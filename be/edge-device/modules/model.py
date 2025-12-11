"""
Face Recognition System with PyTorch
- Using ResNet50 as backbone
- ArcFace Loss function
- Augmentation techniques for training
- Complete training and evaluation pipeline
"""

import os
import numpy as np
import math
import random
import sys
import glob

import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader, RandomSampler
from torch.optim.lr_scheduler import CosineAnnealingLR
from torchvision import transforms, models
from torch.utils.tensorboard import SummaryWriter
from torchvision.transforms import InterpolationMode

from PIL import Image, ImageOps
from tqdm import tqdm
from datetime import datetime


class Logger(object):
    def __init__(self, filename="training.log"):
        self.terminal = sys.stdout
        self.log = open(filename, "a", encoding="utf-8")

    def write(self, message):
        self.terminal.write(message)
        self.log.write(message)

    def flush(self):
        pass  # Required for python stdout compatibility


# Redirect print → both console and file
sys.stdout = Logger("./outputs/training.log")


# Set seeds for consistency
def seed_everything(seed):
    random.seed(seed)
    os.environ["PYTHONHASHSEED"] = str(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False


seed_everything(42)


def seed_worker(worker_id):
    """
    Seed for each worker DataLoader
    """
    worker_seed = torch.initial_seed() % 2**32
    np.random.seed(worker_seed)
    random.seed(worker_seed)


class Config:
    # General configuration
    DATA_ROOT = "./data/faces"  # Path to face data
    TRAIN_LIST = "./data/train_list_new.txt"  # Training list file
    VAL_LIST = "./data/val_list.txt"  # Validation list file
    OUTPUT_DIR = "./outputs"  # Output directory for the model

    # Model parameters
    BACKBONE = "resnet50"  # Backbone: resnet18, resnet34, resnet50, resnet101
    EMBEDDING_SIZE = 512  # Embedding vector size
    DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    # Training parameters
    BATCH_SIZE = 64
    NUM_WORKERS = 4
    NUM_EPOCHS = 40
    LEARNING_RATE = 0.1
    MOMENTUM = 0.9
    WEIGHT_DECAY = 5e-4

    # ArcFace parameters
    ARCFACE_S = 30.0  # Scale
    ARCFACE_M = 0.5  # Margin

    # Image configuration
    IMG_SIZE = 224  # Input image size

    # Evaluation configuration
    EVAL_BATCH_SIZE = 128
    EVAL_FREQUENCY = 5  # Evaluation frequency (after how many epochs)
    TEST_PAIRS = "./data/pairs_test.txt"  # File containing image pairs for evaluation

    # Verification threshold
    VERIFICATION_THRESHOLD = 0.5  # Cosine similarity threshold


# --------------------
# PART 1: DATA
# --------------------


class FaceDataset(Dataset):
    """
    Dataset cho dữ liệu khuôn mặt
    """

    def __init__(self, data_root, list_file, transform=None):
        """
        Args:
            data_root (str): Thư mục gốc chứa ảnh khuôn mặt
            list_file (str): File danh sách ảnh và nhãn (định dạng: đường_dẫn nhãn)
            transform: Các phép biến đổi áp dụng cho ảnh
        """
        self.data_root = data_root
        self.transform = transform

        # Read image and label list
        self.image_list = []
        self.label_list = []

        with open(list_file, "r") as f:
            lines = f.readlines()
            for line in lines:
                line = line.strip().split()  # This is used for name without space
                # line = line.strip().rsplit(" ", 1)
                if len(line) == 2:
                    img_path, label = line
                    self.image_list.append(img_path)
                    self.label_list.append(int(label))

        # Create a mapping from labels to consecutive indices (0, 1, 2, ...)
        # unique_labels = sorted(set(self.label_list))
        # self.label_map = {label: i for i, label in enumerate(unique_labels)}
        # self.num_classes = len(unique_labels)
        self.num_classes = max(self.label_list) + 1

        # Remap labels
        # self.label_list = [self.label_map[label] for label in self.label_list]

        print(f"Loaded {len(self.image_list)} images of {self.num_classes} identities.")

    def __len__(self):
        return len(self.image_list)

    def __getitem__(self, idx):
        img_path = os.path.join(self.data_root, self.image_list[idx])
        label = self.label_list[idx]

        # Read image
        img = Image.open(img_path).convert("RGB")

        # Apply transformations
        if self.transform:
            img = self.transform(img)

        return img, label


# Tăng cường dữ liệu
# def get_train_transform():
#     """
#     Phép biến đổi cho ảnh huấn luyện với tăng cường dữ liệu
#     """
#     return transforms.Compose(
#         [
#             transforms.RandomHorizontalFlip(),  # Lật ngang ngẫu nhiên
#             transforms.RandomRotation(15),  # Xoay ảnh ngẫu nhiên ±15 độ
#             transforms.ColorJitter(  # Thay đổi màu sắc ngẫu nhiên
#                 brightness=0.2, contrast=0.2, saturation=0.2, hue=0.1
#             ),
#             transforms.RandomResizedCrop(  # Cắt và resize ngẫu nhiên
#                 size=Config.IMG_SIZE,
#                 scale=(0.8, 1.0),  # Tỷ lệ cắt từ 80% đến 100%
#                 ratio=(0.9, 1.1),  # Tỷ lệ khung hình giữ gần 1:1
#             ),
#             transforms.ToTensor(),  # Chuyển sang tensor
#             transforms.Normalize(  # Chuẩn hóa theo ImageNet
#                 mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]
#             ),
#         ]
#     )


def get_train_transform():
    # Shift ~21 px relative to the current image size
    frac = 21.0 / float(Config.IMG_SIZE)

    return transforms.Compose(
        [
            ToSquareLetterbox(
                Config.IMG_SIZE, fill=(124, 116, 104)
            ),  # Fixed size in advance
            transforms.RandomHorizontalFlip(p=0.5),
            transforms.RandomAffine(
                degrees=15,
                translate=(frac, frac),
                scale=None,
                shear=None,
                interpolation=InterpolationMode.BILINEAR,
                fill=(124, 116, 104),
            ),
            transforms.RandomApply(
                [
                    transforms.ColorJitter(
                        brightness=0.2, contrast=0.2, saturation=0.2, hue=0.05
                    )
                ],
                p=0.25,
            ),
            transforms.RandomApply(
                [transforms.GaussianBlur(kernel_size=3, sigma=(0.4, 1.0))], p=0.10
            ),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
            transforms.RandomErasing(
                p=0.25, scale=(0.02, 0.08), ratio=(0.3, 3.3), value="random"
            ),
        ]
    )


class ToSquareLetterbox:
    def __init__(self, size=224, fill=(124, 116, 104)):
        self.size = size
        self.fill = fill

    def __call__(self, img: Image.Image):
        w, h = img.size
        s = self.size
        scale = s / max(w, h)
        nw, nh = max(1, int(round(w * scale))), max(1, int(round(h * scale)))
        img = img.resize((nw, nh), resample=Image.BILINEAR)
        pad_l = (s - nw) // 2
        pad_t = (s - nh) // 2
        pad_r = s - nw - pad_l
        pad_b = s - nh - pad_t
        return ImageOps.expand(img, border=(pad_l, pad_t, pad_r, pad_b), fill=self.fill)


def get_val_transform():
    return transforms.Compose(
        [
            ToSquareLetterbox(Config.IMG_SIZE, fill=(124, 116, 104)),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
        ]
    )

    # def get_val_transform():
    """
    Phép biến đổi cho ảnh kiểm tra/đánh giá (không augmentation). Dự kiến sẽ sử dụng augmentation để tạo thêm dữ liệu.
    """
    # return transforms.Compose(
    #     [
    #         transforms.Resize(Config.IMG_SIZE),
    #         transforms.CenterCrop(Config.IMG_SIZE),
    #         transforms.ToTensor(),
    #         transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    #     ]
    # )
    # return transforms.Compose(
    #     [
    #         transforms.Resize(
    #             (Config.IMG_SIZE, Config.IMG_SIZE),
    #             interpolation=InterpolationMode.BILINEAR,
    #             antialias=True,
    #         ),
    #         transforms.ToTensor(),
    #         transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    #     ]
    # )


# --------------------
# PHẦN 2: MÔ HÌNH
# --------------------


class SEBlock(nn.Module):
    """
    Squeeze-and-Excitation Block cho việc tập trung vào kênh màu quan trọng
    """

    def __init__(self, channel, reduction=16):
        super(SEBlock, self).__init__()
        self.avg_pool = nn.AdaptiveAvgPool2d(1)
        self.fc = nn.Sequential(
            nn.Linear(channel, channel // reduction, bias=False),
            nn.ReLU(inplace=True),
            nn.Linear(channel // reduction, channel, bias=False),
            nn.Sigmoid(),
        )

    def forward(self, x):
        b, c, _, _ = x.size()
        y = self.avg_pool(x).view(b, c)
        y = self.fc(y).view(b, c, 1, 1)
        return x * y.expand_as(x)


# class IRBlock(nn.Module):
#     """
#     Improved Residual Block với SE được sử dụng trong mô hình nhận dạng khuôn mặt
#     """

#     expansion = 1

#     def __init__(self, inplanes, planes, stride=1, downsample=None, use_se=True):
#         super(IRBlock, self).__init__()
#         self.bn1 = nn.BatchNorm2d(inplanes)
#         self.conv1 = nn.Conv2d(
#             inplanes, planes, kernel_size=3, stride=stride, padding=1, bias=False
#         )
#         self.bn2 = nn.BatchNorm2d(planes)
#         self.prelu = nn.PReLU(planes)
#         self.conv2 = nn.Conv2d(
#             planes, planes, kernel_size=3, stride=1, padding=1, bias=False
#         )
#         self.bn3 = nn.BatchNorm2d(planes)
#         self.downsample = downsample
#         self.stride = stride
#         self.use_se = use_se
#         if self.use_se:
#             self.se = SEBlock(planes)

#     def forward(self, x):
#         residual = x
#         out = self.bn1(x)
#         out = self.conv1(out)
#         out = self.bn2(out)
#         out = self.prelu(out)
#         out = self.conv2(out)
#         out = self.bn3(out)
#         if self.use_se:
#             out = self.se(out)
#         if self.downsample is not None:
#             residual = self.downsample(x)
#         out += residual
#         return out


class FaceBackbone(nn.Module):
    """
    Backbone cho mô hình nhận dạng khuôn mặt, dựa trên ResNet với các khối IR
    """

    def __init__(self, backbone_name="resnet50"):
        super(FaceBackbone, self).__init__()

        # Lấy mô hình backbone từ torchvision
        if backbone_name == "resnet18":
            self.backbone = models.resnet18(weights="DEFAULT")
            feature_dim = 512
        elif backbone_name == "resnet34":
            self.backbone = models.resnet34(weights="DEFAULT")
            feature_dim = 512
        elif backbone_name == "resnet50":
            self.backbone = models.resnet50(weights="DEFAULT")
            feature_dim = 2048
        elif backbone_name == "resnet101":
            self.backbone = models.resnet101(weights="DEFAULT")
            feature_dim = 2048
        else:
            raise ValueError(f"Backbone {backbone_name} không được hỗ trợ")

        # Discard last fully connected layer
        self.backbone = nn.Sequential(*list(self.backbone.children())[:-2])

        # Add SE Block to enhance performance
        # SE operates on features with spatial dimensions (H,W > 1)
        self.se = SEBlock(feature_dim, reduction=16)

        # Remember output feature dimension
        self.gap = nn.AdaptiveAvgPool2d(1)
        self.feature_dim = feature_dim

    def forward(self, x):
        x = self.backbone(x)
        x = self.se(x)
        x = self.gap(x)
        x = x.view(x.size(0), -1)  # Flatten tensor
        return x


class FaceRecognitionModel(nn.Module):
    """
    Mô hình nhận dạng khuôn mặt hoàn chỉnh với backbone và head tạo embedding
    """

    def __init__(self, backbone_name="resnet50", embedding_size=512, num_classes=None):
        super(FaceRecognitionModel, self).__init__()

        # Backbone for features extraction
        self.backbone = FaceBackbone(backbone_name)
        feature_dim = self.backbone.feature_dim

        # Head for embedding creation
        self.embedding = nn.Linear(feature_dim, embedding_size)
        self.bn = nn.BatchNorm1d(embedding_size)

        # ArcFace classification layer (if needed)
        self.num_classes = num_classes
        if num_classes is not None:
            self.arcface = ArcFaceLayer(
                embedding_size, num_classes, s=Config.ARCFACE_S, m=Config.ARCFACE_M
            )

    def forward(self, x, labels=None):
        # Extract features from backbone
        features = self.backbone(x)

        # Create embedding and normalize
        embedding = self.embedding(features)
        embedding = self.bn(embedding)
        embedding = F.normalize(embedding, p=2, dim=1)  # L2 normalization

        # Apply ArcFace if labels are provided
        if self.num_classes is not None and labels is not None:
            logits = self.arcface(embedding, labels)
            return embedding, logits

        return embedding


class ArcFaceLayer(nn.Module):
    """
    Lớp ArcFace để tính toán hàm mất mát dựa trên góc
    """

    def __init__(self, in_features, out_features, s=30.0, m=0.5):
        super(ArcFaceLayer, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.s = s  # Scale
        self.m = m  # Margin

        # Weight initialization for each layer
        self.weight = nn.Parameter(torch.FloatTensor(out_features, in_features))
        nn.init.xavier_uniform_(self.weight)

        # Calculate minimal angle using algebra
        self.cos_m = math.cos(m)
        self.sin_m = math.sin(m)
        self.th = math.cos(math.pi - m)
        self.mm = math.sin(math.pi - m) * m

    def forward(self, input, label):
        # Normalize weights (each row is a normalized feature vector)
        x = F.normalize(input, p=2, dim=1)
        weight = F.normalize(self.weight, p=2, dim=1)

        # Calculate cosine similarity between input and weights
        cosine = F.linear(x, weight)
        # Clamp to avoid numerical errors when sqrt
        cosine = cosine.clamp(-1.0 + 1e-7, 1.0 - 1e-7)
        sine = torch.sqrt(1.0 - cosine * cosine)

        # Limit range to avoid numerical errors
        sine = torch.sqrt(1.0 - torch.pow(cosine, 2))

        # Formula for angle phi + m where phi is the angle between feature and weight
        phi = cosine * self.cos_m - sine * self.sin_m

        # Condition: cosθ > cosθ_th to ensure monotonicity
        phi = torch.where(cosine > self.th, phi, cosine - self.mm)

        # Convert labels to one-hot encoding
        one_hot = torch.zeros(cosine.size(), device=cosine.device)
        one_hot.scatter_(1, label.view(-1, 1).long(), 1)

        # Apply margin to correct classes, keep unchanged for incorrect classes
        output = (one_hot * phi) + ((1.0 - one_hot) * cosine)

        # Apply scaling factor
        output = output * self.s

        return output


# --------------------
# PHẦN 3: HUẤN LUYỆN
# --------------------


def train_one_epoch(
    model, dataloader, criterion, optimizer, device, epoch, total_epochs
):
    """
    Huấn luyện mô hình trong một epoch
    """
    model.train()
    total_loss = 0.0
    correct = 0
    total = 0

    pbar = tqdm(dataloader, desc=f"Epoch {epoch+1}/{total_epochs}")
    for batch_idx, (inputs, targets) in enumerate(pbar):
        inputs, targets = inputs.to(device, non_blocking=True), targets.to(
            device, non_blocking=True
        )

        # Forward pass
        _, outputs = model(inputs, targets)
        loss = criterion(outputs, targets)

        # Backward pass and optimize
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        # Thống kê
        total_loss += loss.item()
        _, predicted = outputs.max(1)
        total += targets.size(0)
        correct += predicted.eq(targets).sum().item()

        # Cập nhật thanh tiến trình
        pbar.set_postfix(
            {"loss": total_loss / (batch_idx + 1), "acc": 100.0 * correct / total}
        )

    # Tính toán kết quả cuối cùng
    avg_loss = total_loss / len(dataloader)
    accuracy = 100.0 * correct / total

    return avg_loss, accuracy


def validate(model, dataloader, criterion, device):
    """
    Đánh giá mô hình trên tập validation
    """
    model.eval()
    total_loss = 0.0
    correct = 0
    total = 0

    with torch.no_grad():
        for batch_idx, (inputs, targets) in enumerate(dataloader):
            inputs, targets = inputs.to(device), targets.to(device)

            # Forward pass
            _, outputs = model(inputs, targets)
            loss = criterion(outputs, targets)

            # Thống kê
            total_loss += loss.item()
            _, predicted = outputs.max(1)
            total += targets.size(0)
            correct += predicted.eq(targets).sum().item()

    # Tính toán kết quả cuối cùng
    avg_loss = total_loss / len(dataloader)
    accuracy = 100.0 * correct / total

    return avg_loss, accuracy


def find_image_path(data_root, name, idx):
    folder = os.path.join(data_root, name)
    base = f"{name}_{idx:04d}"

    # Thử theo list extension quen thuộc
    for ext in [".jpg", ".jpeg", ".png", ".bmp", ".webp"]:
        candidate = os.path.join(folder, base + ext)
        if os.path.exists(candidate):
            return candidate

    # Nếu vẫn không thấy, dùng glob bắt mọi đuôi
    pattern = os.path.join(folder, base + ".*")
    matches = glob.glob(pattern)
    if matches:
        return matches[0]  # hoặc raise nếu muốn strict hơn

    raise FileNotFoundError(f"Không tìm thấy file cho: {folder}/{base}.*")


def evaluate_pairs(model, data_root, pairs_file, transform, device, threshold=0.5):
    """
    Đánh giá mô hình trên các cặp ảnh (same/different)
    """
    model.eval()

    # Đọc file cặp ảnh
    pairs = []
    with open(pairs_file, "r") as f:
        lines = f.readlines()
        for line in lines:
            line = line.strip().split()  # This is used for name without space
            # line = line.strip().split(" ", 2)  # This is used for name with space
            if len(line) == 3:  # Cùng danh tính: name img1_idx img2_idx
                name = line[0]
                idx1 = int(line[1])
                idx2 = int(line[2])
                img1_path = find_image_path(data_root, name, idx1)
                img2_path = find_image_path(data_root, name, idx2)
                pairs.append((img1_path, img2_path, 1))  # 1 = same
            elif (
                len(line) > 3
            ):  # Khác danh tính: name1 img1_idx name2 img2_idx len(line) == 4
                name1 = line[0]
                idx1 = int(line[1])
                name2 = line[2]
                idx2 = int(line[3])
                img1_path = find_image_path(data_root, name1, idx1)
                img2_path = find_image_path(data_root, name2, idx2)
                pairs.append((img1_path, img2_path, 0))  # 0 = different

    correct = 0
    distances = []
    targets = []

    for img1_path, img2_path, target in tqdm(pairs, desc="Evaluating pairs"):
        # Đọc ảnh
        img1 = Image.open(img1_path).convert("RGB")
        img2 = Image.open(img2_path).convert("RGB")

        # Áp dụng transform
        img1 = transform(img1).unsqueeze(0).to(device)
        img2 = transform(img2).unsqueeze(0).to(device)

        # Tính embedding
        with torch.no_grad():
            embedding1 = model(img1)
            embedding2 = model(img2)

        # Tính cosine similarity
        cosine_sim = F.cosine_similarity(embedding1, embedding2).item()
        distances.append(cosine_sim)
        targets.append(target)

        # Kiểm tra kết quả
        pred = 1 if cosine_sim >= threshold else 0
        if pred == target:
            correct += 1

    # Tính độ chính xác
    accuracy = 100.0 * correct / len(pairs)

    # Tính ROC và AUC
    distances = np.array(distances)
    targets = np.array(targets)

    # Tính FAR và FRR
    thresholds = np.arange(-1, 1, 0.01)
    far = []
    frr = []
    best_threshold = 0
    min_diff = 100  # Khởi tạo với giá trị lớn

    for th in thresholds:
        predictions = (distances >= th).astype(int)
        fp = np.sum((predictions == 1) & (targets == 0))
        fn = np.sum((predictions == 0) & (targets == 1))

        # Tính tỷ lệ
        far_val = fp / np.sum(targets == 0) if np.sum(targets == 0) > 0 else 0
        frr_val = fn / np.sum(targets == 1) if np.sum(targets == 1) > 0 else 0

        far.append(far_val)
        frr.append(frr_val)

        # Tìm ngưỡng cân bằng
        diff = abs(far_val - frr_val)
        if diff < min_diff:
            min_diff = diff
            best_threshold = th

    # Tìm EER (Equal Error Rate)
    far = np.array(far)
    frr = np.array(frr)
    eer_idx = np.argmin(np.abs(far - frr))
    eer = (far[eer_idx] + frr[eer_idx]) / 2

    return accuracy, best_threshold, eer


# --------------------
# PHẦN 4: HÀM CHÍNH
# --------------------


def main():
    # Create output directory
    os.makedirs(Config.OUTPUT_DIR, exist_ok=True)

    # Initialize TensorBoard writer
    log_dir = os.path.join(
        Config.OUTPUT_DIR, "logs", datetime.now().strftime("%Y%m%d_%H%M%S")
    )
    writer = SummaryWriter(log_dir)

    # Prepare data
    train_transform = get_train_transform()
    val_transform = get_val_transform()

    # Create datasets
    train_dataset = FaceDataset(
        Config.DATA_ROOT, Config.TRAIN_LIST, transform=train_transform
    )
    val_dataset = FaceDataset(
        Config.DATA_ROOT, Config.VAL_LIST, transform=val_transform
    )

    # Use RandomSampler to ensure each batch has diverse identities
    TARGET_PER_EPOCH = 3000  # Target number of images per epoch
    sampler = RandomSampler(
        data_source=train_dataset,
        replacement=True,  # allow repeating the same image
        num_samples=TARGET_PER_EPOCH,  # total number of samples per epoch
    )

    g = torch.Generator()
    g.manual_seed(42)

    # Number of classes (identities)
    num_classes = train_dataset.num_classes
    print(f"Number of identity classes: {num_classes}")

    # Create dataloaders
    train_loader = DataLoader(
        train_dataset,
        batch_size=Config.BATCH_SIZE,
        sampler=sampler,
        num_workers=Config.NUM_WORKERS,
        pin_memory=True,
        worker_init_fn=seed_worker,
        generator=g,
    )

    val_loader = DataLoader(
        val_dataset,
        batch_size=Config.EVAL_BATCH_SIZE,
        shuffle=False,
        num_workers=Config.NUM_WORKERS,
        pin_memory=True,
    )

    # Initialize model
    model = FaceRecognitionModel(
        backbone_name=Config.BACKBONE,
        embedding_size=Config.EMBEDDING_SIZE,
        num_classes=num_classes,
    )

    # Move model to GPU if available
    model = model.to(Config.DEVICE)

    # Loss function (Cross Entropy)
    criterion = nn.CrossEntropyLoss()

    # Optimization
    optimizer = optim.SGD(
        model.parameters(),
        lr=Config.LEARNING_RATE,
        momentum=Config.MOMENTUM,
        weight_decay=Config.WEIGHT_DECAY,
    )

    # Learning rate schedule: reduce lr after every 10 epochs
    scheduler = CosineAnnealingLR(optimizer, T_max=Config.NUM_EPOCHS, eta_min=1e-5)

    # Model information
    print(f"Model: {Config.BACKBONE} with embedding size {Config.EMBEDDING_SIZE}")
    print(f"Training on {Config.DEVICE}")

    # Variable to track the best model
    best_val_acc = 0.0

    # Training loop
    for epoch in range(Config.NUM_EPOCHS):
        # Train one epoch
        train_loss, train_acc = train_one_epoch(
            model,
            train_loader,
            criterion,
            optimizer,
            Config.DEVICE,
            epoch,
            Config.NUM_EPOCHS,
        )

        # Evaluate on validation set
        val_loss, val_acc = validate(model, val_loader, criterion, Config.DEVICE)

        # Update learning rate
        scheduler.step()

        # Write log
        print(f"Epoch {epoch+1}/{Config.NUM_EPOCHS}")
        print(f"Train Loss: {train_loss:.4f}, Train Acc: {train_acc:.2f}%")
        print(f"Val Loss: {val_loss:.4f}, Val Acc: {val_acc:.2f}%")
        print(f"Learning rate: {optimizer.param_groups[0]['lr']:.6f}")

        # Write log into TensorBoard
        writer.add_scalar("Loss/train", train_loss, epoch)
        writer.add_scalar("Loss/val", val_loss, epoch)
        writer.add_scalar("Accuracy/train", train_acc, epoch)
        writer.add_scalar("Accuracy/val", val_acc, epoch)
        writer.add_scalar("LearningRate", optimizer.param_groups[0]["lr"], epoch)

        # Save the best model basing on validation accuracy
        if val_acc > best_val_acc:
            best_val_acc = val_acc
            torch.save(
                model.state_dict(), os.path.join(Config.OUTPUT_DIR, "best_model.pth")
            )
            print(f"Saved best model with validation accuracy: {val_acc:.2f}%")

        # Save checkpoint
        torch.save(
            {
                "epoch": epoch,
                "model_state_dict": model.state_dict(),
                "optimizer_state_dict": optimizer.state_dict(),
                "scheduler_state_dict": scheduler.state_dict(),
                "train_loss": train_loss,
                "val_loss": val_loss,
                "train_acc": train_acc,
                "val_acc": val_acc,
            },
            os.path.join(Config.OUTPUT_DIR, "checkpoint.pth"),
        )

        # Evaluate on pairs every EVAL_FREQUENCY epochs
        if (epoch + 1) % Config.EVAL_FREQUENCY == 0 and Config.TEST_PAIRS:
            # Switch to evaluation mode without classification head
            model.eval()
            accuracy, best_threshold, eer = evaluate_pairs(
                model,
                Config.DATA_ROOT,
                Config.TEST_PAIRS,
                val_transform,
                Config.DEVICE,
                Config.VERIFICATION_THRESHOLD,
            )

            print(
                f"Pair Evaluation - Accuracy: {accuracy:.2f}%, Threshold: {best_threshold:.2f}, EER: {eer:.4f}"
            )

            # Write log into TensorBoard
            writer.add_scalar("Verification/accuracy", accuracy, epoch)
            writer.add_scalar("Verification/threshold", best_threshold, epoch)
            writer.add_scalar("Verification/eer", eer, epoch)

    # Close TensorBoard writer
    writer.close()

    print("Training completed!")
    print(f"Best validation accuracy: {best_val_acc:.2f}%")

    # Export model to ONNX
    best_pth = os.path.join(Config.OUTPUT_DIR, "best_model.pth")
    onnx_path = os.path.join(Config.OUTPUT_DIR, "embedder.onnx")
    export_embedder_to_onnx(
        pth_path=best_pth,
        onnx_path=onnx_path,
        img_size=Config.IMG_SIZE,
        backbone=Config.BACKBONE,
        emb_size=Config.EMBEDDING_SIZE,
        device="cpu",
    )
    print("[ONNX] exported once from final best_model.pth")


# --------------------
# PHẦN 6: XUẤT ONNX
# --------------------


def export_embedder_to_onnx(
    pth_path, onnx_path, img_size=224, backbone="resnet50", emb_size=512, device="cpu"
):
    model = FaceRecognitionModel(backbone_name=backbone, embedding_size=emb_size)
    sd = torch.load(pth_path, map_location=device)
    # Strip ArcFace head weights if they exist
    sd = {k: v for k, v in sd.items() if not k.startswith("arcface.")}
    model.load_state_dict(sd, strict=False)
    model.eval()

    dummy = torch.randn(1, 3, img_size, img_size, device=device)
    torch.onnx.export(
        model,
        dummy,
        onnx_path,
        input_names=["input"],
        output_names=["emb"],
        opset_version=13,
        dynamic_axes={"input": {0: "batch"}, "emb": {0: "batch"}},
    )
    print(f"Exported ONNX to: {onnx_path}")


# --------------------
# PHẦN 6: INFERENCE
# --------------------


class FaceVerification:
    """
    Lớp nhận diện khuôn mặt sử dụng mô hình đã huấn luyện
    """

    def __init__(
        self, model_path, backbone_name="resnet50", embedding_size=512, device=None
    ):
        if device is None:
            self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        else:
            self.device = device

        # Initialize model
        self.model = FaceRecognitionModel(backbone_name, embedding_size)
        sd = torch.load(model_path, map_location=self.device)
        sd = {k: v for k, v in sd.items() if not k.startswith("arcface.")}
        self.model.load_state_dict(sd, strict=False)
        # self.model.load_state_dict(torch.load(model_path, map_location=self.device))
        self.model = self.model.to(self.device)
        self.model.eval()

        # Transform for images
        self.transform = get_val_transform()

        # Database for storing embedding vectors
        self.database = {}
        self.threshold = 0.5  # Default threshold

    def add_face(self, image, identity, align=True):
        """
        Thêm khuôn mặt mới vào cơ sở dữ liệu

        Args:
            image: Ảnh khuôn mặt (numpy array hoặc PIL Image)
            identity: Tên danh tính
            align: Có căn chỉnh khuôn mặt hay không
        """
        # If numpy array, convert to PIL Image
        if isinstance(image, np.ndarray):
            image = Image.fromarray(image.astype("uint8"))

        # Apply transform
        image_tensor = self.transform(image).unsqueeze(0).to(self.device)

        # Calculate embedding
        with torch.no_grad():
            embedding = self.model(image_tensor)

        # Save to database
        if identity in self.database:
            # Average with existing embeddings
            current_emb = self.database[identity]
            new_emb = (current_emb + embedding.cpu().numpy()) / 2
            self.database[identity] = new_emb
        else:
            self.database[identity] = embedding.cpu().numpy()

    def recognize(self, image, align=True):
        """
        Nhận diện khuôn mặt

        Args:
            image: Ảnh khuôn mặt (numpy array hoặc PIL Image)
            align: Có căn chỉnh khuôn mặt hay không

        Returns:
            identity: Danh tính nhận diện được
            similarity: Độ tương đồng
        """
        # If numpy array, convert to PIL Image
        if isinstance(image, np.ndarray):
            image = Image.fromarray(image.astype("uint8"))

        # Apply transform
        image_tensor = self.transform(image).unsqueeze(0).to(self.device)

        # Calculate embedding
        with torch.no_grad():
            embedding = self.model(image_tensor)

        # Compare to database
        best_match = None
        best_similarity = -1

        for identity, stored_emb in self.database.items():
            # Calculate cosine similarity
            similarity = F.cosine_similarity(
                embedding, torch.from_numpy(stored_emb).to(self.device)
            ).item()

            if similarity > best_similarity:
                best_similarity = similarity
                best_match = identity

        # Check threshold
        if best_similarity < self.threshold:
            return "Unknown", best_similarity

        return best_match, best_similarity

    def set_threshold(self, threshold):
        """
        Thiết lập ngưỡng nhận diện
        """
        self.threshold = threshold

    def save_database(self, path):
        """
        Lưu database embedding
        """
        np.save(path, self.database)

    def load_database(self, path):
        """
        Tải database embedding
        """
        self.database = np.load(path, allow_pickle=True).item()


# Run main function when running script directly
if __name__ == "__main__":
    main()
