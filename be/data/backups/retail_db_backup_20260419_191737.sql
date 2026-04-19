--
-- PostgreSQL database dump
--

\restrict bNqaCUhD2zYwzdZNpGNIOcbsf0dkwuKI8mL7CxUX3YSPkMl6tYDXog2OzSMprdu

-- Dumped from database version 15.17 (Debian 15.17-1.pgdg12+1)
-- Dumped by pg_dump version 15.17 (Debian 15.17-1.pgdg12+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ab_experiment_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ab_experiment_events (
    id integer NOT NULL,
    experiment_id character varying(100) NOT NULL,
    variant character varying(1) NOT NULL,
    branch_id character varying(50),
    customer_id integer,
    device_id character varying(50),
    converted boolean,
    metric_value double precision,
    "timestamp" timestamp with time zone
);


--
-- Name: ab_experiment_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ab_experiment_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ab_experiment_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ab_experiment_events_id_seq OWNED BY public.ab_experiment_events.id;


--
-- Name: ab_experiments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ab_experiments (
    id integer NOT NULL,
    experiment_id character varying(100) NOT NULL,
    experiment_name character varying(200) NOT NULL,
    variant_a json NOT NULL,
    variant_b json NOT NULL,
    split_ratio double precision,
    target_branches json,
    target_metric character varying(50),
    status character varying(50),
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: ab_experiments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ab_experiments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ab_experiments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ab_experiments_id_seq OWNED BY public.ab_experiments.id;


--
-- Name: branch_inventory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branch_inventory (
    id integer NOT NULL,
    branch_id character varying(50) NOT NULL,
    product_id integer NOT NULL,
    stock integer NOT NULL,
    reserved integer NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: branch_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.branch_inventory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branch_inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.branch_inventory_id_seq OWNED BY public.branch_inventory.id;


--
-- Name: branch_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branch_metrics (
    id integer NOT NULL,
    branch_id character varying(50) NOT NULL,
    date date NOT NULL,
    total_transactions integer,
    total_revenue double precision,
    avg_transaction_value double precision,
    total_recommendations integer,
    recommendations_accepted integer,
    acceptance_rate double precision,
    avg_latency_ms double precision,
    inference_count integer,
    top_selling_products json,
    out_of_stock_items json,
    created_at timestamp without time zone
);


--
-- Name: branch_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.branch_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branch_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.branch_metrics_id_seq OWNED BY public.branch_metrics.id;


--
-- Name: customer_consents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_consents (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    face_recognition_consent boolean,
    data_collection_consent boolean,
    marketing_consent boolean,
    opted_out boolean,
    opted_out_at timestamp without time zone,
    opt_out_reason text,
    consent_method character varying(50),
    consent_ip_address character varying(50),
    consent_location character varying(200),
    data_retention_until timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: customer_consents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_consents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_consents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_consents_id_seq OWNED BY public.customer_consents.id;


--
-- Name: customer_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_stats (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    total_transactions integer,
    total_spent numeric(15,2),
    avg_basket_size numeric(12,2),
    favorite_categories json,
    last_purchase_date timestamp without time zone,
    rank_score double precision,
    segment character varying(50),
    updated_at timestamp with time zone
);


--
-- Name: customer_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_stats_id_seq OWNED BY public.customer_stats.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    customer_id character varying(100) NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    phone character varying(20),
    email character varying(120),
    cccd character varying(20),
    address character varying(255),
    birth_date date,
    age integer,
    age_group character varying(20),
    gender character varying(20),
    description text,
    preferred_branch character varying(50),
    avg_basket_size double precision,
    first_seen timestamp with time zone,
    last_seen timestamp with time zone,
    created_at timestamp with time zone
);


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: edge_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.edge_devices (
    id character varying(50) NOT NULL,
    branch_id character varying(50) NOT NULL,
    name character varying(100),
    description text,
    ip_address character varying(50),
    status character varying(20),
    last_seen timestamp without time zone,
    created_at timestamp without time zone
);


--
-- Name: face_embeddings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.face_embeddings (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    embedding public.vector(512) NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: face_embeddings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.face_embeddings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: face_embeddings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.face_embeddings_id_seq OWNED BY public.face_embeddings.id;


--
-- Name: face_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.face_events (
    id integer NOT NULL,
    branch_id character varying(50) NOT NULL,
    device_id character varying(50),
    event_type character varying(50) NOT NULL,
    "timestamp" timestamp with time zone,
    customer_id integer,
    similarity double precision,
    face_attributes json,
    transaction_id character varying(100),
    created_at timestamp with time zone
);


--
-- Name: face_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.face_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: face_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.face_events_id_seq OWNED BY public.face_events.id;


--
-- Name: federated_client_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.federated_client_updates (
    id integer NOT NULL,
    round_number integer NOT NULL,
    branch_id character varying(50) NOT NULL,
    update_path text NOT NULL,
    update_size_mb double precision,
    local_loss double precision,
    local_accuracy double precision,
    local_samples_count integer,
    status character varying(50),
    created_at timestamp without time zone
);


--
-- Name: federated_client_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.federated_client_updates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: federated_client_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.federated_client_updates_id_seq OWNED BY public.federated_client_updates.id;


--
-- Name: federated_learning_rounds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.federated_learning_rounds (
    id integer NOT NULL,
    round_number integer NOT NULL,
    model_type character varying(100) NOT NULL,
    aggregation_method character varying(50),
    participating_branches json,
    total_branches integer,
    status character varying(50),
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: federated_learning_rounds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.federated_learning_rounds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: federated_learning_rounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.federated_learning_rounds_id_seq OWNED BY public.federated_learning_rounds.id;


--
-- Name: inventory_optimizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_optimizations (
    id integer NOT NULL,
    branch_id character varying(50) NOT NULL,
    product_id integer NOT NULL,
    action character varying(50) NOT NULL,
    quantity integer NOT NULL,
    priority character varying(20),
    reason text,
    status character varying(20),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: inventory_optimizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventory_optimizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_optimizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventory_optimizations_id_seq OWNED BY public.inventory_optimizations.id;


--
-- Name: model_performance_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.model_performance_logs (
    id integer NOT NULL,
    model_version character varying(100) NOT NULL,
    date timestamp without time zone NOT NULL,
    branch_id character varying(50),
    precision_at_5 double precision,
    recall_at_5 double precision,
    ndcg_at_5 double precision,
    ctr double precision,
    avg_latency_ms double precision,
    p95_latency_ms double precision,
    created_at timestamp without time zone
);


--
-- Name: model_performance_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.model_performance_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: model_performance_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.model_performance_logs_id_seq OWNED BY public.model_performance_logs.id;


--
-- Name: model_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.model_versions (
    id integer NOT NULL,
    version character varying(50) NOT NULL,
    model_type character varying(50),
    model_path text,
    model_size_mb double precision,
    accuracy double precision,
    "precision" double precision,
    recall double precision,
    f1_score double precision,
    training_date timestamp without time zone,
    deployed_to_branches json,
    is_active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: model_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.model_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: model_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.model_versions_id_seq OWNED BY public.model_versions.id;


--
-- Name: privacy_audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.privacy_audit_logs (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    operation_type character varying(50) NOT NULL,
    operation_details json,
    performed_by character varying(100),
    performed_by_role character varying(50),
    ip_address character varying(50),
    success boolean,
    error_message text,
    "timestamp" timestamp with time zone
);


--
-- Name: privacy_audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.privacy_audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: privacy_audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.privacy_audit_logs_id_seq OWNED BY public.privacy_audit_logs.id;


--
-- Name: product_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_associations (
    id integer NOT NULL,
    product_id integer NOT NULL,
    related_product_id integer NOT NULL,
    confidence double precision NOT NULL,
    lift double precision,
    support double precision
);


--
-- Name: product_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_associations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_associations_id_seq OWNED BY public.product_associations.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    product_code character varying,
    name character varying NOT NULL,
    volume character varying,
    price numeric(12,2) NOT NULL,
    discount_price double precision,
    discount_percent double precision,
    category character varying,
    stock integer,
    description text,
    image_url character varying,
    emotion character varying,
    target_age_group character varying(20),
    target_gender character varying(20),
    usage_context character varying
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: promotion_branches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_branches (
    id integer NOT NULL,
    promotion_id integer NOT NULL,
    branch_id character varying(50) NOT NULL
);


--
-- Name: promotion_branches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promotion_branches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promotion_branches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promotion_branches_id_seq OWNED BY public.promotion_branches.id;


--
-- Name: promotion_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_products (
    id integer NOT NULL,
    promotion_id integer NOT NULL,
    product_id integer NOT NULL,
    discount_value double precision NOT NULL,
    max_qty_per_customer integer
);


--
-- Name: promotion_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promotion_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promotion_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promotion_products_id_seq OWNED BY public.promotion_products.id;


--
-- Name: promotions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotions (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    discount_type character varying(20) NOT NULL,
    start_at timestamp without time zone NOT NULL,
    end_at timestamp without time zone NOT NULL,
    is_active boolean,
    created_at timestamp without time zone
);


--
-- Name: promotions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promotions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promotions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promotions_id_seq OWNED BY public.promotions.id;


--
-- Name: recommendations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recommendations (
    id integer NOT NULL,
    branch_id character varying(50) NOT NULL,
    transaction_id character varying(100),
    "timestamp" timestamp with time zone,
    customer_id integer,
    device_id character varying(50) NOT NULL,
    face_attributes json,
    recommended_products json,
    items_count integer,
    accepted boolean,
    purchased_items json,
    created_at timestamp without time zone
);


--
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recommendations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recommendations_id_seq OWNED BY public.recommendations.id;


--
-- Name: stores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stores (
    id character varying(50) NOT NULL,
    name character varying(100),
    address character varying(200)
);


--
-- Name: transaction_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_items (
    id integer NOT NULL,
    transaction_id integer,
    product_id integer NOT NULL,
    qty integer,
    unit_price double precision
);


--
-- Name: transaction_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transaction_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transaction_items_id_seq OWNED BY public.transaction_items.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    id integer NOT NULL,
    branch_id character varying(50) NOT NULL,
    transaction_id character varying(100) NOT NULL,
    "timestamp" timestamp with time zone,
    customer_id integer,
    device_id character varying(50) NOT NULL,
    items_data json,
    items_count integer,
    total_amount double precision,
    recommended_items json,
    accepted_recommendations boolean,
    created_at timestamp without time zone
);


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: user_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_accounts (
    id integer NOT NULL,
    email character varying(120) NOT NULL,
    password_hash character varying(255) NOT NULL,
    is_admin boolean,
    customer_pk integer,
    created_at timestamp without time zone
);


--
-- Name: user_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_accounts_id_seq OWNED BY public.user_accounts.id;


--
-- Name: ab_experiment_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_experiment_events ALTER COLUMN id SET DEFAULT nextval('public.ab_experiment_events_id_seq'::regclass);


--
-- Name: ab_experiments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_experiments ALTER COLUMN id SET DEFAULT nextval('public.ab_experiments_id_seq'::regclass);


--
-- Name: branch_inventory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_inventory ALTER COLUMN id SET DEFAULT nextval('public.branch_inventory_id_seq'::regclass);


--
-- Name: branch_metrics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_metrics ALTER COLUMN id SET DEFAULT nextval('public.branch_metrics_id_seq'::regclass);


--
-- Name: customer_consents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_consents ALTER COLUMN id SET DEFAULT nextval('public.customer_consents_id_seq'::regclass);


--
-- Name: customer_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_stats ALTER COLUMN id SET DEFAULT nextval('public.customer_stats_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: face_embeddings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.face_embeddings ALTER COLUMN id SET DEFAULT nextval('public.face_embeddings_id_seq'::regclass);


--
-- Name: face_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.face_events ALTER COLUMN id SET DEFAULT nextval('public.face_events_id_seq'::regclass);


--
-- Name: federated_client_updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federated_client_updates ALTER COLUMN id SET DEFAULT nextval('public.federated_client_updates_id_seq'::regclass);


--
-- Name: federated_learning_rounds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federated_learning_rounds ALTER COLUMN id SET DEFAULT nextval('public.federated_learning_rounds_id_seq'::regclass);


--
-- Name: inventory_optimizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_optimizations ALTER COLUMN id SET DEFAULT nextval('public.inventory_optimizations_id_seq'::regclass);


--
-- Name: model_performance_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_performance_logs ALTER COLUMN id SET DEFAULT nextval('public.model_performance_logs_id_seq'::regclass);


--
-- Name: model_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_versions ALTER COLUMN id SET DEFAULT nextval('public.model_versions_id_seq'::regclass);


--
-- Name: privacy_audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.privacy_audit_logs ALTER COLUMN id SET DEFAULT nextval('public.privacy_audit_logs_id_seq'::regclass);


--
-- Name: product_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_associations ALTER COLUMN id SET DEFAULT nextval('public.product_associations_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: promotion_branches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_branches ALTER COLUMN id SET DEFAULT nextval('public.promotion_branches_id_seq'::regclass);


--
-- Name: promotion_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_products ALTER COLUMN id SET DEFAULT nextval('public.promotion_products_id_seq'::regclass);


--
-- Name: promotions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotions ALTER COLUMN id SET DEFAULT nextval('public.promotions_id_seq'::regclass);


--
-- Name: recommendations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations ALTER COLUMN id SET DEFAULT nextval('public.recommendations_id_seq'::regclass);


--
-- Name: transaction_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_items ALTER COLUMN id SET DEFAULT nextval('public.transaction_items_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: user_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_accounts ALTER COLUMN id SET DEFAULT nextval('public.user_accounts_id_seq'::regclass);


--
-- Data for Name: ab_experiment_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ab_experiment_events (id, experiment_id, variant, branch_id, customer_id, device_id, converted, metric_value, "timestamp") FROM stdin;
1	EXP_REC_001	a	HCM_Q7	47	EDGE_HCM_Q7_01	t	392472.02	2026-03-28 16:20:16.341111+00
2	EXP_REC_001	b	HN_CG	22	EDGE_HN_CG_01	f	0	2026-03-26 23:10:16.342114+00
3	EXP_REC_001	b	HCM_Q1	21	EDGE_HCM_Q1_01	f	0	2026-03-15 01:24:16.342114+00
4	EXP_REC_001	b	HCM_Q7	43	EDGE_HCM_Q7_01	f	0	2026-03-16 10:34:16.342114+00
5	EXP_REC_001	b	HN_CG	19	EDGE_HN_CG_01	f	0	2026-03-23 19:58:16.342114+00
6	EXP_REC_001	a	HCM_Q1	\N	EDGE_HCM_Q1_01	f	0	2026-03-30 11:39:16.342114+00
7	EXP_REC_001	b	HCM_Q7	30	EDGE_HCM_Q7_01	t	104330.73	2026-03-13 01:07:16.342114+00
8	EXP_REC_001	a	HCM_Q7	\N	EDGE_HCM_Q7_01	f	0	2026-03-28 13:25:16.342114+00
9	EXP_REC_001	a	HCM_Q7	\N	EDGE_HCM_Q7_01	f	0	2026-03-25 15:22:16.342114+00
10	EXP_REC_001	a	HCM_Q7	44	EDGE_HCM_Q7_01	f	0	2026-03-27 18:32:16.343116+00
11	EXP_REC_001	b	HCM_Q7	58	EDGE_HCM_Q7_01	t	330942.75	2026-03-17 06:23:16.343116+00
12	EXP_REC_001	b	HCM_Q1	36	EDGE_HCM_Q1_01	t	198464	2026-03-18 01:18:16.343116+00
13	EXP_REC_001	a	HCM_Q7	18	EDGE_HCM_Q7_01	f	0	2026-03-18 11:21:16.343116+00
14	EXP_REC_001	b	HN_CG	12	EDGE_HN_CG_01	f	0	2026-03-27 20:36:16.343116+00
15	EXP_REC_001	a	HCM_Q1	8	EDGE_HCM_Q1_01	f	0	2026-03-13 09:24:16.343116+00
16	EXP_REC_001	b	HCM_Q7	7	EDGE_HCM_Q7_01	t	50652.14	2026-03-23 02:26:16.343116+00
17	EXP_REC_001	b	HCM_Q7	14	EDGE_HCM_Q7_01	f	0	2026-03-28 12:07:16.343116+00
18	EXP_REC_001	b	HN_CG	\N	EDGE_HN_CG_01	f	0	2026-03-24 12:19:16.343116+00
19	EXP_REC_001	b	HCM_Q1	11	EDGE_HCM_Q1_01	t	6367.41	2026-03-16 04:18:16.343116+00
20	EXP_REC_001	a	HCM_Q1	17	EDGE_HCM_Q1_01	f	0	2026-03-15 23:39:16.343116+00
21	EXP_REC_001	a	HCM_Q7	16	EDGE_HCM_Q7_01	f	0	2026-03-12 20:21:16.343116+00
22	EXP_REC_001	a	HN_CG	\N	EDGE_HN_CG_01	f	0	2026-03-28 07:48:16.343116+00
23	EXP_REC_001	b	HCM_Q7	\N	EDGE_HCM_Q7_01	f	0	2026-03-22 20:08:16.344117+00
24	EXP_REC_001	b	HCM_Q1	30	EDGE_HCM_Q1_01	f	0	2026-03-14 19:45:16.344117+00
25	EXP_REC_001	a	HN_CG	\N	EDGE_HN_CG_01	t	259654.45	2026-03-11 17:30:16.344117+00
26	EXP_REC_001	b	HCM_Q1	\N	EDGE_HCM_Q1_01	f	0	2026-03-23 22:52:16.344117+00
27	EXP_REC_001	a	HCM_Q7	28	EDGE_HCM_Q7_01	t	477407.2	2026-03-11 14:22:16.344117+00
28	EXP_REC_001	a	HN_CG	\N	EDGE_HN_CG_01	t	339533.18	2026-03-21 05:02:16.344117+00
29	EXP_REC_001	a	HCM_Q7	18	EDGE_HCM_Q7_01	f	0	2026-03-20 22:32:16.344117+00
30	EXP_REC_001	b	HN_CG	30	EDGE_HN_CG_01	t	4167.44	2026-03-27 02:56:16.344117+00
31	EXP_REC_001	b	HN_CG	19	EDGE_HN_CG_01	f	0	2026-03-29 08:39:16.344117+00
32	EXP_REC_001	a	HCM_Q7	14	EDGE_HCM_Q7_01	f	0	2026-03-31 04:17:16.344117+00
33	EXP_REC_001	a	HCM_Q1	1	EDGE_HCM_Q1_01	t	141632.77	2026-03-14 19:50:16.344117+00
34	EXP_REC_001	a	HN_CG	6	EDGE_HN_CG_01	f	0	2026-03-25 04:02:16.344117+00
35	EXP_REC_001	a	HCM_Q7	\N	EDGE_HCM_Q7_01	f	0	2026-03-20 09:48:16.344117+00
36	EXP_REC_001	a	HCM_Q7	25	EDGE_HCM_Q7_01	f	0	2026-03-21 22:20:16.344117+00
37	EXP_REC_001	a	HN_CG	28	EDGE_HN_CG_01	f	0	2026-03-25 09:31:16.344117+00
38	EXP_REC_001	a	HCM_Q7	13	EDGE_HCM_Q7_01	t	463559.32	2026-03-17 00:28:16.344117+00
39	EXP_REC_001	a	HCM_Q7	57	EDGE_HCM_Q7_01	f	0	2026-03-21 00:40:16.344117+00
40	EXP_REC_001	b	HCM_Q7	23	EDGE_HCM_Q7_01	t	480723.46	2026-03-17 16:41:16.344117+00
41	EXP_REC_001	a	HCM_Q7	50	EDGE_HCM_Q7_01	f	0	2026-03-22 10:02:16.345106+00
42	EXP_REC_001	a	HN_CG	9	EDGE_HN_CG_01	f	0	2026-03-19 13:14:16.345106+00
43	EXP_REC_001	a	HN_CG	30	EDGE_HN_CG_01	t	135087.42	2026-03-11 14:18:16.345106+00
44	EXP_REC_001	b	HCM_Q7	53	EDGE_HCM_Q7_01	f	0	2026-03-27 18:02:16.345106+00
45	EXP_REC_001	a	HN_CG	48	EDGE_HN_CG_01	f	0	2026-03-13 18:08:16.345106+00
46	EXP_REC_001	b	HN_CG	58	EDGE_HN_CG_01	f	0	2026-03-31 02:00:16.345106+00
47	EXP_REC_001	a	HCM_Q1	8	EDGE_HCM_Q1_01	f	0	2026-03-28 01:33:16.345106+00
48	EXP_REC_001	b	HCM_Q7	7	EDGE_HCM_Q7_01	t	463022.22	2026-03-22 05:09:16.345106+00
49	EXP_REC_001	b	HCM_Q1	\N	EDGE_HCM_Q1_01	f	0	2026-03-12 14:12:16.345106+00
50	EXP_REC_001	a	HCM_Q1	2	EDGE_HCM_Q1_01	t	370832.36	2026-03-14 11:09:16.345106+00
51	EXP_REC_001	b	HN_CG	19	EDGE_HN_CG_01	t	137590.67	2026-03-18 18:48:16.345106+00
52	EXP_REC_001	a	HCM_Q7	27	EDGE_HCM_Q7_01	t	60063.25	2026-03-19 17:02:16.345106+00
53	EXP_REC_001	a	HN_CG	42	EDGE_HN_CG_01	f	0	2026-03-20 13:10:16.345106+00
54	EXP_REC_001	a	HCM_Q7	\N	EDGE_HCM_Q7_01	f	0	2026-03-20 00:45:16.345106+00
55	EXP_REC_001	b	HCM_Q1	\N	EDGE_HCM_Q1_01	f	0	2026-03-25 21:30:16.345106+00
56	EXP_REC_001	b	HN_CG	47	EDGE_HN_CG_01	f	0	2026-03-27 08:49:16.345106+00
57	EXP_REC_001	a	HCM_Q7	\N	EDGE_HCM_Q7_01	f	0	2026-03-11 02:15:16.345106+00
58	EXP_REC_001	b	HN_CG	\N	EDGE_HN_CG_01	t	162038.31	2026-03-13 06:02:16.345106+00
59	EXP_REC_001	a	HCM_Q1	26	EDGE_HCM_Q1_01	f	0	2026-03-26 10:33:16.345106+00
60	EXP_REC_001	b	HN_CG	32	EDGE_HN_CG_01	f	0	2026-03-24 13:42:16.346103+00
61	EXP_REC_001	b	HN_CG	\N	EDGE_HN_CG_01	f	0	2026-03-29 22:23:16.346103+00
62	EXP_REC_001	b	HN_CG	55	EDGE_HN_CG_01	f	0	2026-03-11 20:46:16.346103+00
63	EXP_REC_001	b	HCM_Q7	12	EDGE_HCM_Q7_01	t	494435.43	2026-03-13 00:27:16.346103+00
64	EXP_REC_001	a	HCM_Q7	32	EDGE_HCM_Q7_01	t	81044.79	2026-03-15 11:34:16.346103+00
65	EXP_REC_001	a	HN_CG	41	EDGE_HN_CG_01	t	70281.3	2026-03-31 05:50:16.346103+00
66	EXP_REC_001	a	HCM_Q1	35	EDGE_HCM_Q1_01	f	0	2026-03-11 01:08:16.346103+00
67	EXP_REC_001	b	HN_CG	14	EDGE_HN_CG_01	t	449877.88	2026-03-27 15:11:16.346103+00
68	EXP_REC_001	a	HCM_Q1	25	EDGE_HCM_Q1_01	f	0	2026-03-22 14:32:16.346103+00
69	EXP_REC_001	a	HN_CG	4	EDGE_HN_CG_01	t	470308.76	2026-03-23 04:54:16.346103+00
70	EXP_REC_001	a	HCM_Q1	56	EDGE_HCM_Q1_01	f	0	2026-03-24 00:40:16.346103+00
71	EXP_REC_001	a	HCM_Q7	20	EDGE_HCM_Q7_01	f	0	2026-03-22 21:38:16.346103+00
72	EXP_REC_001	b	HCM_Q7	27	EDGE_HCM_Q7_01	f	0	2026-03-30 13:26:16.346103+00
73	EXP_REC_001	a	HCM_Q7	47	EDGE_HCM_Q7_01	f	0	2026-03-12 21:55:16.346103+00
74	EXP_REC_001	a	HCM_Q1	\N	EDGE_HCM_Q1_01	f	0	2026-03-11 18:00:16.346103+00
75	EXP_REC_001	a	HN_CG	\N	EDGE_HN_CG_01	t	20870.49	2026-03-30 02:07:16.346103+00
76	EXP_REC_001	b	HCM_Q7	23	EDGE_HCM_Q7_01	f	0	2026-03-24 16:40:16.347103+00
77	EXP_REC_001	a	HCM_Q1	50	EDGE_HCM_Q1_01	f	0	2026-03-30 04:50:16.347103+00
78	EXP_REC_001	a	HCM_Q7	9	EDGE_HCM_Q7_01	t	58996.28	2026-03-12 06:17:16.347103+00
79	EXP_REC_001	a	HCM_Q1	28	EDGE_HCM_Q1_01	t	5024.83	2026-03-17 17:51:16.347103+00
80	EXP_REC_001	a	HN_CG	\N	EDGE_HN_CG_01	f	0	2026-03-24 16:35:16.347103+00
81	EXP_REC_001	a	HCM_Q1	29	EDGE_HCM_Q1_01	t	301208.01	2026-03-24 08:31:16.347103+00
82	EXP_REC_001	a	HN_CG	31	EDGE_HN_CG_01	t	469185.07	2026-03-25 01:54:16.347103+00
83	EXP_REC_001	b	HCM_Q7	\N	EDGE_HCM_Q7_01	f	0	2026-03-20 00:21:16.347103+00
84	EXP_REC_001	b	HCM_Q1	\N	EDGE_HCM_Q1_01	f	0	2026-03-15 14:36:16.347103+00
85	EXP_REC_001	b	HN_CG	27	EDGE_HN_CG_01	t	456024.61	2026-03-15 10:20:16.347103+00
86	EXP_REC_001	b	HCM_Q1	\N	EDGE_HCM_Q1_01	f	0	2026-03-27 16:24:16.347103+00
87	EXP_REC_001	a	HCM_Q7	42	EDGE_HCM_Q7_01	f	0	2026-03-30 09:22:16.347103+00
88	EXP_REC_001	b	HCM_Q1	20	EDGE_HCM_Q1_01	f	0	2026-03-19 02:38:16.347103+00
89	EXP_REC_001	a	HCM_Q7	\N	EDGE_HCM_Q7_01	t	189663.49	2026-03-18 00:36:16.347103+00
90	EXP_REC_001	a	HN_CG	3	EDGE_HN_CG_01	f	0	2026-03-21 08:48:16.347103+00
91	EXP_REC_001	b	HCM_Q1	\N	EDGE_HCM_Q1_01	f	0	2026-03-12 03:44:16.347103+00
92	EXP_REC_001	a	HN_CG	47	EDGE_HN_CG_01	f	0	2026-03-22 00:10:16.347103+00
93	EXP_REC_001	a	HN_CG	47	EDGE_HN_CG_01	f	0	2026-03-16 17:40:16.347103+00
94	EXP_REC_001	b	HCM_Q1	59	EDGE_HCM_Q1_01	t	124966.31	2026-03-14 08:18:16.347103+00
95	EXP_REC_001	b	HN_CG	3	EDGE_HN_CG_01	t	125256.64	2026-03-10 22:39:16.347103+00
96	EXP_REC_001	b	HN_CG	37	EDGE_HN_CG_01	f	0	2026-03-17 03:38:16.348108+00
97	EXP_REC_001	b	HCM_Q1	30	EDGE_HCM_Q1_01	f	0	2026-03-14 11:13:16.348108+00
98	EXP_REC_001	a	HCM_Q7	6	EDGE_HCM_Q7_01	f	0	2026-03-23 09:23:16.348108+00
99	EXP_REC_001	a	HCM_Q1	\N	EDGE_HCM_Q1_01	t	308974.65	2026-03-30 10:32:16.348108+00
100	EXP_REC_001	b	HN_CG	12	EDGE_HN_CG_01	t	358678.85	2026-03-29 19:23:16.348108+00
101	EXP_REC_001	a	HCM_Q1	\N	EDGE_HCM_Q1_01	f	0	2026-03-20 14:35:16.348108+00
102	EXP_REC_001	a	HN_CG	8	EDGE_HN_CG_01	t	285182.95	2026-03-18 14:58:16.348805+00
103	EXP_REC_001	b	HCM_Q1	19	EDGE_HCM_Q1_01	f	0	2026-03-20 07:13:16.348805+00
104	EXP_REC_001	b	HCM_Q7	\N	EDGE_HCM_Q7_01	f	0	2026-03-26 06:37:16.348805+00
105	EXP_REC_001	a	HN_CG	10	EDGE_HN_CG_01	f	0	2026-03-21 00:54:16.348805+00
106	EXP_REC_001	a	HN_CG	\N	EDGE_HN_CG_01	t	291343.12	2026-03-27 04:51:16.348805+00
107	EXP_REC_001	a	HCM_Q1	\N	EDGE_HCM_Q1_01	f	0	2026-03-12 21:04:16.348805+00
108	EXP_REC_001	a	HN_CG	\N	EDGE_HN_CG_01	f	0	2026-03-15 01:11:16.348805+00
109	EXP_REC_001	a	HN_CG	13	EDGE_HN_CG_01	t	399502.98	2026-03-20 10:10:16.348805+00
110	EXP_REC_001	b	HN_CG	8	EDGE_HN_CG_01	f	0	2026-03-18 06:34:16.348805+00
111	EXP_REC_001	b	HCM_Q1	33	EDGE_HCM_Q1_01	f	0	2026-03-17 04:25:16.348805+00
112	EXP_REC_001	b	HCM_Q1	53	EDGE_HCM_Q1_01	f	0	2026-03-26 22:23:16.348805+00
113	EXP_REC_001	a	HCM_Q7	\N	EDGE_HCM_Q7_01	t	210511.3	2026-03-26 23:08:16.348805+00
114	EXP_REC_001	b	HCM_Q1	50	EDGE_HCM_Q1_01	t	60394.42	2026-03-22 23:54:16.348805+00
115	EXP_REC_001	a	HN_CG	\N	EDGE_HN_CG_01	f	0	2026-03-18 16:55:16.349825+00
116	EXP_REC_001	b	HCM_Q1	5	EDGE_HCM_Q1_01	t	201158.75	2026-03-14 09:54:16.349825+00
117	EXP_REC_001	a	HCM_Q7	22	EDGE_HCM_Q7_01	t	460361.85	2026-03-17 03:59:16.349825+00
118	EXP_REC_001	b	HCM_Q7	54	EDGE_HCM_Q7_01	f	0	2026-03-25 17:50:16.349825+00
119	EXP_REC_001	a	HN_CG	53	EDGE_HN_CG_01	f	0	2026-03-12 23:16:16.349825+00
120	EXP_REC_001	b	HCM_Q7	30	EDGE_HCM_Q7_01	t	361266.59	2026-03-23 14:25:16.349825+00
\.


--
-- Data for Name: ab_experiments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ab_experiments (id, experiment_id, experiment_name, variant_a, variant_b, split_ratio, target_branches, target_metric, status, start_date, end_date, created_at, updated_at) FROM stdin;
1	EXP_REC_001	Recommendation Ranking UI Test	{"model_version": "recommender_v1.0.0", "layout": "control"}	{"model_version": "recommender_v1.1.0", "layout": "carousel_v2"}	0.5	["HCM_Q1", "HCM_Q7", "HN_CG"]	ctr	running	2026-03-17 17:39:16.314947+00	2026-04-14 17:39:16.314947+00	2026-03-31 17:39:16.31863+00	2026-03-31 17:39:16.31863+00
\.


--
-- Data for Name: branch_inventory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.branch_inventory (id, branch_id, product_id, stock, reserved, updated_at) FROM stdin;
1	HCM_Q1	1	23	2	2026-03-31 17:38:51.667365
2	HCM_Q1	2	85	3	2026-03-31 17:38:51.667365
3	HCM_Q1	3	99	3	2026-03-31 17:38:51.667365
4	HCM_Q1	4	75	4	2026-03-31 17:38:51.667365
5	HCM_Q1	5	152	4	2026-03-31 17:38:51.667365
6	HCM_Q1	6	93	0	2026-03-31 17:38:51.667365
7	HCM_Q1	7	13	6	2026-03-31 17:38:51.667365
8	HCM_Q1	8	79	0	2026-03-31 17:38:51.667365
9	HCM_Q1	9	37	2	2026-03-31 17:38:51.667365
10	HCM_Q1	10	78	4	2026-03-31 17:38:51.667365
11	HCM_Q1	11	40	7	2026-03-31 17:38:51.667365
12	HCM_Q1	12	16	6	2026-03-31 17:38:51.667365
13	HCM_Q1	13	32	1	2026-03-31 17:38:51.667365
14	HCM_Q1	14	92	2	2026-03-31 17:38:51.667365
15	HCM_Q1	15	121	5	2026-03-31 17:38:51.667365
16	HCM_Q1	16	88	2	2026-03-31 17:38:51.667365
17	HCM_Q1	17	72	0	2026-03-31 17:38:51.667365
18	HCM_Q1	18	117	0	2026-03-31 17:38:51.667365
19	HCM_Q1	19	63	3	2026-03-31 17:38:51.667365
20	HCM_Q1	20	140	1	2026-03-31 17:38:51.667365
21	HCM_Q1	21	96	8	2026-03-31 17:38:51.667365
22	HCM_Q1	22	136	6	2026-03-31 17:38:51.667365
23	HCM_Q1	23	140	2	2026-03-31 17:38:51.667365
24	HCM_Q1	24	98	3	2026-03-31 17:38:51.667365
25	HCM_Q1	25	90	2	2026-03-31 17:38:51.667365
26	HCM_Q1	26	140	0	2026-03-31 17:38:51.667365
27	HCM_Q1	27	79	5	2026-03-31 17:38:51.667365
28	HCM_Q1	28	89	6	2026-03-31 17:38:51.667365
29	HCM_Q1	29	70	3	2026-03-31 17:38:51.667365
30	HCM_Q1	30	55	1	2026-03-31 17:38:51.667365
31	HCM_Q1	31	24	0	2026-03-31 17:38:51.667365
32	HCM_Q1	32	40	3	2026-03-31 17:38:51.667365
33	HCM_Q1	33	64	7	2026-03-31 17:38:51.667365
34	HCM_Q1	34	14	3	2026-03-31 17:38:51.667365
35	HCM_Q1	35	94	3	2026-03-31 17:38:51.667365
36	HCM_Q1	36	87	4	2026-03-31 17:38:51.667365
37	HCM_Q1	37	196	4	2026-03-31 17:38:51.667365
38	HCM_Q1	38	61	8	2026-03-31 17:38:51.667365
39	HCM_Q1	39	69	8	2026-03-31 17:38:51.667365
40	HCM_Q1	40	63	0	2026-03-31 17:38:51.667365
41	HCM_Q1	41	84	4	2026-03-31 17:38:51.667365
42	HCM_Q1	42	27	4	2026-03-31 17:38:51.667365
43	HCM_Q1	43	25	6	2026-03-31 17:38:51.667365
44	HCM_Q1	44	45	5	2026-03-31 17:38:51.667365
45	HCM_Q1	45	71	8	2026-03-31 17:38:51.667365
46	HCM_Q1	46	34	3	2026-03-31 17:38:51.667365
47	HCM_Q1	47	37	6	2026-03-31 17:38:51.667365
48	HCM_Q1	48	26	8	2026-03-31 17:38:51.667365
49	HCM_Q1	49	51	3	2026-03-31 17:38:51.667365
50	HCM_Q1	50	68	1	2026-03-31 17:38:51.667365
51	HCM_Q1	51	180	5	2026-03-31 17:38:51.667365
52	HCM_Q1	52	35	1	2026-03-31 17:38:51.667365
53	HCM_Q1	53	81	4	2026-03-31 17:38:51.667365
54	HCM_Q1	54	23	6	2026-03-31 17:38:51.667365
55	HCM_Q1	55	7	4	2026-03-31 17:38:51.667365
56	HCM_Q1	56	14	3	2026-03-31 17:38:51.667365
57	HCM_Q1	57	67	6	2026-03-31 17:38:51.667365
58	HCM_Q1	58	114	2	2026-03-31 17:38:51.667365
59	HCM_Q1	59	175	4	2026-03-31 17:38:51.667365
60	HCM_Q1	60	111	0	2026-03-31 17:38:51.667365
61	HCM_Q1	61	95	3	2026-03-31 17:38:51.667365
62	HCM_Q1	62	70	5	2026-03-31 17:38:51.667365
63	HCM_Q1	63	30	7	2026-03-31 17:38:51.667365
64	HCM_Q1	64	62	8	2026-03-31 17:38:51.667365
65	HCM_Q1	65	43	2	2026-03-31 17:38:51.667365
66	HCM_Q1	66	23	4	2026-03-31 17:38:51.667365
67	HCM_Q1	67	151	5	2026-03-31 17:38:51.667365
68	HCM_Q1	68	37	3	2026-03-31 17:38:51.667365
69	HCM_Q1	69	27	3	2026-03-31 17:38:51.667365
70	HCM_Q1	70	54	2	2026-03-31 17:38:51.667365
71	HCM_Q1	71	7	3	2026-03-31 17:38:51.667365
72	HCM_Q1	72	165	1	2026-03-31 17:38:51.667365
73	HCM_Q1	73	126	3	2026-03-31 17:38:51.667365
74	HCM_Q1	74	14	6	2026-03-31 17:38:51.667365
75	HCM_Q1	75	132	3	2026-03-31 17:38:51.667365
76	HCM_Q1	76	7	0	2026-03-31 17:38:51.667365
77	HCM_Q1	77	216	1	2026-03-31 17:38:51.667365
78	HCM_Q1	78	138	3	2026-03-31 17:38:51.667365
79	HCM_Q1	79	76	8	2026-03-31 17:38:51.667365
80	HCM_Q1	80	57	8	2026-03-31 17:38:51.667365
81	HCM_Q1	81	12	1	2026-03-31 17:38:51.667365
82	HCM_Q1	82	72	7	2026-03-31 17:38:51.667365
83	HCM_Q1	83	112	8	2026-03-31 17:38:51.667365
84	HCM_Q1	84	101	7	2026-03-31 17:38:51.667365
85	HCM_Q1	85	128	8	2026-03-31 17:38:51.667365
86	HCM_Q1	86	16	8	2026-03-31 17:38:51.667365
87	HCM_Q1	87	117	2	2026-03-31 17:38:51.667365
88	HCM_Q1	88	196	7	2026-03-31 17:38:51.667365
89	HCM_Q1	89	100	3	2026-03-31 17:38:51.667365
90	HCM_Q1	90	75	4	2026-03-31 17:38:51.667365
91	HCM_Q1	91	161	8	2026-03-31 17:38:51.667365
92	HCM_Q1	92	122	3	2026-03-31 17:38:51.667365
93	HCM_Q1	93	87	1	2026-03-31 17:38:51.667365
94	HCM_Q1	94	130	3	2026-03-31 17:38:51.667365
95	HCM_Q1	95	21	5	2026-03-31 17:38:51.667365
96	HCM_Q1	96	78	1	2026-03-31 17:38:51.667365
97	HCM_Q1	97	77	3	2026-03-31 17:38:51.667365
98	HCM_Q1	98	26	2	2026-03-31 17:38:51.668375
99	HCM_Q1	99	157	1	2026-03-31 17:38:51.668375
100	HCM_Q1	100	138	5	2026-03-31 17:38:51.668375
101	HCM_Q1	101	136	6	2026-03-31 17:38:51.668375
102	HCM_Q1	102	22	6	2026-03-31 17:38:51.668375
103	HCM_Q1	103	27	0	2026-03-31 17:38:51.668375
104	HCM_Q1	104	153	6	2026-03-31 17:38:51.668375
105	HCM_Q1	105	130	5	2026-03-31 17:38:51.668375
106	HCM_Q1	106	92	6	2026-03-31 17:38:51.668375
107	HCM_Q1	107	50	6	2026-03-31 17:38:51.668375
108	HCM_Q1	108	87	8	2026-03-31 17:38:51.668375
109	HCM_Q1	109	93	3	2026-03-31 17:38:51.668375
110	HCM_Q1	110	150	4	2026-03-31 17:38:51.668375
111	HCM_Q1	111	103	0	2026-03-31 17:38:51.668375
112	HCM_Q1	112	27	6	2026-03-31 17:38:51.668375
113	HCM_Q1	113	132	7	2026-03-31 17:38:51.668375
114	HCM_Q1	114	74	8	2026-03-31 17:38:51.668375
115	HCM_Q1	115	65	6	2026-03-31 17:38:51.668375
116	HCM_Q1	116	82	0	2026-03-31 17:38:51.668375
117	HCM_Q1	117	27	6	2026-03-31 17:38:51.668375
118	HCM_Q1	118	88	7	2026-03-31 17:38:51.668375
119	HCM_Q1	119	26	4	2026-03-31 17:38:51.668375
120	HCM_Q1	120	8	3	2026-03-31 17:38:51.668375
121	HCM_Q1	121	145	5	2026-03-31 17:38:51.668375
122	HCM_Q1	122	176	6	2026-03-31 17:38:51.668375
123	HCM_Q1	123	26	6	2026-03-31 17:38:51.668375
124	HCM_Q1	124	119	1	2026-03-31 17:38:51.668375
125	HCM_Q1	125	93	8	2026-03-31 17:38:51.668375
126	HCM_Q1	126	80	5	2026-03-31 17:38:51.668375
127	HCM_Q1	127	82	1	2026-03-31 17:38:51.668375
128	HCM_Q1	128	186	0	2026-03-31 17:38:51.668375
129	HCM_Q1	129	132	3	2026-03-31 17:38:51.668375
130	HCM_Q1	130	59	0	2026-03-31 17:38:51.668375
131	HCM_Q1	131	128	3	2026-03-31 17:38:51.668375
132	HCM_Q1	132	23	1	2026-03-31 17:38:51.668375
133	HCM_Q1	133	37	3	2026-03-31 17:38:51.668375
134	HCM_Q1	134	15	4	2026-03-31 17:38:51.668375
135	HCM_Q1	135	75	2	2026-03-31 17:38:51.668375
136	HCM_Q1	136	157	1	2026-03-31 17:38:51.668375
137	HCM_Q1	137	139	2	2026-03-31 17:38:51.668375
138	HCM_Q1	138	25	1	2026-03-31 17:38:51.668375
139	HCM_Q1	139	77	4	2026-03-31 17:38:51.668375
140	HCM_Q1	140	93	6	2026-03-31 17:38:51.668375
141	HCM_Q1	141	98	3	2026-03-31 17:38:51.668375
142	HCM_Q1	142	46	3	2026-03-31 17:38:51.668375
143	HCM_Q1	143	16	4	2026-03-31 17:38:51.668375
144	HCM_Q1	144	104	1	2026-03-31 17:38:51.668375
145	HCM_Q1	145	176	0	2026-03-31 17:38:51.668375
146	HCM_Q1	146	33	6	2026-03-31 17:38:51.668375
147	HCM_Q1	147	121	1	2026-03-31 17:38:51.668375
148	HCM_Q1	148	108	5	2026-03-31 17:38:51.668375
149	HCM_Q1	149	5	3	2026-03-31 17:38:51.668375
150	HCM_Q1	150	180	1	2026-03-31 17:38:51.668375
151	HCM_Q1	151	17	5	2026-03-31 17:38:51.668375
152	HCM_Q1	152	59	7	2026-03-31 17:38:51.668375
153	HCM_Q1	153	83	6	2026-03-31 17:38:51.668375
154	HCM_Q1	154	26	8	2026-03-31 17:38:51.668375
155	HCM_Q1	155	64	4	2026-03-31 17:38:51.668375
156	HCM_Q1	156	65	8	2026-03-31 17:38:51.668375
157	HCM_Q1	157	88	7	2026-03-31 17:38:51.668375
158	HCM_Q1	158	38	4	2026-03-31 17:38:51.668375
159	HCM_Q1	159	17	3	2026-03-31 17:38:51.668375
160	HCM_Q1	160	55	1	2026-03-31 17:38:51.668375
161	HCM_Q1	161	124	7	2026-03-31 17:38:51.668375
162	HCM_Q1	162	18	7	2026-03-31 17:38:51.668375
163	HCM_Q1	163	156	6	2026-03-31 17:38:51.668375
164	HCM_Q1	164	54	7	2026-03-31 17:38:51.668375
165	HCM_Q1	165	18	2	2026-03-31 17:38:51.668375
166	HCM_Q1	166	107	5	2026-03-31 17:38:51.668375
167	HCM_Q1	167	25	5	2026-03-31 17:38:51.668375
168	HCM_Q1	168	9	4	2026-03-31 17:38:51.668375
169	HCM_Q1	169	167	8	2026-03-31 17:38:51.668375
170	HCM_Q1	170	111	1	2026-03-31 17:38:51.668375
171	HCM_Q1	171	13	6	2026-03-31 17:38:51.668375
172	HCM_Q1	172	72	3	2026-03-31 17:38:51.668375
173	HCM_Q1	173	29	7	2026-03-31 17:38:51.668375
174	HCM_Q1	174	59	0	2026-03-31 17:38:51.668375
175	HCM_Q1	175	35	3	2026-03-31 17:38:51.668375
176	HCM_Q1	176	133	3	2026-03-31 17:38:51.668375
177	HCM_Q1	177	66	5	2026-03-31 17:38:51.668375
178	HCM_Q1	178	17	8	2026-03-31 17:38:51.668375
179	HCM_Q1	179	15	8	2026-03-31 17:38:51.668375
180	HCM_Q1	180	102	7	2026-03-31 17:38:51.668375
181	HCM_Q1	181	99	4	2026-03-31 17:38:51.668375
182	HCM_Q1	182	37	3	2026-03-31 17:38:51.668375
183	HCM_Q1	183	121	8	2026-03-31 17:38:51.668375
184	HCM_Q1	184	88	2	2026-03-31 17:38:51.668375
185	HCM_Q1	185	34	7	2026-03-31 17:38:51.668375
186	HCM_Q1	186	24	8	2026-03-31 17:38:51.668375
187	HCM_Q1	187	148	1	2026-03-31 17:38:51.668375
188	HCM_Q1	188	157	4	2026-03-31 17:38:51.668375
189	HCM_Q1	189	51	2	2026-03-31 17:38:51.668375
190	HCM_Q1	190	8	8	2026-03-31 17:38:51.668375
191	HCM_Q1	191	22	0	2026-03-31 17:38:51.668375
192	HCM_Q1	192	120	8	2026-03-31 17:38:51.668375
193	HCM_Q1	193	17	2	2026-03-31 17:38:51.668375
194	HCM_Q1	194	146	7	2026-03-31 17:38:51.668375
195	HCM_Q1	195	70	0	2026-03-31 17:38:51.668375
196	HCM_Q1	196	141	7	2026-03-31 17:38:51.668375
197	HCM_Q1	197	140	5	2026-03-31 17:38:51.668375
198	HCM_Q1	198	8	0	2026-03-31 17:38:51.668375
199	HCM_Q1	199	62	7	2026-03-31 17:38:51.668375
200	HCM_Q1	200	97	1	2026-03-31 17:38:51.668375
201	HCM_Q1	201	87	1	2026-03-31 17:38:51.668375
202	HCM_Q1	202	10	0	2026-03-31 17:38:51.668375
203	HCM_Q1	203	45	4	2026-03-31 17:38:51.668375
204	HCM_Q1	204	11	3	2026-03-31 17:38:51.668375
205	HCM_Q1	205	8	6	2026-03-31 17:38:51.668375
206	HCM_Q7	1	21	3	2026-03-31 17:38:51.668375
207	HCM_Q7	2	141	6	2026-03-31 17:38:51.668375
208	HCM_Q7	3	77	7	2026-03-31 17:38:51.668375
209	HCM_Q7	4	50	6	2026-03-31 17:38:51.668375
210	HCM_Q7	5	121	0	2026-03-31 17:38:51.668375
211	HCM_Q7	6	73	1	2026-03-31 17:38:51.668375
212	HCM_Q7	7	33	3	2026-03-31 17:38:51.668375
213	HCM_Q7	8	67	4	2026-03-31 17:38:51.668375
214	HCM_Q7	9	85	2	2026-03-31 17:38:51.668375
215	HCM_Q7	10	50	8	2026-03-31 17:38:51.668375
216	HCM_Q7	11	35	0	2026-03-31 17:38:51.668375
217	HCM_Q7	12	14	7	2026-03-31 17:38:51.668375
218	HCM_Q7	13	24	3	2026-03-31 17:38:51.668375
219	HCM_Q7	14	126	4	2026-03-31 17:38:51.668375
220	HCM_Q7	15	139	7	2026-03-31 17:38:51.668375
221	HCM_Q7	16	46	3	2026-03-31 17:38:51.668375
222	HCM_Q7	17	111	3	2026-03-31 17:38:51.668375
223	HCM_Q7	18	134	8	2026-03-31 17:38:51.668375
224	HCM_Q7	19	33	2	2026-03-31 17:38:51.668375
225	HCM_Q7	20	167	2	2026-03-31 17:38:51.668375
226	HCM_Q7	21	64	2	2026-03-31 17:38:51.668375
227	HCM_Q7	22	127	4	2026-03-31 17:38:51.668375
228	HCM_Q7	23	89	7	2026-03-31 17:38:51.668375
229	HCM_Q7	24	81	6	2026-03-31 17:38:51.668375
230	HCM_Q7	25	95	8	2026-03-31 17:38:51.668375
231	HCM_Q7	26	105	7	2026-03-31 17:38:51.668375
232	HCM_Q7	27	67	0	2026-03-31 17:38:51.668375
233	HCM_Q7	28	96	5	2026-03-31 17:38:51.668375
234	HCM_Q7	29	60	0	2026-03-31 17:38:51.668375
235	HCM_Q7	30	42	0	2026-03-31 17:38:51.668375
236	HCM_Q7	31	41	4	2026-03-31 17:38:51.668375
237	HCM_Q7	32	31	2	2026-03-31 17:38:51.668375
238	HCM_Q7	33	90	7	2026-03-31 17:38:51.668375
239	HCM_Q7	34	23	2	2026-03-31 17:38:51.668375
240	HCM_Q7	35	196	6	2026-03-31 17:38:51.668375
241	HCM_Q7	36	110	7	2026-03-31 17:38:51.668375
242	HCM_Q7	37	211	7	2026-03-31 17:38:51.668375
243	HCM_Q7	38	61	5	2026-03-31 17:38:51.668375
244	HCM_Q7	39	63	1	2026-03-31 17:38:51.668375
245	HCM_Q7	40	104	5	2026-03-31 17:38:51.668375
246	HCM_Q7	41	124	7	2026-03-31 17:38:51.668375
247	HCM_Q7	42	32	6	2026-03-31 17:38:51.668375
248	HCM_Q7	43	62	8	2026-03-31 17:38:51.668375
249	HCM_Q7	44	28	1	2026-03-31 17:38:51.668375
250	HCM_Q7	45	62	5	2026-03-31 17:38:51.668375
251	HCM_Q7	46	34	6	2026-03-31 17:38:51.668375
252	HCM_Q7	47	67	0	2026-03-31 17:38:51.668375
253	HCM_Q7	48	62	8	2026-03-31 17:38:51.668375
254	HCM_Q7	49	41	0	2026-03-31 17:38:51.668375
255	HCM_Q7	50	54	5	2026-03-31 17:38:51.668375
256	HCM_Q7	51	140	7	2026-03-31 17:38:51.668375
257	HCM_Q7	52	36	0	2026-03-31 17:38:51.668375
258	HCM_Q7	53	47	8	2026-03-31 17:38:51.668375
259	HCM_Q7	54	14	4	2026-03-31 17:38:51.668375
260	HCM_Q7	55	9	7	2026-03-31 17:38:51.668375
261	HCM_Q7	56	8	3	2026-03-31 17:38:51.668375
262	HCM_Q7	57	89	4	2026-03-31 17:38:51.668375
263	HCM_Q7	58	102	8	2026-03-31 17:38:51.668375
264	HCM_Q7	59	143	3	2026-03-31 17:38:51.668375
265	HCM_Q7	60	183	1	2026-03-31 17:38:51.668375
266	HCM_Q7	61	114	1	2026-03-31 17:38:51.668375
267	HCM_Q7	62	87	2	2026-03-31 17:38:51.668375
268	HCM_Q7	63	31	4	2026-03-31 17:38:51.668375
269	HCM_Q7	64	53	4	2026-03-31 17:38:51.668375
270	HCM_Q7	65	41	7	2026-03-31 17:38:51.668375
271	HCM_Q7	66	29	3	2026-03-31 17:38:51.668375
272	HCM_Q7	67	142	2	2026-03-31 17:38:51.668375
273	HCM_Q7	68	56	8	2026-03-31 17:38:51.668375
274	HCM_Q7	69	28	2	2026-03-31 17:38:51.668375
275	HCM_Q7	70	56	4	2026-03-31 17:38:51.668375
276	HCM_Q7	71	18	6	2026-03-31 17:38:51.668375
277	HCM_Q7	72	93	8	2026-03-31 17:38:51.668375
278	HCM_Q7	73	101	0	2026-03-31 17:38:51.668375
279	HCM_Q7	74	9	4	2026-03-31 17:38:51.668375
280	HCM_Q7	75	178	7	2026-03-31 17:38:51.668375
281	HCM_Q7	76	15	7	2026-03-31 17:38:51.668375
282	HCM_Q7	77	161	5	2026-03-31 17:38:51.668375
283	HCM_Q7	78	89	8	2026-03-31 17:38:51.668375
284	HCM_Q7	79	98	5	2026-03-31 17:38:51.668375
285	HCM_Q7	80	81	3	2026-03-31 17:38:51.668375
286	HCM_Q7	81	18	3	2026-03-31 17:38:51.668375
287	HCM_Q7	82	103	6	2026-03-31 17:38:51.668375
288	HCM_Q7	83	52	7	2026-03-31 17:38:51.668375
289	HCM_Q7	84	111	6	2026-03-31 17:38:51.668375
290	HCM_Q7	85	102	2	2026-03-31 17:38:51.668375
291	HCM_Q7	86	17	0	2026-03-31 17:38:51.668375
292	HCM_Q7	87	77	5	2026-03-31 17:38:51.668375
293	HCM_Q7	88	215	7	2026-03-31 17:38:51.668375
294	HCM_Q7	89	63	7	2026-03-31 17:38:51.668375
295	HCM_Q7	90	28	2	2026-03-31 17:38:51.668375
296	HCM_Q7	91	115	2	2026-03-31 17:38:51.668375
297	HCM_Q7	92	71	4	2026-03-31 17:38:51.668375
298	HCM_Q7	93	94	6	2026-03-31 17:38:51.668375
299	HCM_Q7	94	123	5	2026-03-31 17:38:51.668375
300	HCM_Q7	95	37	8	2026-03-31 17:38:51.668375
301	HCM_Q7	96	49	5	2026-03-31 17:38:51.668375
302	HCM_Q7	97	137	7	2026-03-31 17:38:51.668375
303	HCM_Q7	98	40	0	2026-03-31 17:38:51.668375
304	HCM_Q7	99	145	3	2026-03-31 17:38:51.668375
305	HCM_Q7	100	171	4	2026-03-31 17:38:51.668375
306	HCM_Q7	101	196	1	2026-03-31 17:38:51.668375
307	HCM_Q7	102	38	1	2026-03-31 17:38:51.668375
308	HCM_Q7	103	38	1	2026-03-31 17:38:51.668375
309	HCM_Q7	104	106	4	2026-03-31 17:38:51.668375
310	HCM_Q7	105	187	0	2026-03-31 17:38:51.668375
311	HCM_Q7	106	95	0	2026-03-31 17:38:51.668375
312	HCM_Q7	107	29	5	2026-03-31 17:38:51.668375
313	HCM_Q7	108	78	3	2026-03-31 17:38:51.668375
314	HCM_Q7	109	74	2	2026-03-31 17:38:51.668375
315	HCM_Q7	110	101	1	2026-03-31 17:38:51.668375
316	HCM_Q7	111	122	6	2026-03-31 17:38:51.668375
317	HCM_Q7	112	34	3	2026-03-31 17:38:51.668375
318	HCM_Q7	113	107	2	2026-03-31 17:38:51.668375
319	HCM_Q7	114	38	4	2026-03-31 17:38:51.668375
320	HCM_Q7	115	119	0	2026-03-31 17:38:51.668375
321	HCM_Q7	116	105	7	2026-03-31 17:38:51.668375
322	HCM_Q7	117	65	8	2026-03-31 17:38:51.668375
323	HCM_Q7	118	92	7	2026-03-31 17:38:51.668375
324	HCM_Q7	119	55	4	2026-03-31 17:38:51.668375
325	HCM_Q7	120	10	6	2026-03-31 17:38:51.668375
326	HCM_Q7	121	180	7	2026-03-31 17:38:51.668375
327	HCM_Q7	122	188	3	2026-03-31 17:38:51.668375
328	HCM_Q7	123	51	7	2026-03-31 17:38:51.668375
329	HCM_Q7	124	96	6	2026-03-31 17:38:51.668375
330	HCM_Q7	125	103	4	2026-03-31 17:38:51.668375
331	HCM_Q7	126	217	4	2026-03-31 17:38:51.668375
332	HCM_Q7	127	59	6	2026-03-31 17:38:51.668375
333	HCM_Q7	128	112	0	2026-03-31 17:38:51.668375
334	HCM_Q7	129	148	7	2026-03-31 17:38:51.668375
335	HCM_Q7	130	113	4	2026-03-31 17:38:51.668375
336	HCM_Q7	131	145	3	2026-03-31 17:38:51.668375
337	HCM_Q7	132	40	5	2026-03-31 17:38:51.668375
338	HCM_Q7	133	25	3	2026-03-31 17:38:51.668375
339	HCM_Q7	134	17	2	2026-03-31 17:38:51.668375
340	HCM_Q7	135	66	0	2026-03-31 17:38:51.668375
341	HCM_Q7	136	115	7	2026-03-31 17:38:51.668375
342	HCM_Q7	137	58	5	2026-03-31 17:38:51.668375
343	HCM_Q7	138	21	1	2026-03-31 17:38:51.668375
344	HCM_Q7	139	101	5	2026-03-31 17:38:51.668375
345	HCM_Q7	140	108	2	2026-03-31 17:38:51.668375
346	HCM_Q7	141	76	8	2026-03-31 17:38:51.668375
347	HCM_Q7	142	111	5	2026-03-31 17:38:51.668375
348	HCM_Q7	143	28	4	2026-03-31 17:38:51.668375
349	HCM_Q7	144	103	4	2026-03-31 17:38:51.668375
350	HCM_Q7	145	192	7	2026-03-31 17:38:51.668375
351	HCM_Q7	146	58	4	2026-03-31 17:38:51.668375
352	HCM_Q7	147	130	5	2026-03-31 17:38:51.668375
353	HCM_Q7	148	140	7	2026-03-31 17:38:51.668375
354	HCM_Q7	149	15	2	2026-03-31 17:38:51.668375
355	HCM_Q7	150	171	3	2026-03-31 17:38:51.668375
356	HCM_Q7	151	26	6	2026-03-31 17:38:51.668375
357	HCM_Q7	152	76	8	2026-03-31 17:38:51.668375
358	HCM_Q7	153	59	6	2026-03-31 17:38:51.668375
359	HCM_Q7	154	20	8	2026-03-31 17:38:51.668375
360	HCM_Q7	155	27	5	2026-03-31 17:38:51.668375
361	HCM_Q7	156	68	4	2026-03-31 17:38:51.668375
362	HCM_Q7	157	75	5	2026-03-31 17:38:51.668375
363	HCM_Q7	158	25	3	2026-03-31 17:38:51.668375
364	HCM_Q7	159	20	8	2026-03-31 17:38:51.668375
365	HCM_Q7	160	34	3	2026-03-31 17:38:51.668375
366	HCM_Q7	161	183	7	2026-03-31 17:38:51.668375
367	HCM_Q7	162	34	4	2026-03-31 17:38:51.668375
368	HCM_Q7	163	168	1	2026-03-31 17:38:51.668375
369	HCM_Q7	164	41	0	2026-03-31 17:38:51.668375
370	HCM_Q7	165	10	7	2026-03-31 17:38:51.668375
371	HCM_Q7	166	67	3	2026-03-31 17:38:51.668375
372	HCM_Q7	167	27	2	2026-03-31 17:38:51.668375
373	HCM_Q7	168	11	5	2026-03-31 17:38:51.668375
374	HCM_Q7	169	185	8	2026-03-31 17:38:51.668375
375	HCM_Q7	170	70	2	2026-03-31 17:38:51.668375
376	HCM_Q7	171	25	1	2026-03-31 17:38:51.668375
377	HCM_Q7	172	98	6	2026-03-31 17:38:51.668375
378	HCM_Q7	173	35	4	2026-03-31 17:38:51.668375
379	HCM_Q7	174	33	5	2026-03-31 17:38:51.668375
380	HCM_Q7	175	43	7	2026-03-31 17:38:51.668375
381	HCM_Q7	176	213	5	2026-03-31 17:38:51.668375
382	HCM_Q7	177	49	5	2026-03-31 17:38:51.668375
383	HCM_Q7	178	18	5	2026-03-31 17:38:51.668375
384	HCM_Q7	179	10	4	2026-03-31 17:38:51.668375
385	HCM_Q7	180	84	1	2026-03-31 17:38:51.668375
386	HCM_Q7	181	187	7	2026-03-31 17:38:51.668375
387	HCM_Q7	182	30	3	2026-03-31 17:38:51.668375
388	HCM_Q7	183	169	0	2026-03-31 17:38:51.668375
389	HCM_Q7	184	33	5	2026-03-31 17:38:51.668375
390	HCM_Q7	185	36	2	2026-03-31 17:38:51.668375
391	HCM_Q7	186	41	3	2026-03-31 17:38:51.668375
392	HCM_Q7	187	76	8	2026-03-31 17:38:51.668375
393	HCM_Q7	188	83	3	2026-03-31 17:38:51.668375
394	HCM_Q7	189	93	3	2026-03-31 17:38:51.668375
395	HCM_Q7	190	8	2	2026-03-31 17:38:51.668375
396	HCM_Q7	191	45	0	2026-03-31 17:38:51.668375
397	HCM_Q7	192	63	2	2026-03-31 17:38:51.668375
398	HCM_Q7	193	33	8	2026-03-31 17:38:51.669375
399	HCM_Q7	194	96	2	2026-03-31 17:38:51.669375
400	HCM_Q7	195	71	0	2026-03-31 17:38:51.669375
401	HCM_Q7	196	83	5	2026-03-31 17:38:51.669375
402	HCM_Q7	197	184	3	2026-03-31 17:38:51.669375
403	HCM_Q7	198	13	0	2026-03-31 17:38:51.669375
404	HCM_Q7	199	56	0	2026-03-31 17:38:51.669375
405	HCM_Q7	200	99	6	2026-03-31 17:38:51.669375
406	HCM_Q7	201	100	1	2026-03-31 17:38:51.669375
407	HCM_Q7	202	9	5	2026-03-31 17:38:51.669375
408	HCM_Q7	203	70	1	2026-03-31 17:38:51.669375
409	HCM_Q7	204	19	3	2026-03-31 17:38:51.669375
410	HCM_Q7	205	19	0	2026-03-31 17:38:51.669375
411	HN_CG	1	23	8	2026-03-31 17:38:51.669375
412	HN_CG	2	89	0	2026-03-31 17:38:51.669375
413	HN_CG	3	45	7	2026-03-31 17:38:51.669375
414	HN_CG	4	85	6	2026-03-31 17:38:51.669375
415	HN_CG	5	179	7	2026-03-31 17:38:51.669375
416	HN_CG	6	80	7	2026-03-31 17:38:51.669375
417	HN_CG	7	13	1	2026-03-31 17:38:51.669375
418	HN_CG	8	49	2	2026-03-31 17:38:51.669375
419	HN_CG	9	41	4	2026-03-31 17:38:51.669375
420	HN_CG	10	77	8	2026-03-31 17:38:51.669375
421	HN_CG	11	74	6	2026-03-31 17:38:51.669375
422	HN_CG	12	23	8	2026-03-31 17:38:51.669375
423	HN_CG	13	24	8	2026-03-31 17:38:51.669375
424	HN_CG	14	176	1	2026-03-31 17:38:51.669375
425	HN_CG	15	149	1	2026-03-31 17:38:51.669375
426	HN_CG	16	110	8	2026-03-31 17:38:51.669375
427	HN_CG	17	95	3	2026-03-31 17:38:51.669375
428	HN_CG	18	135	3	2026-03-31 17:38:51.669375
429	HN_CG	19	41	7	2026-03-31 17:38:51.669375
430	HN_CG	20	107	1	2026-03-31 17:38:51.669375
431	HN_CG	21	92	5	2026-03-31 17:38:51.669375
432	HN_CG	22	114	5	2026-03-31 17:38:51.669375
433	HN_CG	23	138	7	2026-03-31 17:38:51.669375
434	HN_CG	24	39	1	2026-03-31 17:38:51.669375
435	HN_CG	25	39	1	2026-03-31 17:38:51.669375
436	HN_CG	26	126	5	2026-03-31 17:38:51.669375
437	HN_CG	27	153	8	2026-03-31 17:38:51.669375
438	HN_CG	28	38	8	2026-03-31 17:38:51.669375
439	HN_CG	29	57	1	2026-03-31 17:38:51.669375
440	HN_CG	30	65	6	2026-03-31 17:38:51.669375
441	HN_CG	31	38	0	2026-03-31 17:38:51.669375
442	HN_CG	32	43	4	2026-03-31 17:38:51.669375
443	HN_CG	33	79	8	2026-03-31 17:38:51.669375
444	HN_CG	34	11	7	2026-03-31 17:38:51.669375
445	HN_CG	35	95	1	2026-03-31 17:38:51.669375
446	HN_CG	36	82	8	2026-03-31 17:38:51.669375
447	HN_CG	37	124	4	2026-03-31 17:38:51.669375
448	HN_CG	38	77	6	2026-03-31 17:38:51.669375
449	HN_CG	39	103	8	2026-03-31 17:38:51.669375
450	HN_CG	40	40	4	2026-03-31 17:38:51.669375
451	HN_CG	41	72	4	2026-03-31 17:38:51.669375
452	HN_CG	42	49	4	2026-03-31 17:38:51.669375
453	HN_CG	43	67	5	2026-03-31 17:38:51.669375
454	HN_CG	44	27	2	2026-03-31 17:38:51.669375
455	HN_CG	45	81	6	2026-03-31 17:38:51.669375
456	HN_CG	46	31	0	2026-03-31 17:38:51.669375
457	HN_CG	47	29	8	2026-03-31 17:38:51.669375
458	HN_CG	48	38	6	2026-03-31 17:38:51.669375
459	HN_CG	49	41	2	2026-03-31 17:38:51.669375
460	HN_CG	50	68	5	2026-03-31 17:38:51.669375
461	HN_CG	51	159	1	2026-03-31 17:38:51.669375
462	HN_CG	52	44	2	2026-03-31 17:38:51.669375
463	HN_CG	53	44	0	2026-03-31 17:38:51.669375
464	HN_CG	54	27	4	2026-03-31 17:38:51.669375
465	HN_CG	55	9	6	2026-03-31 17:38:51.669375
466	HN_CG	56	13	7	2026-03-31 17:38:51.669375
467	HN_CG	57	67	3	2026-03-31 17:38:51.669375
468	HN_CG	58	122	1	2026-03-31 17:38:51.669375
469	HN_CG	59	133	1	2026-03-31 17:38:51.669375
470	HN_CG	60	96	7	2026-03-31 17:38:51.669375
471	HN_CG	61	122	4	2026-03-31 17:38:51.669375
472	HN_CG	62	41	6	2026-03-31 17:38:51.669375
473	HN_CG	63	46	0	2026-03-31 17:38:51.669375
474	HN_CG	64	26	4	2026-03-31 17:38:51.669375
475	HN_CG	65	64	2	2026-03-31 17:38:51.669375
476	HN_CG	66	25	4	2026-03-31 17:38:51.669375
477	HN_CG	67	123	0	2026-03-31 17:38:51.669375
478	HN_CG	68	63	6	2026-03-31 17:38:51.669375
479	HN_CG	69	15	6	2026-03-31 17:38:51.669375
480	HN_CG	70	42	3	2026-03-31 17:38:51.669375
481	HN_CG	71	14	5	2026-03-31 17:38:51.669375
482	HN_CG	72	63	0	2026-03-31 17:38:51.669375
483	HN_CG	73	124	7	2026-03-31 17:38:51.669375
484	HN_CG	74	17	5	2026-03-31 17:38:51.669375
485	HN_CG	75	143	6	2026-03-31 17:38:51.669375
486	HN_CG	76	13	6	2026-03-31 17:38:51.669375
487	HN_CG	77	122	6	2026-03-31 17:38:51.669375
488	HN_CG	78	56	5	2026-03-31 17:38:51.669375
489	HN_CG	79	75	7	2026-03-31 17:38:51.669375
490	HN_CG	80	78	5	2026-03-31 17:38:51.669375
491	HN_CG	81	9	1	2026-03-31 17:38:51.669375
492	HN_CG	82	56	6	2026-03-31 17:38:51.669375
493	HN_CG	83	98	6	2026-03-31 17:38:51.669375
494	HN_CG	84	127	5	2026-03-31 17:38:51.669375
495	HN_CG	85	83	2	2026-03-31 17:38:51.669375
496	HN_CG	86	10	1	2026-03-31 17:38:51.669375
497	HN_CG	87	127	3	2026-03-31 17:38:51.669375
498	HN_CG	88	221	5	2026-03-31 17:38:51.669375
499	HN_CG	89	89	2	2026-03-31 17:38:51.669375
500	HN_CG	90	41	2	2026-03-31 17:38:51.669375
501	HN_CG	91	96	2	2026-03-31 17:38:51.669375
502	HN_CG	92	137	1	2026-03-31 17:38:51.669375
503	HN_CG	93	76	7	2026-03-31 17:38:51.669375
504	HN_CG	94	103	7	2026-03-31 17:38:51.669375
505	HN_CG	95	33	5	2026-03-31 17:38:51.669375
506	HN_CG	96	76	5	2026-03-31 17:38:51.669375
507	HN_CG	97	79	1	2026-03-31 17:38:51.669375
508	HN_CG	98	28	4	2026-03-31 17:38:51.669375
509	HN_CG	99	169	0	2026-03-31 17:38:51.669375
510	HN_CG	100	128	1	2026-03-31 17:38:51.669375
511	HN_CG	101	106	7	2026-03-31 17:38:51.669375
512	HN_CG	102	21	5	2026-03-31 17:38:51.669375
513	HN_CG	103	40	1	2026-03-31 17:38:51.669375
514	HN_CG	104	129	1	2026-03-31 17:38:51.669375
515	HN_CG	105	148	8	2026-03-31 17:38:51.669375
516	HN_CG	106	102	8	2026-03-31 17:38:51.669375
517	HN_CG	107	54	0	2026-03-31 17:38:51.669375
518	HN_CG	108	79	3	2026-03-31 17:38:51.669375
519	HN_CG	109	59	7	2026-03-31 17:38:51.669375
520	HN_CG	110	152	0	2026-03-31 17:38:51.669375
521	HN_CG	111	104	5	2026-03-31 17:38:51.669375
522	HN_CG	112	45	1	2026-03-31 17:38:51.669375
523	HN_CG	113	108	2	2026-03-31 17:38:51.669375
524	HN_CG	114	28	7	2026-03-31 17:38:51.669375
525	HN_CG	115	186	8	2026-03-31 17:38:51.669375
526	HN_CG	116	76	2	2026-03-31 17:38:51.669375
527	HN_CG	117	40	4	2026-03-31 17:38:51.669375
528	HN_CG	118	124	5	2026-03-31 17:38:51.669375
529	HN_CG	119	45	0	2026-03-31 17:38:51.669375
530	HN_CG	120	12	5	2026-03-31 17:38:51.669375
531	HN_CG	121	86	1	2026-03-31 17:38:51.669375
532	HN_CG	122	148	6	2026-03-31 17:38:51.669375
533	HN_CG	123	26	2	2026-03-31 17:38:51.669375
534	HN_CG	124	132	2	2026-03-31 17:38:51.669375
535	HN_CG	125	137	4	2026-03-31 17:38:51.669375
536	HN_CG	126	213	6	2026-03-31 17:38:51.669375
537	HN_CG	127	71	1	2026-03-31 17:38:51.669375
538	HN_CG	128	117	6	2026-03-31 17:38:51.669375
539	HN_CG	129	120	5	2026-03-31 17:38:51.669375
540	HN_CG	130	111	8	2026-03-31 17:38:51.669375
541	HN_CG	131	67	6	2026-03-31 17:38:51.669375
542	HN_CG	132	37	0	2026-03-31 17:38:51.669375
543	HN_CG	133	30	2	2026-03-31 17:38:51.669375
544	HN_CG	134	23	5	2026-03-31 17:38:51.669375
545	HN_CG	135	85	7	2026-03-31 17:38:51.669375
546	HN_CG	136	98	2	2026-03-31 17:38:51.669375
547	HN_CG	137	71	4	2026-03-31 17:38:51.669375
548	HN_CG	138	23	1	2026-03-31 17:38:51.669375
549	HN_CG	139	72	8	2026-03-31 17:38:51.669375
550	HN_CG	140	116	8	2026-03-31 17:38:51.669375
551	HN_CG	141	58	5	2026-03-31 17:38:51.669375
552	HN_CG	142	111	2	2026-03-31 17:38:51.669375
553	HN_CG	143	30	2	2026-03-31 17:38:51.669375
554	HN_CG	144	51	2	2026-03-31 17:38:51.669375
555	HN_CG	145	166	0	2026-03-31 17:38:51.669375
556	HN_CG	146	36	3	2026-03-31 17:38:51.669375
557	HN_CG	147	154	4	2026-03-31 17:38:51.669375
558	HN_CG	148	135	7	2026-03-31 17:38:51.669375
559	HN_CG	149	7	3	2026-03-31 17:38:51.669375
560	HN_CG	150	110	7	2026-03-31 17:38:51.669375
561	HN_CG	151	26	3	2026-03-31 17:38:51.669375
562	HN_CG	152	45	7	2026-03-31 17:38:51.669375
563	HN_CG	153	66	4	2026-03-31 17:38:51.669375
564	HN_CG	154	50	8	2026-03-31 17:38:51.669375
565	HN_CG	155	45	2	2026-03-31 17:38:51.669375
566	HN_CG	156	76	2	2026-03-31 17:38:51.669375
567	HN_CG	157	95	0	2026-03-31 17:38:51.669375
568	HN_CG	158	47	5	2026-03-31 17:38:51.669375
569	HN_CG	159	21	1	2026-03-31 17:38:51.669375
570	HN_CG	160	50	8	2026-03-31 17:38:51.669375
571	HN_CG	161	216	4	2026-03-31 17:38:51.669375
572	HN_CG	162	14	2	2026-03-31 17:38:51.669375
573	HN_CG	163	113	8	2026-03-31 17:38:51.669375
574	HN_CG	164	42	6	2026-03-31 17:38:51.669375
575	HN_CG	165	8	3	2026-03-31 17:38:51.669375
576	HN_CG	166	143	5	2026-03-31 17:38:51.669375
577	HN_CG	167	28	6	2026-03-31 17:38:51.669375
578	HN_CG	168	7	5	2026-03-31 17:38:51.669375
579	HN_CG	169	116	1	2026-03-31 17:38:51.669375
580	HN_CG	170	67	0	2026-03-31 17:38:51.669375
581	HN_CG	171	15	1	2026-03-31 17:38:51.669375
582	HN_CG	172	98	5	2026-03-31 17:38:51.669375
583	HN_CG	173	32	2	2026-03-31 17:38:51.669375
584	HN_CG	174	34	7	2026-03-31 17:38:51.669375
585	HN_CG	175	71	2	2026-03-31 17:38:51.669375
586	HN_CG	176	185	7	2026-03-31 17:38:51.669375
587	HN_CG	177	78	0	2026-03-31 17:38:51.669375
588	HN_CG	178	24	0	2026-03-31 17:38:51.669375
589	HN_CG	179	13	2	2026-03-31 17:38:51.669375
590	HN_CG	180	129	8	2026-03-31 17:38:51.669375
591	HN_CG	181	119	4	2026-03-31 17:38:51.669375
592	HN_CG	182	37	1	2026-03-31 17:38:51.669375
593	HN_CG	183	81	6	2026-03-31 17:38:51.669375
594	HN_CG	184	69	7	2026-03-31 17:38:51.669375
595	HN_CG	185	27	7	2026-03-31 17:38:51.669375
596	HN_CG	186	35	0	2026-03-31 17:38:51.669375
597	HN_CG	187	153	3	2026-03-31 17:38:51.669375
598	HN_CG	188	144	4	2026-03-31 17:38:51.669375
599	HN_CG	189	66	5	2026-03-31 17:38:51.669375
600	HN_CG	190	7	6	2026-03-31 17:38:51.669375
601	HN_CG	191	24	1	2026-03-31 17:38:51.669375
602	HN_CG	192	83	5	2026-03-31 17:38:51.669375
603	HN_CG	193	12	8	2026-03-31 17:38:51.669375
604	HN_CG	194	134	8	2026-03-31 17:38:51.669375
605	HN_CG	195	123	6	2026-03-31 17:38:51.669375
606	HN_CG	196	181	0	2026-03-31 17:38:51.669375
607	HN_CG	197	162	5	2026-03-31 17:38:51.669375
608	HN_CG	198	9	0	2026-03-31 17:38:51.669375
609	HN_CG	199	71	1	2026-03-31 17:38:51.669375
610	HN_CG	200	133	1	2026-03-31 17:38:51.669375
611	HN_CG	201	124	5	2026-03-31 17:38:51.669375
612	HN_CG	202	6	2	2026-03-31 17:38:51.669375
613	HN_CG	203	72	2	2026-03-31 17:38:51.669375
614	HN_CG	204	26	7	2026-03-31 17:38:51.669375
615	HN_CG	205	20	7	2026-03-31 17:38:51.669375
\.


--
-- Data for Name: branch_metrics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.branch_metrics (id, branch_id, date, total_transactions, total_revenue, avg_transaction_value, total_recommendations, recommendations_accepted, acceptance_rate, avg_latency_ms, inference_count, top_selling_products, out_of_stock_items, created_at) FROM stdin;
1	HN_CG	2026-02-20	4	2410700	602675	4	0	0	123.07	361	["L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "Th\\u00f9ng 24 ly m\\u00ec Handy H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 67g", "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0"]	[]	2026-03-31 17:39:16.176273
2	HCM_Q1	2026-02-28	2	686450	343225	2	0	0	99.24	380	["B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "B\\u00fat bi Thi\\u00ean Long (C\\u00e2y)", "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 180ml"]	[]	2026-03-31 17:39:16.177284
3	HN_CG	2026-03-09	1	45000	45000	1	0	0	176.28	463	["D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g"]	[]	2026-03-31 17:39:16.177284
4	HCM_Q1	2026-03-04	6	3235500	539250	6	3	0.5	63.31	473	["D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "T\\u00fai \\u0111\\u1ef1ng r\\u00e1c (Cu\\u1ed9n 3 m\\u00e0u)", "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi thanh d\\u1ecbu", "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 220ml"]	[]	2026-03-31 17:39:16.178284
5	HCM_Q1	2026-03-30	2	1105150	552575	2	0	0	99.73	92	["L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa dinh d\\u01b0\\u1ee1ng Gotz 55g", "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "Nhang mu\\u1ed7i (H\\u1ed9p 10 khoanh)", "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply"]	[]	2026-03-31 17:39:16.178284
6	HCM_Q1	2026-03-23	2	565750	282875	2	0	0	186.78	54	["C\\u00e1p s\\u1ea1c Android/iPhone", "Ph\\u1edf b\\u00f2 Vifon g\\u00f3i 90g (c\\u00f3 g\\u00f3i th\\u1ecbt th\\u1eadt)", "B\\u1ed9t gi\\u1eb7t OMO (T\\u00fai 3kg)", "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "Th\\u00f9ng 12 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 1.5 l\\u00edt"]	[]	2026-03-31 17:39:16.179282
7	HCM_Q7	2026-02-18	3	2268750	756250	3	1	0.33	196.44	93	["Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "Tr\\u00e0 Lipton T\\u00fai l\\u1ecdc (H\\u1ed9p 25 g\\u00f3i)", "Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "N\\u01b0\\u1edbc lau s\\u00e0n Gift (1 L\\u00edt)"]	[]	2026-03-31 17:39:16.179282
8	HCM_Q1	2026-02-27	2	593000	296500	2	2	1	202.78	467	["Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "Bia Corona Extra chai 250ml", "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "Tr\\u00e0 Lipton T\\u00fai l\\u1ecdc (H\\u1ed9p 25 g\\u00f3i)", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t TH true MILK 180ml"]	[]	2026-03-31 17:39:16.179282
9	HN_CG	2026-02-21	3	1610500	536833.33	3	1	0.33	99.01	328	["Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa dinh d\\u01b0\\u1ee1ng Gotz 55g", "Nhang mu\\u1ed7i (H\\u1ed9p 10 khoanh)", "N\\u01b0\\u1edbc gi\\u1eb7t Ariel (T\\u00fai 2.1kg)", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml"]	[]	2026-03-31 17:39:16.180282
10	HCM_Q7	2026-03-22	4	1634950	408737.5	4	2	0.5	63.39	72	["B\\u00fan c\\u00e1 cay H\\u1eb1ng Nga g\\u00f3i 70g", "N\\u01b0\\u1edbc gi\\u1eb7t Ariel (T\\u00fai 2.1kg)", "Th\\u00f9ng 12 lon bia Hoegaarden Peach v\\u1ecb \\u0111\\u00e0o 500ml", "Ng\\u0169 c\\u1ed1c dinh d\\u01b0\\u1ee1ng (G\\u00f3i 500g)", "M\\u00ec H\\u1ea3o H\\u1ea3o T\\u00f4m Chua Cay"]	[]	2026-03-31 17:39:16.180282
11	HCM_Q7	2026-03-28	2	1215500	607750	2	0	0	82.69	164	["N\\u01b0\\u1edbc ch\\u1ea5m chua ng\\u1ecdt Nam Ng\\u01b0 \\u1edbt t\\u1ecfi L\\u00fd S\\u01a1n", "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml"]	[]	2026-03-31 17:39:16.181282
12	HN_CG	2026-02-23	1	90000	90000	1	0	0	116.53	196	["S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p chai 170ml", "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "Keo 502 (Chai)", "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g"]	[]	2026-03-31 17:39:16.181282
13	HCM_Q7	2026-03-26	1	1015500	1015500	1	0	0	138.69	106	["S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p chai 170ml", "B\\u00fan c\\u00e1 cay H\\u1eb1ng Nga g\\u00f3i 70g", "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "M\\u00ec Kokomi 90 t\\u00f4m chua cay g\\u00f3i 90g"]	[]	2026-03-31 17:39:16.182282
14	HCM_Q1	2026-03-22	4	3134300	783575	4	1	0.25	158.51	110	["6 lon n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 320ml", "M\\u00ec x\\u00e0o kh\\u00f4 Indomie Mi Goreng v\\u1ecb \\u0111\\u1eb7c bi\\u1ec7t g\\u00f3i 85g", "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi thanh d\\u1ecbu", "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml"]	[]	2026-03-31 17:39:16.182282
15	HCM_Q7	2026-03-16	3	2693650	897883.33	3	1	0.33	88.49	321	["Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt 7 Up v\\u1ecb chanh 390ml", "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An"]	[]	2026-03-31 17:39:16.182282
16	HN_CG	2026-02-27	1	375000	375000	1	1	1	84.04	391	["M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "Thu\\u1ed1c x\\u1ecbt mu\\u1ed7i Raid (600ml)", "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 250ml", "N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml"]	[]	2026-03-31 17:39:16.183282
17	HN_CG	2026-03-14	2	249500	124750	2	2	1	200.06	188	["Snack Khoai t\\u00e2y O'Star", "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa h\\u01b0\\u01a1ng vani Hoff 55g", "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)"]	[]	2026-03-31 17:39:16.183282
18	HCM_Q7	2026-02-16	5	3049950	609990	5	3	0.6	187.79	453	["D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh tinh luy\\u1ec7n Janbee", "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "B\\u00f3ng \\u0111\\u00e8n LED \\u0110i\\u1ec7n Quang 20W", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml"]	[]	2026-03-31 17:39:16.184282
19	HCM_Q7	2026-03-15	3	699600	233200	3	0	0	111.24	249	["T\\u01b0\\u01a1ng \\u1edbt Chinsu (250g)", "D\\u00e2y r\\u00fat nh\\u1ef1a (T\\u00fai 100 s\\u1ee3i)", "C\\u1ee7 s\\u1ea1c USB 2 c\\u1ed5ng", "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "Tr\\u00e0 Lipton T\\u00fai l\\u1ecdc (H\\u1ed9p 25 g\\u00f3i)"]	[]	2026-03-31 17:39:16.184789
20	HCM_Q7	2026-03-21	2	237100	118550	2	1	0.5	190.34	107	["Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "V\\u1edf h\\u1ecdc sinh 96 trang", "Th\\u00f9ng 24 lon Bia S\\u00e0i G\\u00f2n Lager 330ml", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml"]	[]	2026-03-31 17:39:16.184789
21	HCM_Q7	2026-03-09	3	1112600	370866.67	3	1	0.33	74.47	115	["L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Coca Cola 320ml", "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb d\\u00e2u 12% chai 360ml"]	[]	2026-03-31 17:39:16.185798
22	HCM_Q1	2026-03-31	1	315900	315900	1	1	1	139.07	296	["Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "G\\u1ea1o ST25 (T\\u00fai 5kg)", "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "C\\u1ee7 s\\u1ea1c USB 2 c\\u1ed5ng", "C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)"]	[]	2026-03-31 17:39:16.185798
23	HN_CG	2026-03-23	4	1506450	376612.5	4	1	0.25	113.35	460	["B\\u00f3ng \\u0111\\u00e8n LED \\u0110i\\u1ec7n Quang 20W", "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n nha \\u0111am Lothamilk 100g", "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "Th\\u00f9ng M\\u00ec 3 Mi\\u1ec1n (30 g\\u00f3i)", "N\\u01b0\\u1edbc x\\u1ea3 v\\u1ea3i Comfort (T\\u00fai 1.6L)"]	[]	2026-03-31 17:39:16.185798
24	HN_CG	2026-03-28	2	1894000	947000	2	1	0.5	139.54	323	["B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "D\\u1ea7u g\\u1ed9i Clear Men (Chai 630g)", "S\\u1eefa t\\u1eafm Lifebuoy (Chai 850g)", "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g"]	[]	2026-03-31 17:39:16.186798
25	HCM_Q7	2026-03-27	2	185450	92725	2	0	0	73.38	416	["Th\\u00f9ng M\\u00ec 3 Mi\\u1ec1n (30 g\\u00f3i)", "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "\\u00c1o m\\u01b0a ti\\u1ec7n l\\u1ee3i (C\\u00e1i)", "Th\\u1edbt nh\\u1ef1a tr\\u00f2n"]	[]	2026-03-31 17:39:16.186798
26	HN_CG	2026-03-27	3	755200	251733.33	3	2	0.67	189.81	162	["K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "L\\u1ed1c 4 h\\u0169 s\\u1eefa chua \\u0103n co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Lothamilk 100g", "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 320ml", "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh tinh luy\\u1ec7n Janbee"]	[]	2026-03-31 17:39:16.187798
27	HCM_Q7	2026-03-07	1	808000	808000	1	0	0	92.52	485	["N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0 nh\\u00e3n v\\u00e0ng 14 \\u0111\\u1ed9 \\u0111\\u1ea1m", "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 320ml", "B\\u00e0n ch\\u1ea3i \\u0111\\u00e1nh r\\u0103ng Colgate", "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng kh\\u00f4ng \\u0111\\u01b0\\u1eddng Vinamilk S\\u1eefa t\\u01b0\\u01a1i 100% 1 l\\u00edt"]	[]	2026-03-31 17:39:16.187798
28	HCM_Q1	2026-02-19	2	935700	467850	2	1	0.5	207.34	80	["N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml", "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 320ml", "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "Th\\u00f9ng 12 lon bia Hoegaarden Peach v\\u1ecb \\u0111\\u00e0o 500ml"]	[]	2026-03-31 17:39:16.188798
29	HCM_Q1	2026-02-25	2	1082950	541475	2	1	0.5	133.66	477	["Kem \\u0111\\u00e1nh r\\u0103ng P/S (180g)", "Th\\u00f9ng M\\u00ec 3 Mi\\u1ec1n (30 g\\u00f3i)", "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n nha \\u0111am Lothamilk 100g", "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p chai 170ml"]	[]	2026-03-31 17:39:16.188798
30	HCM_Q1	2026-03-26	2	1477000	738500	2	0	0	68.94	120	["Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "B\\u1eadt l\\u1eeda gas", "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g"]	[]	2026-03-31 17:39:16.188798
31	HN_CG	2026-03-12	3	1543000	514333.33	3	3	1	177.29	406	["D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An", "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola h\\u01b0\\u01a1ng vani Gery Crunch Roll g\\u00f3i 23g", "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en", "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "Ph\\u1edf b\\u00f2 Vifon g\\u00f3i 90g (c\\u00f3 g\\u00f3i th\\u1ecbt th\\u1eadt)"]	[]	2026-03-31 17:39:16.189797
32	HN_CG	2026-02-18	1	41000	41000	1	1	1	166.04	87	["Tr\\u00e0 Lipton T\\u00fai l\\u1ecdc (H\\u1ed9p 25 g\\u00f3i)", "Dao c\\u1ea1o r\\u00e2u Gillette (C\\u00e2y)", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml"]	[]	2026-03-31 17:39:16.189797
33	HCM_Q1	2026-03-17	3	1103950	367983.33	3	1	0.33	118.44	90	["L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n nha \\u0111am Lothamilk 100g", "M\\u00ec Kokomi 90 t\\u00f4m chua cay g\\u00f3i 90g", "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "N\\u01b0\\u1edbc t\\u1ea9y b\\u1ed3n c\\u1ea7u Vim (900ml)", "M\\u00ec H\\u1ea3o H\\u1ea3o T\\u00f4m Chua Cay"]	[]	2026-03-31 17:39:16.190798
34	HCM_Q1	2026-03-14	1	29850	29850	1	0	0	83.95	143	["S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "B\\u1ea5m kim s\\u1ed1 10 (C\\u00e1i)", "D\\u1ea7u g\\u1ed9i Sunsilk (Chai 650g)"]	[]	2026-03-31 17:39:16.190798
35	HCM_Q1	2026-02-26	3	2023000	674333.33	3	1	0.33	171.77	203	["S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "G\\u1ea1o ST25 (T\\u00fai 5kg)", "D\\u00e2y r\\u00fat nh\\u1ef1a (T\\u00fai 100 s\\u1ee3i)", "Th\\u00f9ng 12 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 1.5 l\\u00edt", "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)"]	[]	2026-03-31 17:39:16.191797
36	HCM_Q1	2026-03-08	2	397750	198875	2	2	1	185.02	405	["D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 250ml", "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t TH true MILK 180ml", "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o sa t\\u1ebf h\\u00e0nh t\\u00edm 75g"]	[]	2026-03-31 17:39:16.192394
37	HN_CG	2026-03-13	1	610280	610280	1	1	1	200.99	66	["Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "B\\u00eca h\\u1ed3 s\\u01a1 Clearbag (C\\u00e1i)", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng lof Kun 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "K\\u1eb9o c\\u1ee9ng Dynamite", "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt"]	[]	2026-03-31 17:39:16.192394
38	HN_CG	2026-02-25	2	656800	328400	2	1	0.5	61.74	476	["D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An", "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "Kem \\u0111\\u00e1nh r\\u0103ng P/S (180g)", "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)"]	[]	2026-03-31 17:39:16.193412
39	HN_CG	2026-03-01	1	643000	643000	1	1	1	192.72	342	["K\\u1eb9o c\\u1ee9ng Dynamite", "Bia Corona Extra chai 250ml", "N\\u1ebfn c\\u00e2y (G\\u00f3i 5 c\\u00e2y)", "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An"]	[]	2026-03-31 17:39:16.193412
40	HCM_Q1	2026-02-22	1	28800	28800	1	0	0	209.03	189	["Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "Tr\\u00e0 xanh C2 (Chai 360ml)", "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)"]	[]	2026-03-31 17:39:16.19441
41	HN_CG	2026-03-07	1	426100	426100	1	0	0	93.9	366	["Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g", "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh c\\u00e1 v\\u1ecb t\\u00f4m n\\u01b0\\u1edbng m\\u00f4i \\u0111\\u1ecf Orion Marine Boy 35g", "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch v\\u1ecb socola Ovaltine b\\u1ed5 sung canxi 180ml", "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)"]	[]	2026-03-31 17:39:16.194921
42	HCM_Q1	2026-03-28	1	308850	308850	1	0	0	216.16	359	["M\\u00ec Kokomi 90 t\\u00f4m chua cay g\\u00f3i 90g", "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "L\\u1ed1c 4 s\\u1eefa chua Vinamilk", "Tr\\u00e0 Lipton T\\u00fai l\\u1ecdc (H\\u1ed9p 25 g\\u00f3i)", "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb \\u0111\\u00e0o 12% chai 360ml"]	[]	2026-03-31 17:39:16.194921
43	HCM_Q1	2026-03-10	2	671750	335875	2	2	1	164.43	257	["B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng v\\u1ecb t\\u1ef1 nhi\\u00ean TH true MILK Hilo 180ml", "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en", "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola h\\u01b0\\u01a1ng vani Gery Crunch Roll g\\u00f3i 23g", "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0"]	[]	2026-03-31 17:39:16.195931
44	HCM_Q7	2026-03-25	2	1059350	529675	2	1	0.5	127.88	188	["Ph\\u1edf b\\u00f2 Vifon g\\u00f3i 90g (c\\u00f3 g\\u00f3i th\\u1ecbt th\\u1eadt)", "B\\u00fan c\\u00e1 cay H\\u1eb1ng Nga g\\u00f3i 70g", "M\\u00ec Kokomi 90 t\\u00f4m chua cay g\\u00f3i 90g", "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 320ml", "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)"]	[]	2026-03-31 17:39:16.195931
45	HN_CG	2026-03-20	2	234300	117150	2	2	1	184.61	221	["N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n \\u00edt \\u0111\\u01b0\\u1eddng Nutimilk 100g", "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "B\\u1ed9t gi\\u1eb7t OMO (T\\u00fai 3kg)"]	[]	2026-03-31 17:39:16.196929
46	HCM_Q1	2026-03-11	3	631500	210500	3	2	0.67	77.03	158	["Dao c\\u1ea1o r\\u00e2u Gillette (C\\u00e2y)", "D\\u1ea7u \\u0103n th\\u01b0\\u1ee3ng h\\u1ea1ng Neptune Light", "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb vi\\u1ec7t qu\\u1ea5t 12% chai 360ml", "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml"]	[]	2026-03-31 17:39:16.196929
47	HCM_Q1	2026-03-19	3	833200	277733.33	3	0	0	148.27	376	["N\\u01b0\\u1edbc m\\u1eafm Chinsu c\\u00e1 c\\u01a1m bi\\u1ec3n \\u0111\\u00f4ng 25 \\u0111\\u1ed9 \\u0111\\u1ea1m", "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n \\u00edt \\u0111\\u01b0\\u1eddng Nutimilk 100g", "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa dinh d\\u01b0\\u1ee1ng Gotz 55g", "M\\u00ec x\\u00e0o kh\\u00f4 Indomie Mi Goreng v\\u1ecb \\u0111\\u1eb7c bi\\u1ec7t g\\u00f3i 85g", "N\\u01b0\\u1edbc t\\u1ea9y b\\u1ed3n c\\u1ea7u Vim (900ml)"]	[]	2026-03-31 17:39:16.196929
48	HCM_Q7	2026-03-11	1	164500	164500	1	1	1	150.37	338	["C\\u00e1p s\\u1ea1c Android/iPhone", "N\\u01b0\\u1edbc su\\u1ed1i Aquafina (500ml)", "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi thanh d\\u1ecbu", "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Tam Th\\u00e1i T\\u1eed Nh\\u1ea5t Ca s\\u00e1nh \\u0111\\u1eadm", "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb \\u0111\\u00e0o 12% chai 360ml"]	[]	2026-03-31 17:39:16.19793
49	HN_CG	2026-03-08	2	1316200	658100	2	1	0.5	74.91	208	["D\\u1ea7u \\u0103n th\\u01b0\\u1ee3ng h\\u1ea1ng Neptune Light", "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "B\\u00eca h\\u1ed3 s\\u01a1 Clearbag (C\\u00e1i)", "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g"]	[]	2026-03-31 17:39:16.19793
50	HN_CG	2026-02-19	2	1927800	963900	2	1	0.5	140.03	211	["B\\u00eca h\\u1ed3 s\\u01a1 Clearbag (C\\u00e1i)", "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh c\\u00e1 v\\u1ecb t\\u00f4m n\\u01b0\\u1edbng m\\u00f4i \\u0111\\u1ecf Orion Marine Boy 35g", "B\\u00fat bi Thi\\u00ean Long (C\\u00e2y)", "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 220ml"]	[]	2026-03-31 17:39:16.198931
51	HN_CG	2026-03-16	5	1987650	397530	5	1	0.2	172.43	99	["Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "Th\\u01b0\\u1edbc k\\u1ebb 20cm", "K\\u1eb9o c\\u1ee9ng Dynamite", "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g"]	[]	2026-03-31 17:39:16.198931
52	HCM_Q1	2026-02-21	1	42750	42750	1	0	0	140.35	446	["Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "N\\u01b0\\u1edbc ch\\u1ea5m chua ng\\u1ecdt Nam Ng\\u01b0 \\u1edbt t\\u1ecfi L\\u00fd S\\u01a1n", "X\\u00e0 b\\u00f4ng c\\u1ee5c X-Men", "C\\u1ee7 s\\u1ea1c USB 2 c\\u1ed5ng", "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g"]	[]	2026-03-31 17:39:16.199931
53	HCM_Q1	2026-03-06	2	1377300	688650	2	2	1	136.31	494	["N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Nh\\u1ecb Ca Tam Th\\u00e1i T\\u1eed chai", "Th\\u00f9ng 24 lon Bia Blanc 1664 330ml", "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)"]	[]	2026-03-31 17:39:16.199931
54	HCM_Q7	2026-03-20	1	86000	86000	1	1	1	134.1	370	["Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "Keo 502 (Chai)", "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p 170ml", "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)"]	[]	2026-03-31 17:39:16.199931
55	HCM_Q7	2026-02-20	2	935500	467750	2	2	1	164.68	443	["Keo 502 (Chai)", "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "K\\u1eb9o c\\u1ee9ng Dynamite", "N\\u01b0\\u1edbc t\\u0103ng l\\u1ef1c Redbull (Lon)", "V\\u1edf h\\u1ecdc sinh 96 trang"]	[]	2026-03-31 17:39:16.20093
56	HCM_Q7	2026-03-12	4	835150	208787.5	4	2	0.5	157.4	317	["D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb 390ml", "T\\u01b0\\u01a1ng \\u1edbt Chinsu (250g)", "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 220ml"]	[]	2026-03-31 17:39:16.20093
57	HCM_Q7	2026-03-08	1	218000	218000	1	0	0	114.24	234	["Thu\\u1ed1c x\\u1ecbt mu\\u1ed7i Raid (600ml)", "H\\u1ea1t n\\u00eam Knorr (400g)", "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi \\u0111\\u1eadm \\u0111\\u1eb7c", "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "\\u00c1o m\\u01b0a ti\\u1ec7n l\\u1ee3i (C\\u00e1i)"]	[]	2026-03-31 17:39:16.20193
58	HCM_Q7	2026-02-19	1	175600	175600	1	0	0	169.26	172	["L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "M\\u00ec Kokomi 90 t\\u00f4m chua cay g\\u00f3i 90g", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t TH true MILK 180ml"]	[]	2026-03-31 17:39:16.20193
59	HCM_Q1	2026-03-01	2	252450	126225	2	0	0	150.7	304	["Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb vi\\u1ec7t qu\\u1ea5t 12% chai 360ml"]	[]	2026-03-31 17:39:16.20293
60	HCM_Q1	2026-02-20	1	408600	408600	1	0	0	147.54	458	["V\\u1edb ch\\u00e2n nam/n\\u1eef (\\u0110\\u00f4i)", "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "Snack Khoai t\\u00e2y O'Star", "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)"]	[]	2026-03-31 17:39:16.20293
61	HCM_Q7	2026-02-21	2	117900	58950	2	0	0	110.19	201	["Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "Th\\u00f9ng 24 lon Bia S\\u00e0i G\\u00f2n Lager 330ml", "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml"]	[]	2026-03-31 17:39:16.20393
62	HN_CG	2026-03-17	1	196400	196400	1	0	0	116.54	86	["L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "N\\u1ebfn c\\u00e2y (G\\u00f3i 5 c\\u00e2y)", "M\\u0169 b\\u1ea3o hi\\u1ec3m n\\u1eeda \\u0111\\u1ea7u", "C\\u00e1 h\\u1ed9p 3 C\\u00f4 G\\u00e1i", "L\\u1ed1c 2 h\\u0169 s\\u01b0\\u0303a chua n\\u00ea\\u0301p c\\u00e2\\u0309m Sa\\u0300i Go\\u0300n Milk 120g"]	[]	2026-03-31 17:39:16.20393
63	HN_CG	2026-03-25	1	13500	13500	1	0	0	217.78	181	["B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "C\\u00e2y lau nh\\u00e0 360 \\u0111\\u1ed9 (B\\u1ed9)", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml"]	[]	2026-03-31 17:39:16.204932
64	HCM_Q7	2026-03-13	2	1353100	676550	2	1	0.5	215.47	299	["N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi \\u0111\\u1eadm \\u0111\\u1eb7c", "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml", "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 250ml", "B\\u00e1nh quy socola chip nh\\u00e2n socola Parle Platina Hide & Seek g\\u00f3i 112.5g", "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g"]	[]	2026-03-31 17:39:16.205456
65	HCM_Q7	2026-02-26	1	1115200	1115200	1	1	1	197.12	398	["Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "\\u0110\\u01b0\\u1eddng tinh luy\\u1ec7n Bi\\u00ean H\\u00f2a (1kg)", "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml", "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "Thu\\u1ed1c x\\u1ecbt mu\\u1ed7i Raid (600ml)"]	[]	2026-03-31 17:39:16.205456
66	HN_CG	2026-03-04	2	1754050	877025	2	0	0	212.33	241	["M\\u00ec x\\u00e0o kh\\u00f4 Indomie Mi Goreng v\\u1ecb \\u0111\\u1eb7c bi\\u1ec7t g\\u00f3i 85g", "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "G\\u1ea1o ST25 (T\\u00fai 5kg)", "B\\u00e1nh quy Cosy (G\\u00f3i 200g)", "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)"]	[]	2026-03-31 17:39:16.206467
67	HCM_Q7	2026-02-27	1	1527950	1527950	1	0	0	102.05	498	["B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi \\u0111\\u1eadm \\u0111\\u1eb7c", "S\\u00e1p kh\\u1eed m\\u00f9i ph\\u00f2ng (H\\u1ed9p)", "T\\u00fai \\u0111\\u1ef1ng r\\u00e1c (Cu\\u1ed9n 3 m\\u00e0u)", "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g"]	[]	2026-03-31 17:39:16.208731
68	HCM_Q1	2026-03-07	1	349000	349000	1	1	1	178.57	175	["K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "N\\u01b0\\u1edbc r\\u1eeda ch\\u00e9n Sunlight (750ml)", "D\\u1ea7u \\u0103n th\\u01b0\\u1ee3ng h\\u1ea1ng Neptune Light", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t TH true MILK 180ml", "B\\u00fan c\\u00e1 cay H\\u1eb1ng Nga g\\u00f3i 70g"]	[]	2026-03-31 17:39:16.209741
69	HN_CG	2026-03-10	1	102000	102000	1	0	0	106.51	131	["N\\u01b0\\u1edbc t\\u1ea9y b\\u1ed3n c\\u1ea7u Vim (900ml)", "B\\u00e1nh quy socola chip nh\\u00e2n socola Parle Platina Hide & Seek g\\u00f3i 112.5g", "Th\\u00f9ng 24 ly m\\u00ec Handy H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 67g", "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p chai 170ml", "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh quy socola Orion Miz 54g"]	[]	2026-03-31 17:39:16.210746
70	HCM_Q7	2026-02-17	3	543700	181233.33	3	1	0.33	199.87	392	["Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml", "L\\u1ed1c 4 s\\u1eefa chua Vinamilk", "T\\u00fai \\u0111\\u1ef1ng r\\u00e1c (Cu\\u1ed9n 3 m\\u00e0u)", "D\\u1ea7u g\\u1ed9i Clear Men (Chai 630g)"]	[]	2026-03-31 17:39:16.211763
71	HCM_Q1	2026-03-16	2	550000	275000	2	0	0	204.02	288	["Ph\\u1edf b\\u00f2 Vifon g\\u00f3i 90g (c\\u00f3 g\\u00f3i th\\u1ecbt th\\u1eadt)", "M\\u00ec x\\u00e0o kh\\u00f4 Indomie Mi Goreng v\\u1ecb \\u0111\\u1eb7c bi\\u1ec7t g\\u00f3i 85g", "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "B\\u00fat ch\\u00ec g\\u1ed7 2B", "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g"]	[]	2026-03-31 17:39:16.212753
72	HCM_Q7	2026-03-04	3	607700	202566.67	3	1	0.33	182.91	152	["B\\u00e1nh quy socola chip nh\\u00e2n socola Parle Platina Hide & Seek g\\u00f3i 112.5g", "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb d\\u00e2u 12% chai 360ml", "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb 390ml"]	[]	2026-03-31 17:39:16.212753
73	HN_CG	2026-02-26	1	18000	18000	1	1	1	219.43	298	["L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "Th\\u01b0\\u1edbc k\\u1ebb 20cm", "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "L\\u1ed1c 5 g\\u00f3i ph\\u1edf g\\u00e0 \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 65g"]	[]	2026-03-31 17:39:16.213756
74	HCM_Q7	2026-03-19	1	990100	990100	1	1	1	104.54	69	["N\\u01b0\\u1edbc gi\\u1eb7t Ariel (T\\u00fai 2.1kg)", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t TH true MILK 180ml", "S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "Bao tay cao su (\\u0110\\u00f4i)"]	[]	2026-03-31 17:39:16.213756
75	HCM_Q1	2026-03-02	1	490000	490000	1	0	0	94.16	340	["N\\u01b0\\u1edbc m\\u1eafm Chinsu c\\u00e1 c\\u01a1m bi\\u1ec3n \\u0111\\u00f4ng 25 \\u0111\\u1ed9 \\u0111\\u1ea1m", "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "\\u00c1o m\\u01b0a ti\\u1ec7n l\\u1ee3i (C\\u00e1i)", "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o sa t\\u1ebf h\\u00e0nh t\\u00edm 75g"]	[]	2026-03-31 17:39:16.213756
76	HCM_Q7	2026-03-31	1	391750	391750	1	0	0	209.83	235	["C\\u00e1p s\\u1ea1c Android/iPhone", "H\\u1ea1t n\\u00eam Knorr (400g)", "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en"]	[]	2026-03-31 17:39:16.215284
77	HCM_Q1	2026-03-03	1	2768100	2768100	1	1	1	93.84	61	["Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An", "Th\\u00f9ng 24 lon Bia Tiger lon 250ml", "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n kh\\u00f4ng \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g"]	[]	2026-03-31 17:39:16.215284
78	HCM_Q1	2026-03-21	1	292350	292350	1	0	0	161.71	92	["Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "Th\\u00f9ng 24 lon Bia Heineken Silver 250ml", "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "M\\u00ec H\\u1ea3o 100 t\\u00f4m chua cay g\\u00f3i 65g"]	[]	2026-03-31 17:39:16.216325
79	HCM_Q7	2026-03-23	1	47600	47600	1	1	1	107.73	414	["Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "Th\\u00f9ng M\\u00ec 3 Mi\\u1ec1n (30 g\\u00f3i)", "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "M\\u00e0ng b\\u1ecdc th\\u1ef1c ph\\u1ea9m (Cu\\u1ed9n)"]	[]	2026-03-31 17:39:16.217299
80	HCM_Q1	2026-03-05	1	541500	541500	1	0	0	202.89	144	["N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en", "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb 390ml", "B\\u00eca h\\u1ed3 s\\u01a1 Clearbag (C\\u00e1i)"]	[]	2026-03-31 17:39:16.218309
81	HCM_Q7	2026-02-24	2	1228000	614000	2	0	0	107.5	151	["N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml", "Th\\u00f9ng M\\u00ec 3 Mi\\u1ec1n (30 g\\u00f3i)", "N\\u01b0\\u1edbc su\\u1ed1i Aquafina (500ml)", "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "S\\u1eefa t\\u1eafm Lifebuoy (Chai 850g)"]	[]	2026-03-31 17:39:16.218309
82	HN_CG	2026-03-29	1	20800	20800	1	1	1	170.21	132	["Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "B\\u1ed9t ng\\u1ecdt Ajinomoto (454g)", "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Coca Cola 320ml", "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "Gi\\u1ea5y v\\u1ec7 sinh E'mos (L\\u1ed1c 10)"]	[]	2026-03-31 17:39:16.21932
83	HCM_Q1	2026-03-12	1	1380100	1380100	1	1	1	122.26	55	["N\\u01b0\\u1edbc r\\u1eeda ch\\u00e9n Sunlight (750ml)", "V\\u1edb ch\\u00e2n nam/n\\u1eef (\\u0110\\u00f4i)", "Dao c\\u1ea1o r\\u00e2u Gillette (C\\u00e2y)", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "M\\u00ec Kokomi 90 t\\u00f4m chua cay g\\u00f3i 90g"]	[]	2026-03-31 17:39:16.220314
84	HCM_Q7	2026-03-29	1	37050	37050	1	1	1	175.64	346	["N\\u01b0\\u1edbc r\\u1eeda tay kh\\u00f4 (Chai 100ml)", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng d\\u1ee9a 12.5% chai 360ml", "Pin AAA Panasonic (V\\u1ec9 2 vi\\u00ean)", "B\\u00fat ch\\u00ec g\\u1ed7 2B"]	[]	2026-03-31 17:39:16.220314
85	HCM_Q1	2026-03-29	1	48500	48500	1	0	0	178.85	427	["B\\u00fat ch\\u00ec g\\u1ed7 2B", "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb d\\u00e2u 12% chai 360ml", "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "C\\u00e1 h\\u1ed9p 3 C\\u00f4 G\\u00e1i"]	[]	2026-03-31 17:39:16.221308
86	HCM_Q1	2026-02-15	1	204000	204000	1	0	0	209.41	305	["R\\u01b0\\u1ee3u soju Heejin v\\u1ecb d\\u00e2u 12% chai 360ml", "L\\u1ed1c 5 g\\u00f3i ph\\u1edf g\\u00e0 \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 65g", "C\\u00e1p s\\u1ea1c Android/iPhone", "Gi\\u1ea5y b\\u1ea1c n\\u01b0\\u1edbng (Cu\\u1ed9n)", "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g"]	[]	2026-03-31 17:39:16.221308
87	HCM_Q7	2026-03-10	1	496000	496000	1	0	0	102.05	419	["D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh tinh luy\\u1ec7n Janbee", "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)", "Bao tay cao su (\\u0110\\u00f4i)"]	[]	2026-03-31 17:39:16.222311
88	HCM_Q7	2026-03-30	1	295000	295000	1	0	0	215.11	99	["N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Nh\\u1ecb Ca Tam Th\\u00e1i T\\u1eed chai", "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p 170ml", "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "Th\\u00f9ng M\\u00ec 3 Mi\\u1ec1n (30 g\\u00f3i)"]	[]	2026-03-31 17:39:16.222311
89	HCM_Q7	2026-03-02	1	29000	29000	1	0	0	171.43	446	["Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng v\\u1ecb t\\u1ef1 nhi\\u00ean TH true MILK Hilo 180ml", "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p 170ml", "N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml"]	[]	2026-03-31 17:39:16.223766
90	HN_CG	2026-02-22	1	795000	795000	1	1	1	93.56	147	["Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml"]	[]	2026-03-31 17:39:16.224289
91	HN_CG	2026-02-16	1	47000	47000	1	1	1	62.59	207	["K\\u1eb9o c\\u1ee9ng Dynamite", "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "Snack Khoai t\\u00e2y O'Star", "C\\u00e2y lau nh\\u00e0 360 \\u0111\\u1ed9 (B\\u1ed9)"]	[]	2026-03-31 17:39:16.224289
92	HCM_Q1	2026-02-23	1	1190000	1190000	1	1	1	219.85	261	["G\\u1ea1o ST25 (T\\u00fai 5kg)", "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Coca Cola 320ml", "B\\u1ed9t gi\\u1eb7t OMO (T\\u00fai 3kg)", "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "Tr\\u00e0 xanh C2 (Chai 360ml)"]	[]	2026-03-31 17:39:16.224289
93	HCM_Q7	2026-02-14	1	140350	140350	1	0	0	215.85	221	["L\\u1ed1c 5 g\\u00f3i ph\\u1edf g\\u00e0 \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 65g", "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "C\\u00e1 h\\u1ed9p 3 C\\u00f4 G\\u00e1i", "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola h\\u01b0\\u01a1ng vani Gery Crunch Roll g\\u00f3i 23g"]	[]	2026-03-31 17:39:16.225827
94	HN_CG	2026-03-18	1	1110000	1110000	1	1	1	88.3	354	["Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "B\\u1ed9t gi\\u1eb7t OMO (T\\u00fai 3kg)", "B\\u1ed9t ng\\u1ecdt Ajinomoto (454g)", "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml"]	[]	2026-03-31 17:39:16.225827
95	HN_CG	2026-03-24	1	1220500	1220500	1	1	1	195.21	402	["B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "B\\u1ed9t ng\\u1ecdt Ajinomoto (454g)", "C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)", "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp"]	[]	2026-03-31 17:39:16.226848
96	HN_CG	2026-03-19	1	792000	792000	1	0	0	159.26	488	["Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "B\\u00fan c\\u00e1 cay H\\u1eb1ng Nga g\\u00f3i 70g", "C\\u00e2y lau nh\\u00e0 360 \\u0111\\u1ed9 (B\\u1ed9)", "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0 nh\\u00e3n v\\u00e0ng 14 \\u0111\\u1ed9 \\u0111\\u1ea1m"]	[]	2026-03-31 17:39:16.226848
97	HCM_Q7	2026-02-28	1	611000	611000	1	0	0	158.6	260	["B\\u00fan c\\u00e1 cay H\\u1eb1ng Nga g\\u00f3i 70g", "Snack Khoai t\\u00e2y O'Star", "B\\u1ea5m kim s\\u1ed1 10 (C\\u00e1i)", "B\\u00eca h\\u1ed3 s\\u01a1 Clearbag (C\\u00e1i)", "Thu\\u1ed1c x\\u1ecbt mu\\u1ed7i Raid (600ml)"]	[]	2026-03-31 17:39:16.226848
98	HCM_Q7	2026-03-24	1	165000	165000	1	1	1	208.36	101	["C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)", "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "K\\u1eb9o c\\u1ee9ng Dynamite", "B\\u0103ng v\\u1ec7 sinh Diana (G\\u00f3i 8)", "N\\u01b0\\u1edbc m\\u1eafm Chinsu c\\u00e1 c\\u01a1m bi\\u1ec3n \\u0111\\u00f4ng 25 \\u0111\\u1ed9 \\u0111\\u1ea1m"]	[]	2026-03-31 17:39:16.227847
99	HN_CG	2026-03-21	1	444450	444450	1	1	1	166.83	486	["Th\\u00f9ng M\\u00ec 3 Mi\\u1ec1n (30 g\\u00f3i)", "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p chai 170ml", "\\u00c1o m\\u01b0a ti\\u1ec7n l\\u1ee3i (C\\u00e1i)", "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)"]	[]	2026-03-31 17:39:16.227847
\.


--
-- Data for Name: customer_consents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_consents (id, customer_id, face_recognition_consent, data_collection_consent, marketing_consent, opted_out, opted_out_at, opt_out_reason, consent_method, consent_ip_address, consent_location, data_retention_until, created_at, updated_at) FROM stdin;
1	1	f	t	f	f	\N	\N	kiosk	10.0.0.192	Q7 kiosk	2026-10-10 17:38:51.951503+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
2	2	t	t	t	f	\N	\N	kiosk	10.0.0.43	HN app	2026-11-06 17:38:52.681538+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
3	3	t	t	f	f	\N	\N	staff	10.0.0.42	Q7 kiosk	2027-03-30 17:38:53.030687+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
4	4	t	t	t	f	\N	\N	kiosk	10.0.0.176	Q7 kiosk	2027-01-10 17:38:53.38783+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
5	5	t	f	t	f	\N	Không muốn nhận marketing	kiosk	10.0.0.55	HN app	2026-10-16 17:38:53.779572+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
6	6	t	t	t	f	2026-02-07 09:40:54.101541	\N	mobile	10.0.0.117	HN app	2027-01-22 17:38:54.101541+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
7	7	f	t	f	f	2026-02-11 03:14:54.449225	\N	staff	10.0.0.9	Q7 kiosk	2026-09-17 17:38:54.449225+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
8	8	t	t	t	t	\N	\N	kiosk	10.0.0.80	Q1 kiosk	2026-12-22 17:38:54.891869+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
9	9	f	f	f	f	\N	\N	kiosk	10.0.0.66	Q1 kiosk	2026-10-08 17:38:55.310488+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
10	10	t	t	f	f	\N	\N	mobile	10.0.0.65	Q1 kiosk	2027-02-07 17:38:55.659677+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
11	11	t	t	f	f	\N	\N	staff	10.0.0.21	HN app	2026-08-06 17:38:56.067324+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
12	12	t	t	t	f	\N	\N	kiosk	10.0.0.120	HN app	2027-03-17 17:38:56.430956+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
13	13	t	f	f	f	\N	\N	mobile	10.0.0.61	Q1 kiosk	2026-11-11 17:38:56.816341+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
14	14	t	t	f	f	\N	\N	mobile	10.0.0.95	HN app	2026-08-07 17:38:57.406846+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
15	15	t	t	t	f	\N	\N	kiosk	10.0.0.171	Q1 kiosk	2027-01-27 17:38:57.85253+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
16	16	t	t	f	t	\N	\N	mobile	10.0.0.155	HN app	2026-07-08 17:38:58.227326+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
17	17	f	t	f	f	\N	\N	mobile	10.0.0.154	HN app	2026-08-03 17:38:58.583567+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
18	18	t	f	t	f	2026-02-17 12:41:58.938442	\N	kiosk	10.0.0.231	HN app	2027-02-04 17:38:58.938442+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
19	19	t	t	t	f	\N	\N	staff	10.0.0.106	Q7 kiosk	2026-10-03 17:38:59.28657+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
20	20	t	f	t	f	\N	\N	kiosk	10.0.0.107	HN app	2027-03-03 17:38:59.668393+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
21	21	t	t	f	f	\N	\N	kiosk	10.0.0.43	Q7 kiosk	2026-07-01 17:38:59.996727+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
22	22	t	t	f	f	\N	\N	staff	10.0.0.128	Q7 kiosk	2026-07-04 17:39:00.350898+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
23	23	f	t	t	f	\N	\N	kiosk	10.0.0.134	Q1 kiosk	2026-08-03 17:39:00.692487+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
24	24	t	t	t	f	\N	\N	kiosk	10.0.0.207	HN app	2026-11-07 17:39:01.014056+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
25	25	f	t	t	f	\N	\N	staff	10.0.0.60	Q7 kiosk	2027-01-26 17:39:01.382285+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
26	26	f	t	f	f	\N	\N	kiosk	10.0.0.62	HN app	2026-10-30 17:39:01.733953+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
27	27	f	t	t	f	\N	\N	staff	10.0.0.224	Q7 kiosk	2027-03-07 17:39:02.179643+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
28	28	f	t	t	f	\N	\N	kiosk	10.0.0.5	HN app	2026-10-14 17:39:02.683936+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
29	29	t	t	f	f	\N	\N	staff	10.0.0.35	HN app	2026-10-24 17:39:03.018658+00	2026-03-31 17:39:13.856593+00	2026-03-31 17:39:13.856593+00
30	30	t	t	t	f	\N	Không muốn nhận marketing	kiosk	10.0.0.178	Q1 kiosk	2026-07-29 17:39:03.418528+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
31	31	t	t	f	f	\N	\N	staff	10.0.0.139	Q1 kiosk	2026-11-21 17:39:03.805751+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
32	32	t	t	t	f	2026-03-10 10:19:04.142662	\N	mobile	10.0.0.183	Q7 kiosk	2027-01-17 17:39:04.142662+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
33	33	t	t	t	f	\N	Không muốn nhận marketing	mobile	10.0.0.136	Q1 kiosk	2026-08-21 17:39:04.497052+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
34	34	t	t	f	f	\N	\N	mobile	10.0.0.142	Q7 kiosk	2026-09-06 17:39:04.831127+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
35	35	t	t	t	f	\N	\N	kiosk	10.0.0.2	HN app	2026-09-06 17:39:05.174097+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
36	36	f	t	t	f	\N	\N	staff	10.0.0.190	HN app	2027-01-14 17:39:05.467985+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
37	37	t	t	t	f	\N	\N	staff	10.0.0.161	Q7 kiosk	2026-10-03 17:39:05.76392+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
38	38	t	t	t	f	\N	\N	staff	10.0.0.204	Q1 kiosk	2026-12-15 17:39:06.094481+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
39	39	t	t	t	f	\N	\N	kiosk	10.0.0.52	Q7 kiosk	2026-08-16 17:39:06.512699+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
40	40	t	t	f	f	\N	\N	staff	10.0.0.113	Q7 kiosk	2026-07-06 17:39:06.858341+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
41	41	t	t	f	f	\N	\N	kiosk	10.0.0.93	HN app	2026-09-15 17:39:07.186165+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
42	42	t	t	f	f	\N	\N	staff	10.0.0.49	HN app	2026-12-24 17:39:07.475403+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
43	43	f	t	f	f	\N	\N	staff	10.0.0.63	Q7 kiosk	2026-07-31 17:39:07.78414+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
44	44	t	t	f	f	2026-03-25 02:27:08.08273	\N	staff	10.0.0.166	Q7 kiosk	2027-03-06 17:39:08.08273+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
45	45	t	t	t	f	\N	\N	staff	10.0.0.16	HN app	2026-11-12 17:39:08.390947+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
46	46	t	t	f	f	\N	\N	kiosk	10.0.0.198	HN app	2026-12-29 17:39:08.730439+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
47	47	f	t	f	f	\N	\N	staff	10.0.0.84	HN app	2026-10-30 17:39:09.043899+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
48	48	t	t	f	t	\N	\N	mobile	10.0.0.7	HN app	2026-11-17 17:39:09.349812+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
49	49	t	t	f	f	\N	Không muốn nhận marketing	mobile	10.0.0.204	Q7 kiosk	2026-09-25 17:39:09.666987+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
50	50	f	t	f	f	\N	\N	kiosk	10.0.0.193	HN app	2026-07-04 17:39:09.963885+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
51	51	f	t	f	t	\N	\N	kiosk	10.0.0.35	Q7 kiosk	2026-08-10 17:39:10.304636+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
52	52	t	t	f	f	2026-02-10 04:19:10.621579	\N	staff	10.0.0.24	Q1 kiosk	2027-01-26 17:39:10.621579+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
53	53	f	t	f	f	\N	\N	staff	10.0.0.15	Q1 kiosk	2026-09-12 17:39:10.964652+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
54	54	t	t	f	f	\N	\N	staff	10.0.0.136	Q1 kiosk	2026-11-06 17:39:11.276325+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
55	55	f	t	f	f	\N	\N	staff	10.0.0.27	Q7 kiosk	2027-03-04 17:39:11.626202+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
56	56	t	t	f	f	\N	\N	staff	10.0.0.72	Q1 kiosk	2026-11-07 17:39:11.964038+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
57	57	f	t	t	f	\N	\N	staff	10.0.0.86	Q7 kiosk	2026-09-04 17:39:12.402951+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
58	58	t	t	f	f	\N	\N	staff	10.0.0.9	Q7 kiosk	2027-01-26 17:39:12.779652+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
59	59	t	t	t	f	\N	\N	staff	10.0.0.201	Q7 kiosk	2026-09-05 17:39:13.12351+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
60	60	f	f	t	f	\N	\N	kiosk	10.0.0.239	Q7 kiosk	2027-03-06 17:39:13.460861+00	2026-03-31 17:39:13.858103+00	2026-03-31 17:39:13.858103+00
\.


--
-- Data for Name: customer_stats; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_stats (id, customer_id, total_transactions, total_spent, avg_basket_size, favorite_categories, last_purchase_date, rank_score, segment, updated_at) FROM stdin;
1	1	21	5202498.11	399991.35	["Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "Gia v\\u1ecb", "Snack"]	2026-03-14 19:20:51.950892	72.36	VIP	2026-03-31 17:39:13.921608+00
2	2	7	6389256.00	340712.76	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-01 11:20:52.681538	50.39	VIP	2026-03-31 17:39:13.921608+00
3	3	4	375590.07	423592.45	["Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "Snack", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m"]	2026-03-11 20:19:53.030687	54.15	New	2026-03-31 17:39:13.921608+00
4	4	6	4677007.89	202494.62	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-15 02:03:53.387231	84.13	VIP	2026-03-31 17:39:13.921608+00
5	5	9	270469.54	271241.09	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Gia v\\u1ecb", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t"]	2026-03-30 07:41:53.778572	68.64	Churn Risk	2026-03-31 17:39:13.921608+00
6	6	17	5818365.83	405095.78	["Gia v\\u1ecb", "Snack", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m"]	2026-03-10 13:37:54.100549	51.33	Churn Risk	2026-03-31 17:39:13.921608+00
7	7	3	3790357.15	317326.42	["Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "Snack", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m"]	2026-03-13 15:54:54.449225	86.34	Churn Risk	2026-03-31 17:39:13.921608+00
8	8	25	5602643.83	281918.05	["N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Gia v\\u1ecb"]	2026-03-02 17:57:54.891869	43.58	VIP	2026-03-31 17:39:13.921608+00
9	9	16	1082940.31	148077.31	["Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Snack"]	2026-03-28 11:56:55.310488	81.97	VIP	2026-03-31 17:39:13.921608+00
10	10	4	4731939.40	166777.15	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Snack", "Gia v\\u1ecb"]	2026-03-21 02:10:55.659677	39.55	Churn Risk	2026-03-31 17:39:13.921608+00
11	11	23	2387784.36	257582.97	["Gia v\\u1ecb", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t"]	2026-03-16 00:32:56.067324	25.82	New	2026-03-31 17:39:13.921608+00
12	12	18	4094415.43	364604.09	["N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Snack", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m"]	2026-03-22 23:41:56.430956	99.89	Loyal	2026-03-31 17:39:13.921608+00
13	13	21	1748277.55	436680.10	["Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m"]	2026-03-27 03:28:56.816341	26.12	New	2026-03-31 17:39:13.921608+00
14	14	16	6363310.04	213663.00	["Gia v\\u1ecb", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "Snack"]	2026-03-29 21:18:57.406846	19.29	New	2026-03-31 17:39:13.921608+00
15	15	12	2534996.25	401056.19	["Gia v\\u1ecb", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m"]	2026-03-31 00:42:57.85253	22.51	Potential	2026-03-31 17:39:13.921608+00
16	16	15	3405246.03	298592.63	["Gia v\\u1ecb", "Snack", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-30 13:02:58.227326	63.31	Potential	2026-03-31 17:39:13.921608+00
17	17	6	3199503.20	447327.05	["Gia v\\u1ecb", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Snack"]	2026-03-05 04:00:58.583567	22.84	New	2026-03-31 17:39:13.921608+00
18	18	0	1496204.99	398048.93	["Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "Gia v\\u1ecb", "Snack"]	2026-03-12 14:27:58.938442	52.83	New	2026-03-31 17:39:13.921608+00
19	19	16	3059798.22	427216.00	["Gia v\\u1ecb", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t"]	2026-03-12 17:40:59.28657	78.54	New	2026-03-31 17:39:13.921608+00
20	20	16	913017.37	82661.80	["N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-20 14:29:59.668393	48.35	New	2026-03-31 17:39:13.921608+00
21	21	8	6920707.02	293730.93	["Gia v\\u1ecb", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m"]	2026-03-27 18:24:59.996727	50.19	Potential	2026-03-31 17:39:13.921608+00
22	22	19	3104104.30	103709.77	["N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Snack"]	2026-03-12 15:53:00.350898	44.59	Loyal	2026-03-31 17:39:13.921608+00
23	23	6	331904.52	301820.52	["Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m"]	2026-03-25 20:37:00.692487	42.38	VIP	2026-03-31 17:39:13.921608+00
24	24	17	6413561.92	208795.24	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-01 11:10:01.014056	93.67	New	2026-03-31 17:39:13.921608+00
25	25	22	3155103.62	219519.70	["Gia v\\u1ecb", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-01 02:56:01.382285	51.46	New	2026-03-31 17:39:13.921608+00
26	26	8	1812977.50	114413.49	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Snack", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-02 12:09:01.733953	38.25	Potential	2026-03-31 17:39:13.921608+00
27	27	7	5870709.50	211730.13	["Snack", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "Gia v\\u1ecb"]	2026-03-09 20:08:02.179643	65.24	New	2026-03-31 17:39:13.921608+00
28	28	12	1632440.20	293366.12	["Snack", "Gia v\\u1ecb", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t"]	2026-03-01 00:37:02.683936	55.22	Loyal	2026-03-31 17:39:13.921608+00
29	29	19	6046709.96	149246.40	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Gia v\\u1ecb"]	2026-03-15 22:18:03.017644	42.93	Loyal	2026-03-31 17:39:13.921608+00
30	30	13	6008530.30	152543.39	["N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Gia v\\u1ecb", "Snack"]	2026-03-26 04:08:03.418528	22.1	New	2026-03-31 17:39:13.921608+00
31	31	20	764483.02	355499.49	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t"]	2026-03-13 23:40:03.805751	82.9	Churn Risk	2026-03-31 17:39:13.921608+00
32	32	24	5182030.54	409164.01	["Gia v\\u1ecb", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t"]	2026-03-11 12:44:04.142662	25.08	Churn Risk	2026-03-31 17:39:13.921608+00
33	33	18	3694456.27	246606.80	["N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "Snack"]	2026-03-26 18:24:04.497052	69.58	VIP	2026-03-31 17:39:13.921608+00
34	34	12	2234657.51	171536.71	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Gia v\\u1ecb", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-27 13:06:04.831127	85.47	VIP	2026-03-31 17:39:13.921608+00
35	35	14	4454227.91	315264.92	["Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "Gia v\\u1ecb", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m"]	2026-03-10 21:05:05.174097	37.87	Churn Risk	2026-03-31 17:39:13.921608+00
36	36	22	6462409.93	430374.28	["Gia v\\u1ecb", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Snack"]	2026-03-07 03:48:05.467985	36.36	Potential	2026-03-31 17:39:13.921608+00
37	37	20	1752976.52	362879.17	["Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t"]	2026-03-10 18:05:05.76392	82.79	Loyal	2026-03-31 17:39:13.921608+00
38	38	0	1382969.43	117841.19	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-16 18:39:06.094481	30.95	Potential	2026-03-31 17:39:13.921608+00
39	39	8	5452005.08	106412.34	["Gia v\\u1ecb", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Snack"]	2026-03-03 08:47:06.512699	44.34	VIP	2026-03-31 17:39:13.921608+00
40	40	21	6732375.89	426399.64	["N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Snack", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m"]	2026-03-02 00:06:06.858341	20.99	Loyal	2026-03-31 17:39:13.921608+00
41	41	12	5545092.08	83304.05	["Snack", "Gia v\\u1ecb", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m"]	2026-03-12 13:16:07.186165	79.37	Potential	2026-03-31 17:39:13.921608+00
42	42	15	1705454.95	443220.01	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Gia v\\u1ecb", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-25 16:55:07.475403	44	Potential	2026-03-31 17:39:13.921608+00
43	43	19	6409870.61	285172.51	["Snack", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Gia v\\u1ecb"]	2026-03-22 09:05:07.78414	43.04	VIP	2026-03-31 17:39:13.921608+00
44	44	16	4814246.86	363321.62	["N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-17 21:19:08.08273	19.94	New	2026-03-31 17:39:13.921608+00
45	45	1	2627842.74	304202.84	["Snack", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "Gia v\\u1ecb"]	2026-03-11 01:40:08.390947	90.08	VIP	2026-03-31 17:39:13.921608+00
46	46	9	637754.09	159883.02	["Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "Snack", "Gia v\\u1ecb"]	2026-03-08 10:05:08.730439	44.68	Potential	2026-03-31 17:39:13.921608+00
47	47	3	1250984.30	146746.72	["Gia v\\u1ecb", "S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-26 00:01:09.043899	49.87	Churn Risk	2026-03-31 17:39:13.921608+00
48	48	17	6490413.77	174012.98	["Gia v\\u1ecb", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t"]	2026-03-30 18:37:09.349812	98.47	New	2026-03-31 17:39:13.921608+00
49	49	18	1167532.02	93962.43	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Snack"]	2026-03-23 05:43:09.666987	62.39	Potential	2026-03-31 17:39:13.921608+00
50	50	18	5754655.33	115284.70	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "Snack", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-05 23:15:09.963885	17.06	VIP	2026-03-31 17:39:13.921608+00
51	51	9	3718245.13	198147.12	["Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Gia v\\u1ecb"]	2026-03-14 19:25:10.304636	23.79	Loyal	2026-03-31 17:39:13.921608+00
52	52	12	1911650.04	227455.00	["Gia v\\u1ecb", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Snack"]	2026-03-16 00:27:10.621579	53.91	New	2026-03-31 17:39:13.921608+00
53	53	11	4197752.33	88956.53	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Gia v\\u1ecb"]	2026-03-12 03:00:10.964652	23.12	VIP	2026-03-31 17:39:13.921608+00
54	54	3	2205314.55	254340.41	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n"]	2026-03-14 11:26:11.276325	59.18	Churn Risk	2026-03-31 17:39:13.921608+00
55	55	22	4363956.96	99641.54	["Snack", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t"]	2026-03-10 08:57:11.625196	86.69	Churn Risk	2026-03-31 17:39:13.921608+00
56	56	16	6770860.47	287454.39	["Snack", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "Gia v\\u1ecb"]	2026-03-02 01:20:11.964038	40.02	Loyal	2026-03-31 17:39:13.921608+00
57	57	8	1656520.61	206460.88	["Gia v\\u1ecb", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Snack"]	2026-03-08 05:06:12.402951	96.45	New	2026-03-31 17:39:13.921608+00
58	58	21	5620724.91	399157.43	["S\\u1eefa & ch\\u1ebf ph\\u1ea9m", "N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Gia v\\u1ecb"]	2026-03-02 12:58:12.779652	93.97	Potential	2026-03-31 17:39:13.921608+00
59	59	20	6539425.21	181304.58	["N\\u01b0\\u1edbc gi\\u1ea3i kh\\u00e1t", "Snack", "Gia v\\u1ecb"]	2026-03-26 16:51:13.12351	98.74	New	2026-03-31 17:39:13.921608+00
60	60	20	2680319.87	395287.89	["Gia v\\u1ecb", "Ch\\u0103m s\\u00f3c c\\u00e1 nh\\u00e2n", "Snack"]	2026-03-26 11:25:13.460861	12.9	VIP	2026-03-31 17:39:13.921608+00
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customers (id, customer_id, first_name, last_name, phone, email, cccd, address, birth_date, age, age_group, gender, description, preferred_branch, avg_basket_size, first_seen, last_seen, created_at) FROM stdin;
1	CUS0001	Hà	Hoàng	0913940129	customer0001@gmail.com	986202124371	220 Demo Street	2001-05-17	25	18_24	female	Khách hàng seed để test UI	HN_CG	440768.72	2025-10-22 15:07:51.876256+00	2026-03-24 01:15:51.876256+00	2026-03-17 01:44:51.876256+00
2	CUS0002	Huy	Phan	0944241100	customer0002@gmail.com	214990572280	294 Demo Street	1998-11-24	28	18_24	male	Khách hàng seed để test UI	HN_CG	268265.21	2026-03-20 17:23:51.876828+00	2026-03-31 02:15:51.876828+00	2025-12-23 13:27:51.876828+00
3	CUS0003	Bình	Vũ	0953191535	customer0003@gmail.com	556332815629	164 Demo Street	1994-05-27	32	18_24	unisex	Khách hàng seed để test UI	HCM_Q7	124178.34	2025-10-10 16:27:51.876828+00	2026-03-28 01:36:51.876828+00	2025-12-19 14:42:51.876828+00
4	CUS0004	Quân	Hoàng	0953929586	customer0004@gmail.com	705961411719	234 Demo Street	1989-01-12	37	25_34	female	Khách hàng seed để test UI	HN_CG	370267.67	2025-10-23 10:09:51.876828+00	2026-03-25 23:07:51.876828+00	2026-02-08 17:41:51.876828+00
5	CUS0005	Lan	Lê	0965034115	customer0005@gmail.com	353505764245	278 Demo Street	2008-06-21	18	18_24	female	Khách hàng seed để test UI	HCM_Q1	360803.79	2025-12-24 17:52:51.876828+00	2026-03-27 14:25:51.876828+00	2025-11-16 10:12:51.876828+00
6	CUS0006	Trang	Nguyễn	0947557512	customer0006@gmail.com	147644186640	119 Demo Street	1999-09-14	27	35_44	female	Khách hàng seed để test UI	HN_CG	111413.89	2026-03-07 01:30:51.877411+00	2026-03-21 05:34:51.877411+00	2025-10-30 23:35:51.877411+00
7	CUS0007	Phúc	Lê	0949148093	customer0007@gmail.com	532936211675	168 Demo Street	1993-06-15	33	35_44	male	Khách hàng seed để test UI	HCM_Q1	429115.23	2026-02-24 23:32:51.877411+00	2026-03-29 14:28:51.877411+00	2025-12-06 03:18:51.877411+00
8	CUS0008	Phúc	Trần	0958088526	customer0008@gmail.com	950251631900	107 Demo Street	1974-08-10	52	45_54	female	Khách hàng seed để test UI	HCM_Q1	113455.73	2025-10-07 07:46:51.877411+00	2026-03-22 16:25:51.877411+00	2026-01-07 13:33:51.877411+00
9	CUS0009	Lan	Phan	0978915391	customer0009@gmail.com	843239583508	154 Demo Street	1983-05-27	43	25_34	male	Khách hàng seed để test UI	HCM_Q7	396202.48	2025-11-08 18:03:51.877411+00	2026-03-28 14:09:51.877411+00	2026-03-05 13:31:51.877411+00
10	CUS0010	An	Nguyễn	0927544302	customer0010@gmail.com	509742378907	44 Demo Street	1994-10-19	32	35_44	male	Khách hàng seed để test UI	HCM_Q1	448949.73	2026-02-08 21:10:51.877411+00	2026-03-29 14:41:51.877411+00	2026-01-06 14:36:51.877411+00
11	CUS0011	Quân	Nguyễn	0987025433	customer0011@gmail.com	536903103710	255 Demo Street	1998-01-13	28	45_54	male	Khách hàng seed để test UI	HCM_Q7	159444.96	2026-02-12 09:21:51.877411+00	2026-03-24 13:36:51.877411+00	2025-10-24 21:59:51.877411+00
12	CUS0012	Lan	Hoàng	0965296657	customer0012@gmail.com	705086926545	246 Demo Street	1977-01-03	49	35_44	female	Khách hàng seed để test UI	HCM_Q1	235116.88	2025-10-18 01:23:51.878033+00	2026-03-20 23:48:51.878033+00	2026-03-27 04:48:51.878033+00
13	CUS0013	Nam	Đặng	0975052579	customer0013@gmail.com	652185266920	165 Demo Street	1974-07-09	52	25_34	male	Khách hàng seed để test UI	HCM_Q7	300933.05	2026-03-24 09:35:51.878033+00	2026-03-24 01:16:51.878033+00	2025-11-02 10:28:51.878033+00
14	CUS0014	Dũng	Phạm	0945772648	customer0014@gmail.com	995645376775	29 Demo Street	1993-04-19	33	45_54	female	Khách hàng seed để test UI	HCM_Q1	145157.14	2025-10-31 06:47:51.878033+00	2026-03-25 23:37:51.878033+00	2025-10-01 19:16:51.878033+00
15	CUS0015	Hà	Phạm	0982762732	customer0015@gmail.com	290305933879	252 Demo Street	1977-01-03	49	18_24	male	Khách hàng seed để test UI	HN_CG	160959.31	2025-11-17 02:38:51.878033+00	2026-03-25 22:26:51.878033+00	2026-02-26 06:53:51.878033+00
16	CUS0016	Huy	Phan	0912941099	customer0016@gmail.com	744879512673	73 Demo Street	2005-02-28	21	35_44	male	Khách hàng seed để test UI	HCM_Q7	340679.06	2025-10-13 05:01:51.878033+00	2026-03-30 07:19:51.878033+00	2026-01-08 13:28:51.878627+00
17	CUS0017	Phúc	Đặng	0933381086	customer0017@gmail.com	862622885564	183 Demo Street	1988-04-22	38	25_34	female	Khách hàng seed để test UI	HCM_Q7	351578.14	2026-01-15 13:27:51.878627+00	2026-03-30 19:02:51.878627+00	2025-12-20 23:36:51.878627+00
18	CUS0018	Huy	Phan	0995851936	customer0018@gmail.com	214098169516	255 Demo Street	1994-03-11	32	18_24	male	Khách hàng seed để test UI	HCM_Q7	443480.47	2026-02-16 20:42:51.878627+00	2026-03-29 18:56:51.878627+00	2025-10-18 17:42:51.878627+00
19	CUS0019	My	Đặng	0945596211	customer0019@gmail.com	371483526792	35 Demo Street	2008-06-09	18	18_24	unisex	Khách hàng seed để test UI	HCM_Q1	97814.56	2025-12-08 18:12:51.878627+00	2026-03-29 04:07:51.878627+00	2025-12-25 06:04:51.878627+00
20	CUS0020	Ngọc	Trần	0987585294	customer0020@gmail.com	936019548415	116 Demo Street	1978-03-15	48	18_24	male	Khách hàng seed để test UI	HCM_Q7	87428.86	2026-01-24 14:34:51.878627+00	2026-03-26 11:42:51.878627+00	2025-12-25 11:52:51.878627+00
21	CUS0021	Chi	Trần	0989729429	customer0021@gmail.com	778541594085	248 Demo Street	1987-12-01	39	45_54	unisex	Khách hàng seed để test UI	HCM_Q1	304707.52	2025-12-10 12:35:51.87915+00	2026-03-30 07:25:51.87915+00	2026-02-11 03:54:51.87915+00
22	CUS0022	Linh	Hoàng	0941883191	customer0022@gmail.com	151951563323	202 Demo Street	1989-10-18	37	45_54	male	Khách hàng seed để test UI	HCM_Q1	213506.7	2025-12-12 15:20:51.87915+00	2026-03-20 21:00:51.87915+00	2025-11-29 11:32:51.87915+00
23	CUS0023	An	Phạm	0995656500	customer0023@gmail.com	620042955668	60 Demo Street	1998-05-26	28	45_54	female	Khách hàng seed để test UI	HCM_Q7	411104.67	2026-01-23 14:57:51.87915+00	2026-03-23 05:27:51.87915+00	2025-12-27 05:15:51.87915+00
24	CUS0024	Huy	Đặng	0945338986	customer0024@gmail.com	612989778945	135 Demo Street	2006-04-27	20	35_44	unisex	Khách hàng seed để test UI	HCM_Q1	135918.35	2025-10-03 20:32:51.87915+00	2026-03-29 20:16:51.87915+00	2025-11-13 03:50:51.87915+00
25	CUS0025	Lan	Nguyễn	0980139805	customer0025@gmail.com	853919293672	244 Demo Street	1984-10-08	42	45_54	female	Khách hàng seed để test UI	HCM_Q1	226077.62	2026-03-23 01:02:51.87915+00	2026-03-22 22:55:51.87915+00	2025-10-24 13:31:51.87915+00
26	CUS0026	Quân	Lê	0938439415	customer0026@gmail.com	313925709865	65 Demo Street	1998-01-14	28	18_24	unisex	Khách hàng seed để test UI	HCM_Q7	154710.13	2025-10-22 12:45:51.87915+00	2026-03-22 09:18:51.87915+00	2026-03-14 15:14:51.879782+00
27	CUS0027	Ngọc	Phan	0979751366	customer0027@gmail.com	116636410911	268 Demo Street	1991-07-04	35	45_54	male	Khách hàng seed để test UI	HCM_Q1	289639.75	2025-11-02 13:39:51.879782+00	2026-03-29 22:49:51.879782+00	2026-03-06 07:43:51.879782+00
28	CUS0028	Nam	Vũ	0961411224	customer0028@gmail.com	635388236349	293 Demo Street	1992-10-16	34	18_24	male	Khách hàng seed để test UI	HCM_Q7	229100.36	2025-10-23 21:55:51.879782+00	2026-03-25 16:13:51.879782+00	2026-01-05 19:23:51.879782+00
29	CUS0029	Bình	Đặng	0959988144	customer0029@gmail.com	469454087066	156 Demo Street	1991-05-09	35	45_54	unisex	Khách hàng seed để test UI	HN_CG	116340.43	2026-02-01 13:19:51.879782+00	2026-03-24 07:21:51.879782+00	2025-12-14 21:57:51.879782+00
30	CUS0030	Chi	Phạm	0938372352	customer0030@gmail.com	913497602318	249 Demo Street	1980-09-28	46	35_44	male	Khách hàng seed để test UI	HN_CG	372851.45	2026-03-15 07:53:51.879782+00	2026-03-23 05:30:51.879782+00	2025-11-16 23:37:51.879782+00
31	CUS0031	Huy	Phạm	0917734634	customer0031@gmail.com	135431290900	234 Demo Street	1996-01-12	30	25_34	female	Khách hàng seed để test UI	HCM_Q7	384697.33	2025-11-22 04:58:51.880373+00	2026-03-29 20:37:51.880373+00	2026-01-29 06:07:51.880373+00
32	CUS0032	Quân	Lê	0988769733	customer0032@gmail.com	484620049657	177 Demo Street	1978-03-27	48	35_44	unisex	Khách hàng seed để test UI	HN_CG	113445.01	2026-03-24 05:35:51.880373+00	2026-03-28 22:49:51.880373+00	2026-02-05 09:57:51.880373+00
33	CUS0033	Lan	Phạm	0997454571	customer0033@gmail.com	664399535800	11 Demo Street	1991-11-01	35	45_54	male	Khách hàng seed để test UI	HN_CG	144084.24	2026-03-29 10:22:51.880373+00	2026-03-22 07:53:51.880373+00	2025-10-18 09:11:51.880373+00
34	CUS0034	Ngọc	Phan	0943822694	customer0034@gmail.com	612038308984	155 Demo Street	1979-11-17	47	45_54	unisex	Khách hàng seed để test UI	HCM_Q1	82718.6	2025-10-13 06:03:51.880373+00	2026-03-20 22:00:51.880373+00	2026-01-18 07:55:51.880373+00
35	CUS0035	Dũng	Đặng	0955135227	customer0035@gmail.com	404892688739	167 Demo Street	2004-05-09	22	35_44	male	Khách hàng seed để test UI	HCM_Q1	271398.63	2026-01-29 15:47:51.880373+00	2026-03-22 04:56:51.880373+00	2026-01-08 20:30:51.880373+00
36	CUS0036	An	Đặng	0944819604	customer0036@gmail.com	563456656182	208 Demo Street	1990-07-24	36	18_24	unisex	Khách hàng seed để test UI	HN_CG	448058.88	2026-02-11 06:52:51.880373+00	2026-03-27 20:04:51.880373+00	2025-10-19 01:40:51.880373+00
37	CUS0037	Nam	Hoàng	0998263548	customer0037@gmail.com	713649872479	93 Demo Street	1998-05-04	28	45_54	male	Khách hàng seed để test UI	HN_CG	175701.18	2025-11-08 11:55:51.880961+00	2026-03-25 21:33:51.880961+00	2026-02-03 06:24:51.880961+00
38	CUS0038	Minh	Vũ	0959886371	customer0038@gmail.com	741069220481	151 Demo Street	1987-08-28	39	18_24	female	Khách hàng seed để test UI	HCM_Q1	400565.55	2025-11-01 22:59:51.880961+00	2026-03-30 01:42:51.880961+00	2026-02-10 01:31:51.880961+00
39	CUS0039	Ngọc	Hoàng	0917256074	customer0039@gmail.com	250971443883	103 Demo Street	1982-06-14	44	45_54	male	Khách hàng seed để test UI	HCM_Q7	399085.76	2026-02-13 15:07:51.880961+00	2026-03-25 21:27:51.880961+00	2026-01-09 21:35:51.880961+00
40	CUS0040	An	Đặng	0938102825	customer0040@gmail.com	953672824861	87 Demo Street	1991-10-25	35	25_34	female	Khách hàng seed để test UI	HCM_Q1	127880.2	2025-12-09 21:11:51.880961+00	2026-03-25 04:08:51.880961+00	2025-12-23 17:36:51.880961+00
41	CUS0041	Khánh	Phan	0953246714	customer0041@gmail.com	308439202956	10 Demo Street	2008-11-01	18	25_34	male	Khách hàng seed để test UI	HN_CG	404484.5	2026-01-11 13:32:51.880961+00	2026-03-25 01:01:51.880961+00	2026-01-12 12:34:51.880961+00
42	CUS0042	Bình	Hoàng	0971193393	customer0042@gmail.com	674356664610	269 Demo Street	1990-06-14	36	25_34	female	Khách hàng seed để test UI	HCM_Q7	212922.83	2026-02-11 11:40:51.881537+00	2026-03-25 17:24:51.881537+00	2026-02-01 18:30:51.881537+00
43	CUS0043	Khánh	Nguyễn	0932680748	customer0043@gmail.com	499960935218	20 Demo Street	1976-07-21	50	35_44	unisex	Khách hàng seed để test UI	HN_CG	97977.18	2026-03-18 20:32:51.881537+00	2026-03-21 17:35:51.881537+00	2025-10-06 14:12:51.881537+00
44	CUS0044	Quân	Vũ	0983454998	customer0044@gmail.com	620776545528	79 Demo Street	2001-04-23	25	18_24	female	Khách hàng seed để test UI	HCM_Q7	324815.89	2025-10-13 01:21:51.881537+00	2026-03-21 21:54:51.881537+00	2026-02-24 03:45:51.881537+00
45	CUS0045	Dũng	Trần	0925302505	customer0045@gmail.com	219334635833	255 Demo Street	1990-04-20	36	25_34	female	Khách hàng seed để test UI	HN_CG	440054.3	2025-12-29 19:12:51.881537+00	2026-03-27 12:36:51.881537+00	2025-11-11 01:40:51.881537+00
46	CUS0046	Khánh	Đặng	0941474764	customer0046@gmail.com	112896661519	46 Demo Street	1987-02-27	39	45_54	male	Khách hàng seed để test UI	HCM_Q1	368424.7	2026-03-11 17:52:51.881537+00	2026-03-30 08:57:51.881537+00	2026-01-31 03:20:51.881537+00
47	CUS0047	Linh	Đặng	0923396125	customer0047@gmail.com	292471135737	21 Demo Street	2005-05-12	21	35_44	female	Khách hàng seed để test UI	HN_CG	122883.39	2026-03-20 16:44:51.882119+00	2026-03-28 19:57:51.882119+00	2026-02-16 07:16:51.882119+00
48	CUS0048	Quân	Hoàng	0960012498	customer0048@gmail.com	477162399720	94 Demo Street	2003-02-13	23	45_54	female	Khách hàng seed để test UI	HCM_Q7	389212.09	2025-10-06 01:47:51.882119+00	2026-03-24 20:42:51.882119+00	2026-02-17 14:30:51.882119+00
49	CUS0049	Bình	Lê	0965838294	customer0049@gmail.com	752453750816	248 Demo Street	2002-10-22	24	45_54	male	Khách hàng seed để test UI	HN_CG	220507.79	2025-12-29 22:37:51.882119+00	2026-03-20 17:41:51.882119+00	2026-02-26 01:40:51.882119+00
50	CUS0050	Trang	Trần	0969148126	customer0050@gmail.com	168916926394	134 Demo Street	1982-11-11	44	18_24	unisex	Khách hàng seed để test UI	HN_CG	274182.63	2025-11-03 18:02:51.882119+00	2026-03-27 19:43:51.882119+00	2026-01-04 01:05:51.882119+00
51	CUS0051	Dũng	Vũ	0974683506	customer0051@gmail.com	827334455774	198 Demo Street	1993-03-27	33	18_24	male	Khách hàng seed để test UI	HN_CG	425717.43	2025-11-22 01:44:51.882119+00	2026-03-24 12:34:51.882119+00	2025-11-26 07:23:51.882119+00
52	CUS0052	My	Hoàng	0978038903	customer0052@gmail.com	702251938661	194 Demo Street	2005-07-27	21	25_34	male	Khách hàng seed để test UI	HCM_Q7	244349.88	2025-11-05 03:33:51.882704+00	2026-03-24 03:18:51.882704+00	2026-03-01 01:51:51.882704+00
53	CUS0053	An	Trần	0965343143	customer0053@gmail.com	710039252993	282 Demo Street	1983-01-27	43	18_24	unisex	Khách hàng seed để test UI	HN_CG	315889.11	2025-11-21 00:25:51.882704+00	2026-03-20 20:09:51.882704+00	2026-01-03 05:46:51.882704+00
54	CUS0054	Bình	Phạm	0954556611	customer0054@gmail.com	944219419581	243 Demo Street	1979-12-22	47	35_44	unisex	Khách hàng seed để test UI	HCM_Q7	122188.64	2025-10-14 10:38:51.882704+00	2026-03-26 05:45:51.882704+00	2025-10-20 08:03:51.882704+00
55	CUS0055	Vy	Phan	0916144233	customer0055@gmail.com	284240684348	253 Demo Street	2002-03-27	24	45_54	male	Khách hàng seed để test UI	HCM_Q7	306015.15	2026-02-11 13:39:51.882704+00	2026-03-25 11:09:51.882704+00	2026-02-10 19:17:51.882704+00
56	CUS0056	Dũng	Vũ	0994992096	customer0056@gmail.com	842331265000	64 Demo Street	2006-08-15	20	25_34	female	Khách hàng seed để test UI	HCM_Q1	276234.81	2026-03-18 23:39:51.882704+00	2026-03-24 23:08:51.882704+00	2025-11-21 11:54:51.882704+00
57	CUS0057	Huy	Lê	0961996696	customer0057@gmail.com	759954030945	165 Demo Street	2002-09-13	24	45_54	unisex	Khách hàng seed để test UI	HN_CG	362078.62	2026-01-20 05:17:51.882704+00	2026-03-27 02:47:51.883293+00	2026-02-25 13:12:51.883293+00
58	CUS0058	Vy	Hoàng	0952132393	customer0058@gmail.com	910511328725	284 Demo Street	1973-11-07	53	25_34	male	Khách hàng seed để test UI	HN_CG	344322.28	2025-10-07 05:40:51.883293+00	2026-03-21 12:53:51.883293+00	2025-10-16 12:06:51.883293+00
59	CUS0059	My	Trần	0985467972	customer0059@gmail.com	742013300223	293 Demo Street	1986-11-23	40	45_54	unisex	Khách hàng seed để test UI	HN_CG	410730.42	2025-11-15 07:42:51.883293+00	2026-03-25 17:05:51.883293+00	2026-03-04 17:14:51.883293+00
60	CUS0060	Hà	Nguyễn	0936830448	customer0060@gmail.com	925780383750	83 Demo Street	2005-05-22	21	35_44	male	Khách hàng seed để test UI	HCM_Q1	335520.09	2026-01-15 10:50:51.883293+00	2026-03-23 16:16:51.883293+00	2025-12-06 13:59:51.883293+00
\.


--
-- Data for Name: edge_devices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.edge_devices (id, branch_id, name, description, ip_address, status, last_seen, created_at) FROM stdin;
EDGE_HCM_Q1_01	HCM_Q1	Edge Cam Q1 - 01	Thiết bị edge nhận diện tại cửa vào	192.168.1.11	active	2026-03-31 17:38:50.984408	2026-03-31 17:38:50.987606
EDGE_HCM_Q7_01	HCM_Q7	Edge Cam Q7 - 01	Thiết bị edge nhận diện tại quầy thanh toán	192.168.1.21	active	2026-03-31 17:38:50.985146	2026-03-31 17:38:50.987606
EDGE_HN_CG_01	HN_CG	Edge Cam Cầu Giấy - 01	Thiết bị edge nhận diện tại cửa vào	192.168.1.31	active	2026-03-31 17:38:50.985865	2026-03-31 17:38:50.987606
\.


--
-- Data for Name: face_embeddings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.face_embeddings (id, customer_id, embedding, created_at) FROM stdin;
\.


--
-- Data for Name: face_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.face_events (id, branch_id, device_id, event_type, "timestamp", customer_id, similarity, face_attributes, transaction_id, created_at) FROM stdin;
1	HN_CG	EDGE_HN_CG_01	no_face	2026-02-20 12:09:14.118651+00	6	0.75	{"age_group": "35_44", "gender": "female"}	TXN-20260220-00001	2026-02-20 12:15:14.118651+00
2	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-02-28 01:57:14.132516+00	\N	0.79	{"age_group": "25_34", "gender": "female"}	TXN-20260228-00002	2026-02-28 02:05:14.132516+00
3	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-09 16:15:14.15531+00	\N	0.81	{"age_group": "35_44", "gender": "male"}	TXN-20260309-00003	2026-03-09 16:30:14.15531+00
4	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-04 00:19:14.165717+00	\N	0.88	{"age_group": "45_54", "gender": "unisex"}	TXN-20260304-00004	2026-03-04 00:35:14.165717+00
5	HN_CG	EDGE_HN_CG_01	face_recognized	2026-02-20 05:25:14.176984+00	55	0.75	{"age_group": "45_54", "gender": "male"}	TXN-20260220-00005	2026-02-20 05:40:14.176984+00
6	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-30 21:08:14.188043+00	22	0.73	{"age_group": "45_54", "gender": "male"}	TXN-20260330-00006	2026-03-30 21:27:14.188043+00
7	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-23 02:23:14.20472+00	22	0.81	{"age_group": "45_54", "gender": "male"}	TXN-20260323-00007	2026-03-23 02:30:14.20472+00
8	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-02-18 23:36:14.217184+00	\N	\N	{"age_group": "25_34", "gender": "female"}	TXN-20260218-00008	2026-02-18 23:46:14.217184+00
9	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-02-27 16:41:14.227101+00	\N	0.84	{"age_group": "18_24", "gender": "unisex"}	TXN-20260227-00009	2026-02-27 16:48:14.227101+00
10	HN_CG	EDGE_HN_CG_01	no_face	2026-02-21 15:11:14.23688+00	60	0.77	{"age_group": "35_44", "gender": "male"}	TXN-20260221-00010	2026-02-21 15:18:14.23688+00
11	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-22 12:16:14.24567+00	43	0.88	{"age_group": "35_44", "gender": "unisex"}	TXN-20260322-00011	2026-03-22 12:22:14.24567+00
12	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-28 14:57:14.254948+00	2	0.74	{"age_group": "18_24", "gender": "male"}	TXN-20260328-00012	2026-03-28 15:12:14.254948+00
13	HN_CG	EDGE_HN_CG_01	no_face	2026-02-20 08:35:14.262969+00	20	0.81	{"age_group": "18_24", "gender": "male"}	TXN-20260220-00013	2026-02-20 08:41:14.262969+00
14	HN_CG	EDGE_HN_CG_01	face_recognized	2026-02-23 21:24:14.272251+00	26	0.9	{"age_group": "18_24", "gender": "unisex"}	TXN-20260223-00014	2026-02-23 21:35:14.272251+00
15	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-26 17:29:14.283835+00	22	0.89	{"age_group": "45_54", "gender": "male"}	TXN-20260326-00015	2026-03-26 17:40:14.283835+00
16	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-22 03:00:14.294506+00	\N	\N	{"age_group": "35_44", "gender": "male"}	TXN-20260322-00016	2026-03-22 03:05:14.294506+00
17	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-16 03:43:14.305518+00	\N	0.76	{"age_group": "18_24", "gender": "unisex"}	TXN-20260316-00017	2026-03-16 03:55:14.305518+00
18	HN_CG	EDGE_HN_CG_01	no_face	2026-02-27 19:59:14.315636+00	5	0.77	{"age_group": "18_24", "gender": "female"}	TXN-20260227-00018	2026-02-27 20:12:14.315636+00
19	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-14 03:35:14.324943+00	\N	0.86	{"age_group": "45_54", "gender": "male"}	TXN-20260314-00019	2026-03-14 03:40:14.324943+00
20	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-02-16 20:23:14.334038+00	\N	0.93	{"age_group": "45_54", "gender": "unisex"}	TXN-20260216-00020	2026-02-16 20:35:14.334038+00
21	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-15 15:54:14.342716+00	60	0.79	{"age_group": "35_44", "gender": "male"}	TXN-20260315-00021	2026-03-15 15:59:14.342716+00
22	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-21 19:55:14.3519+00	\N	0.83	{"age_group": "45_54", "gender": "male"}	TXN-20260321-00022	2026-03-21 20:11:14.3519+00
23	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-09 15:45:14.361431+00	47	0.76	{"age_group": "35_44", "gender": "female"}	TXN-20260309-00023	2026-03-09 15:58:14.361431+00
24	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-02-16 16:16:14.369984+00	52	0.9	{"age_group": "25_34", "gender": "male"}	TXN-20260216-00024	2026-02-16 16:33:14.369984+00
25	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-31 04:13:14.378846+00	44	0.94	{"age_group": "18_24", "gender": "female"}	TXN-20260331-00025	2026-03-31 04:33:14.378846+00
26	HN_CG	EDGE_HN_CG_01	no_face	2026-03-23 04:48:14.388386+00	\N	0.9	{"age_group": "45_54", "gender": "female"}	TXN-20260323-00026	2026-03-23 04:57:14.388386+00
27	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-28 04:59:14.396564+00	50	0.86	{"age_group": "18_24", "gender": "unisex"}	TXN-20260328-00027	2026-03-28 05:15:14.396564+00
28	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-27 14:58:14.404976+00	\N	0.96	{"age_group": "35_44", "gender": "male"}	TXN-20260327-00028	2026-03-27 15:03:14.404976+00
29	HN_CG	EDGE_HN_CG_01	no_face	2026-03-27 00:22:14.413933+00	\N	0.92	{"age_group": "18_24", "gender": "unisex"}	TXN-20260327-00029	2026-03-27 00:25:14.413933+00
30	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-07 13:46:14.424241+00	3	0.86	{"age_group": "18_24", "gender": "unisex"}	TXN-20260307-00030	2026-03-07 13:59:14.424241+00
31	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-09 18:36:14.433793+00	54	0.96	{"age_group": "35_44", "gender": "unisex"}	TXN-20260309-00031	2026-03-09 18:37:14.433793+00
32	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-02-19 15:26:14.442963+00	9	0.88	{"age_group": "25_34", "gender": "male"}	TXN-20260219-00032	2026-02-19 15:42:14.442963+00
33	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-02-25 13:04:14.453237+00	52	0.87	{"age_group": "25_34", "gender": "male"}	TXN-20260225-00033	2026-02-25 13:19:14.453237+00
34	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-26 17:25:14.461893+00	41	0.77	{"age_group": "25_34", "gender": "male"}	TXN-20260326-00034	2026-03-26 17:39:14.461893+00
35	HN_CG	EDGE_HN_CG_01	no_face	2026-03-12 06:11:14.472206+00	46	0.93	{"age_group": "45_54", "gender": "male"}	TXN-20260312-00035	2026-03-12 06:13:14.472206+00
36	HN_CG	EDGE_HN_CG_01	face_recognized	2026-02-18 06:20:14.481737+00	11	0.75	{"age_group": "45_54", "gender": "male"}	TXN-20260218-00036	2026-02-18 06:21:14.481737+00
37	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-17 14:14:14.491143+00	21	0.88	{"age_group": "45_54", "gender": "unisex"}	TXN-20260317-00037	2026-03-17 14:19:14.491143+00
38	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-14 11:07:14.499686+00	30	0.8	{"age_group": "35_44", "gender": "male"}	TXN-20260314-00038	2026-03-14 11:18:14.499686+00
39	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-02-26 01:25:14.508959+00	\N	0.96	{"age_group": "18_24", "gender": "unisex"}	TXN-20260226-00039	2026-02-26 01:44:14.508959+00
40	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-02-27 16:04:14.518193+00	\N	\N	{"age_group": "18_24", "gender": "male"}	TXN-20260227-00040	2026-02-27 16:12:14.518193+00
41	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-22 19:11:14.528944+00	30	0.81	{"age_group": "35_44", "gender": "male"}	TXN-20260322-00041	2026-03-22 19:14:14.528944+00
42	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-08 02:42:14.540657+00	\N	\N	{"age_group": "18_24", "gender": "female"}	TXN-20260308-00042	2026-03-08 03:00:14.540657+00
43	HN_CG	EDGE_HN_CG_01	no_face	2026-03-14 00:41:14.549397+00	49	0.93	{"age_group": "45_54", "gender": "male"}	TXN-20260314-00043	2026-03-14 00:56:14.549397+00
44	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-13 15:17:14.557926+00	57	0.84	{"age_group": "45_54", "gender": "unisex"}	TXN-20260313-00044	2026-03-13 15:33:14.557926+00
45	HN_CG	EDGE_HN_CG_01	face_recognized	2026-02-25 21:08:14.567284+00	5	0.79	{"age_group": "18_24", "gender": "female"}	TXN-20260225-00045	2026-02-25 21:18:14.567284+00
46	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-09 08:08:14.575394+00	\N	\N	{"age_group": "35_44", "gender": "male"}	TXN-20260309-00046	2026-03-09 08:10:14.575394+00
47	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-22 06:01:14.582922+00	14	0.8	{"age_group": "45_54", "gender": "female"}	TXN-20260322-00047	2026-03-22 06:11:14.582922+00
48	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-01 16:30:14.590249+00	47	0.94	{"age_group": "35_44", "gender": "female"}	TXN-20260301-00048	2026-03-01 16:31:14.590249+00
49	HN_CG	EDGE_HN_CG_01	no_face	2026-02-21 01:22:14.600486+00	\N	\N	{"age_group": "45_54", "gender": "female"}	TXN-20260221-00049	2026-02-21 01:36:14.600486+00
50	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-26 13:07:14.608082+00	\N	0.76	{"age_group": "45_54", "gender": "male"}	TXN-20260326-00050	2026-03-26 13:26:14.608082+00
51	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-02-22 07:58:14.617622+00	32	0.85	{"age_group": "35_44", "gender": "unisex"}	TXN-20260222-00051	2026-02-22 08:08:14.617622+00
52	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-07 23:04:14.624829+00	49	0.95	{"age_group": "45_54", "gender": "male"}	TXN-20260307-00052	2026-03-07 23:09:14.624829+00
53	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-28 08:09:14.633055+00	18	0.87	{"age_group": "18_24", "gender": "male"}	TXN-20260328-00053	2026-03-28 08:21:14.633055+00
54	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-10 12:19:14.640057+00	19	0.74	{"age_group": "18_24", "gender": "unisex"}	TXN-20260310-00054	2026-03-10 12:33:14.640057+00
55	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-02-26 07:23:14.649728+00	20	0.98	{"age_group": "18_24", "gender": "male"}	TXN-20260226-00055	2026-02-26 07:28:14.649728+00
56	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-25 15:30:14.657874+00	\N	0.77	{"age_group": "18_24", "gender": "unisex"}	TXN-20260325-00056	2026-03-25 15:49:14.657874+00
57	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-21 00:44:14.666418+00	\N	0.86	{"age_group": "45_54", "gender": "male"}	TXN-20260321-00057	2026-03-21 00:50:14.666418+00
58	HN_CG	EDGE_HN_CG_01	no_face	2026-03-20 02:44:14.67696+00	\N	\N	{"age_group": "35_44", "gender": "male"}	TXN-20260320-00058	2026-03-20 02:56:14.67696+00
59	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-11 19:33:14.687475+00	25	0.89	{"age_group": "45_54", "gender": "female"}	TXN-20260311-00059	2026-03-11 19:46:14.687475+00
60	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-19 07:11:14.696642+00	26	0.97	{"age_group": "18_24", "gender": "unisex"}	TXN-20260319-00060	2026-03-19 07:27:14.696642+00
61	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-15 02:02:14.70518+00	30	0.9	{"age_group": "35_44", "gender": "male"}	TXN-20260315-00061	2026-03-15 02:08:14.70518+00
62	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-02-26 01:45:14.714027+00	7	0.8	{"age_group": "35_44", "gender": "male"}	TXN-20260226-00062	2026-02-26 01:49:14.714027+00
63	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-11 19:11:14.723443+00	\N	0.85	{"age_group": "18_24", "gender": "unisex"}	TXN-20260311-00063	2026-03-11 19:29:14.723443+00
64	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-28 16:52:14.73356+00	25	0.96	{"age_group": "45_54", "gender": "female"}	TXN-20260328-00064	2026-03-28 17:02:14.73356+00
65	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-11 15:51:14.743752+00	11	0.85	{"age_group": "45_54", "gender": "male"}	TXN-20260311-00065	2026-03-11 16:10:14.743752+00
66	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-08 04:08:14.755177+00	33	0.74	{"age_group": "45_54", "gender": "male"}	TXN-20260308-00066	2026-03-08 04:27:14.755177+00
67	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-12 00:29:14.765715+00	23	0.89	{"age_group": "45_54", "gender": "female"}	TXN-20260312-00067	2026-03-12 00:48:14.765715+00
68	HN_CG	EDGE_HN_CG_01	no_face	2026-02-19 15:56:14.774853+00	41	0.79	{"age_group": "25_34", "gender": "male"}	TXN-20260219-00068	2026-02-19 16:06:14.774853+00
69	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-16 08:08:14.783062+00	\N	0.85	{"age_group": "45_54", "gender": "female"}	TXN-20260316-00069	2026-03-16 08:10:14.783062+00
70	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-02-21 07:27:14.792585+00	\N	\N	{"age_group": "35_44", "gender": "female"}	TXN-20260221-00070	2026-02-21 07:44:14.792585+00
71	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-06 17:36:14.80284+00	50	0.9	{"age_group": "18_24", "gender": "unisex"}	TXN-20260306-00071	2026-03-06 17:52:14.80284+00
72	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-22 06:00:14.810381+00	31	0.8	{"age_group": "25_34", "gender": "female"}	TXN-20260322-00072	2026-03-22 06:09:14.810381+00
73	HN_CG	EDGE_HN_CG_01	no_face	2026-03-16 03:13:14.819564+00	\N	\N	{"age_group": "35_44", "gender": "male"}	TXN-20260316-00073	2026-03-16 03:15:14.819564+00
74	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-20 19:22:14.828745+00	60	0.88	{"age_group": "35_44", "gender": "male"}	TXN-20260320-00074	2026-03-20 19:23:14.828745+00
75	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-02-20 20:12:14.83778+00	\N	0.96	{"age_group": "35_44", "gender": "male"}	TXN-20260220-00075	2026-02-20 20:13:14.83778+00
76	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-28 04:53:14.84652+00	\N	\N	{"age_group": "25_34", "gender": "female"}	TXN-20260328-00076	2026-03-28 05:00:14.84652+00
77	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-12 17:44:14.85704+00	28	0.89	{"age_group": "18_24", "gender": "male"}	TXN-20260312-00077	2026-03-12 17:56:14.85704+00
78	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-17 19:03:14.86732+00	\N	0.96	{"age_group": "25_34", "gender": "female"}	TXN-20260317-00078	2026-03-17 19:15:14.86732+00
79	HN_CG	EDGE_HN_CG_01	no_face	2026-03-23 00:35:14.876467+00	\N	0.85	{"age_group": "45_54", "gender": "male"}	TXN-20260323-00079	2026-03-23 00:37:14.876467+00
80	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-15 01:11:14.887002+00	\N	\N	{"age_group": "25_34", "gender": "male"}	TXN-20260315-00080	2026-03-15 01:19:14.887002+00
81	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-08 18:47:14.897253+00	\N	0.87	{"age_group": "35_44", "gender": "male"}	TXN-20260308-00081	2026-03-08 19:04:14.897253+00
82	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-16 01:55:14.907475+00	1	0.94	{"age_group": "18_24", "gender": "female"}	TXN-20260316-00082	2026-03-16 01:56:14.907475+00
83	HN_CG	EDGE_HN_CG_01	face_recognized	2026-02-20 03:11:14.918028+00	\N	0.95	{"age_group": "18_24", "gender": "male"}	TXN-20260220-00083	2026-02-20 03:19:14.918028+00
84	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-06 07:43:14.931767+00	\N	\N	{"age_group": "45_54", "gender": "female"}	TXN-20260306-00084	2026-03-06 07:58:14.931767+00
85	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-02-19 04:20:14.954065+00	28	0.93	{"age_group": "18_24", "gender": "male"}	TXN-20260219-00085	2026-02-19 04:34:14.954065+00
86	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-12 23:30:14.970242+00	\N	\N	{"age_group": "25_34", "gender": "female"}	TXN-20260312-00086	2026-03-12 23:36:14.970242+00
87	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-01 19:57:14.982209+00	46	0.72	{"age_group": "45_54", "gender": "male"}	TXN-20260301-00087	2026-03-01 20:11:14.982209+00
88	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-02-20 18:01:14.996615+00	31	0.76	{"age_group": "25_34", "gender": "female"}	TXN-20260220-00088	2026-02-20 18:08:14.996615+00
89	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-22 02:08:15.008764+00	\N	\N	{"age_group": "45_54", "gender": "female"}	TXN-20260322-00089	2026-03-22 02:12:15.008764+00
90	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-02-16 02:10:15.023329+00	26	0.73	{"age_group": "18_24", "gender": "unisex"}	TXN-20260216-00090	2026-02-16 02:25:15.023329+00
91	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-02-21 20:12:15.037506+00	29	0.79	{"age_group": "45_54", "gender": "unisex"}	TXN-20260221-00091	2026-02-21 20:18:15.037506+00
92	HN_CG	EDGE_HN_CG_01	no_face	2026-02-21 02:27:15.050751+00	9	0.94	{"age_group": "25_34", "gender": "male"}	TXN-20260221-00092	2026-02-21 02:33:15.050751+00
93	HN_CG	EDGE_HN_CG_01	no_face	2026-03-17 13:49:15.063296+00	\N	\N	{"age_group": "18_24", "gender": "male"}	TXN-20260317-00093	2026-03-17 14:04:15.063296+00
94	HN_CG	EDGE_HN_CG_01	no_face	2026-03-25 11:54:15.07448+00	\N	\N	{"age_group": "18_24", "gender": "male"}	TXN-20260325-00094	2026-03-25 11:59:15.07448+00
95	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-13 01:15:15.085718+00	1	0.83	{"age_group": "18_24", "gender": "female"}	TXN-20260313-00095	2026-03-13 01:29:15.085718+00
96	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-02-26 15:16:15.099166+00	\N	\N	{"age_group": "35_44", "gender": "female"}	TXN-20260226-00096	2026-02-26 15:34:15.099166+00
97	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-02-18 10:26:15.112782+00	\N	\N	{"age_group": "35_44", "gender": "female"}	TXN-20260218-00097	2026-02-18 10:43:15.112782+00
98	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-04 01:17:15.126701+00	57	0.78	{"age_group": "45_54", "gender": "unisex"}	TXN-20260304-00098	2026-03-04 01:32:15.126701+00
99	HN_CG	EDGE_HN_CG_01	no_face	2026-03-16 14:00:15.139985+00	19	0.92	{"age_group": "18_24", "gender": "unisex"}	TXN-20260316-00099	2026-03-16 14:19:15.139985+00
100	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-02-27 13:04:15.153026+00	29	0.87	{"age_group": "45_54", "gender": "unisex"}	TXN-20260227-00100	2026-02-27 13:08:15.153026+00
101	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-30 13:28:15.164644+00	20	0.87	{"age_group": "18_24", "gender": "male"}	TXN-20260330-00101	2026-03-30 13:30:15.164644+00
102	HN_CG	EDGE_HN_CG_01	no_face	2026-03-23 00:56:15.178212+00	\N	\N	{"age_group": "25_34", "gender": "male"}	TXN-20260323-00102	2026-03-23 00:59:15.178212+00
103	HN_CG	EDGE_HN_CG_01	no_face	2026-03-27 22:53:15.194693+00	8	0.85	{"age_group": "45_54", "gender": "female"}	TXN-20260327-00103	2026-03-27 23:06:15.194693+00
104	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-11 05:13:15.209137+00	\N	0.9	{"age_group": "45_54", "gender": "male"}	TXN-20260311-00104	2026-03-11 05:23:15.209137+00
105	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-07 14:02:15.221507+00	\N	0.82	{"age_group": "45_54", "gender": "male"}	TXN-20260307-00105	2026-03-07 14:19:15.221507+00
106	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-17 17:04:15.230909+00	\N	0.92	{"age_group": "35_44", "gender": "male"}	TXN-20260317-00106	2026-03-17 17:22:15.230909+00
107	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-12 21:16:15.24064+00	\N	\N	{"age_group": "18_24", "gender": "male"}	TXN-20260312-00107	2026-03-12 21:29:15.24064+00
108	HN_CG	EDGE_HN_CG_01	no_face	2026-03-10 20:17:15.252994+00	\N	\N	{"age_group": "18_24", "gender": "male"}	TXN-20260310-00108	2026-03-10 20:18:15.252994+00
109	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-02-17 21:20:15.265003+00	35	0.77	{"age_group": "35_44", "gender": "male"}	TXN-20260217-00109	2026-02-17 21:35:15.265003+00
110	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-19 14:46:15.274566+00	49	0.93	{"age_group": "45_54", "gender": "male"}	TXN-20260319-00110	2026-03-19 14:47:15.274566+00
111	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-02-16 17:45:15.284703+00	\N	\N	{"age_group": "35_44", "gender": "female"}	TXN-20260216-00111	2026-02-16 18:03:15.284703+00
112	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-04 04:04:15.296027+00	42	0.72	{"age_group": "25_34", "gender": "female"}	TXN-20260304-00112	2026-03-04 04:22:15.296027+00
113	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-16 18:56:15.305598+00	37	0.73	{"age_group": "45_54", "gender": "male"}	TXN-20260316-00113	2026-03-16 19:12:15.305598+00
114	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-16 06:44:15.313405+00	\N	\N	{"age_group": "18_24", "gender": "female"}	TXN-20260316-00114	2026-03-16 06:46:15.313405+00
115	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-04 15:18:15.320933+00	4	0.93	{"age_group": "25_34", "gender": "female"}	TXN-20260304-00115	2026-03-04 15:33:15.320933+00
116	HN_CG	EDGE_HN_CG_01	face_recognized	2026-02-26 06:45:15.329627+00	44	0.83	{"age_group": "18_24", "gender": "female"}	TXN-20260226-00116	2026-02-26 07:02:15.329627+00
117	HN_CG	EDGE_HN_CG_01	no_face	2026-03-23 07:50:15.338895+00	\N	0.85	{"age_group": "25_34", "gender": "male"}	TXN-20260323-00117	2026-03-23 08:02:15.338895+00
118	HN_CG	EDGE_HN_CG_01	no_face	2026-02-19 10:38:15.348461+00	33	0.84	{"age_group": "45_54", "gender": "male"}	TXN-20260219-00118	2026-02-19 10:49:15.348461+00
119	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-01 22:14:15.358281+00	1	0.75	{"age_group": "18_24", "gender": "female"}	TXN-20260301-00119	2026-03-01 22:26:15.358281+00
120	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-19 08:24:15.367844+00	38	0.77	{"age_group": "18_24", "gender": "female"}	TXN-20260319-00120	2026-03-19 08:28:15.367844+00
121	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-02-20 03:23:15.383791+00	24	0.89	{"age_group": "35_44", "gender": "unisex"}	TXN-20260220-00121	2026-02-20 03:43:15.383791+00
122	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-16 15:42:15.398062+00	\N	\N	{"age_group": "45_54", "gender": "male"}	TXN-20260316-00122	2026-03-16 15:59:15.398062+00
123	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-02-18 22:46:15.409612+00	31	0.74	{"age_group": "25_34", "gender": "female"}	TXN-20260218-00123	2026-02-18 22:58:15.409612+00
124	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-02 00:57:15.420859+00	23	0.74	{"age_group": "45_54", "gender": "female"}	TXN-20260302-00124	2026-03-02 01:00:15.420859+00
125	HN_CG	EDGE_HN_CG_01	no_face	2026-03-27 06:36:15.430833+00	\N	0.79	{"age_group": "35_44", "gender": "male"}	TXN-20260327-00125	2026-03-27 06:37:15.430833+00
126	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-22 05:10:15.442065+00	\N	\N	{"age_group": "45_54", "gender": "male"}	TXN-20260322-00126	2026-03-22 05:25:15.442065+00
127	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-02-17 06:13:15.453051+00	\N	0.98	{"age_group": "25_34", "gender": "male"}	TXN-20260217-00127	2026-02-17 06:18:15.453051+00
128	HN_CG	EDGE_HN_CG_01	face_recognized	2026-02-25 05:20:15.464955+00	\N	\N	{"age_group": "18_24", "gender": "female"}	TXN-20260225-00128	2026-02-25 05:27:15.464955+00
129	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-31 12:05:15.475678+00	\N	0.89	{"age_group": "35_44", "gender": "unisex"}	TXN-20260331-00129	2026-03-31 12:19:15.475678+00
130	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-03 14:34:15.48747+00	33	0.93	{"age_group": "45_54", "gender": "male"}	TXN-20260303-00130	2026-03-03 14:47:15.48747+00
131	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-19 18:47:15.500713+00	58	0.92	{"age_group": "25_34", "gender": "male"}	TXN-20260319-00131	2026-03-19 19:03:15.500713+00
132	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-21 09:15:15.511977+00	7	0.84	{"age_group": "35_44", "gender": "male"}	TXN-20260321-00132	2026-03-21 09:26:15.511977+00
133	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-23 01:44:15.521515+00	43	0.72	{"age_group": "35_44", "gender": "unisex"}	TXN-20260323-00133	2026-03-23 01:47:15.521515+00
134	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-02-16 00:24:15.531787+00	\N	0.92	{"age_group": "35_44", "gender": "female"}	TXN-20260216-00134	2026-02-16 00:26:15.531787+00
135	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-05 17:22:15.541947+00	\N	\N	{"age_group": "18_24", "gender": "female"}	TXN-20260305-00135	2026-03-05 17:39:15.541947+00
136	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-25 06:17:15.550524+00	60	0.78	{"age_group": "35_44", "gender": "male"}	TXN-20260325-00136	2026-03-25 06:19:15.550524+00
137	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-02-24 23:28:15.560229+00	\N	\N	{"age_group": "45_54", "gender": "female"}	TXN-20260224-00137	2026-02-24 23:29:15.560229+00
138	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-29 21:49:15.569782+00	46	0.91	{"age_group": "45_54", "gender": "male"}	TXN-20260329-00138	2026-03-29 21:51:15.569782+00
139	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-04 20:39:15.579431+00	21	0.82	{"age_group": "45_54", "gender": "unisex"}	TXN-20260304-00139	2026-03-04 20:47:15.579431+00
140	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-27 11:19:15.589598+00	1	0.91	{"age_group": "18_24", "gender": "female"}	TXN-20260327-00140	2026-03-27 11:36:15.589598+00
141	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-12 22:55:15.60126+00	16	0.82	{"age_group": "35_44", "gender": "male"}	TXN-20260312-00141	2026-03-12 23:11:15.60126+00
142	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-12 03:08:15.610577+00	\N	0.82	{"age_group": "35_44", "gender": "male"}	TXN-20260312-00142	2026-03-12 03:21:15.610577+00
143	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-29 14:02:15.620842+00	\N	0.91	{"age_group": "18_24", "gender": "female"}	TXN-20260329-00143	2026-03-29 14:15:15.620842+00
144	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-29 18:44:15.634038+00	\N	0.97	{"age_group": "18_24", "gender": "unisex"}	TXN-20260329-00144	2026-03-29 18:57:15.634038+00
145	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-02-15 07:54:15.642691+00	\N	\N	{"age_group": "35_44", "gender": "male"}	TXN-20260215-00145	2026-02-15 08:07:15.642691+00
146	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-04 12:26:15.652541+00	\N	0.93	{"age_group": "18_24", "gender": "female"}	TXN-20260304-00146	2026-03-04 12:28:15.652541+00
147	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-02-19 12:30:15.662096+00	\N	\N	{"age_group": "25_34", "gender": "male"}	TXN-20260219-00147	2026-02-19 12:34:15.662096+00
148	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-10 05:39:15.671292+00	\N	\N	{"age_group": "35_44", "gender": "male"}	TXN-20260310-00148	2026-03-10 05:56:15.671292+00
149	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-30 20:43:15.679855+00	\N	0.8	{"age_group": "35_44", "gender": "unisex"}	TXN-20260330-00149	2026-03-30 20:47:15.679855+00
150	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-02-28 15:14:15.69007+00	\N	\N	{"age_group": "35_44", "gender": "female"}	TXN-20260228-00150	2026-02-28 15:20:15.69007+00
151	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-02-24 20:45:15.700052+00	43	0.75	{"age_group": "35_44", "gender": "unisex"}	TXN-20260224-00151	2026-02-24 20:53:15.700052+00
152	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-23 07:11:15.708655+00	48	0.86	{"age_group": "45_54", "gender": "female"}	TXN-20260323-00152	2026-03-23 07:15:15.708655+00
153	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-02 12:54:15.717924+00	19	0.9	{"age_group": "18_24", "gender": "unisex"}	TXN-20260302-00153	2026-03-02 13:01:15.717924+00
154	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-16 18:35:15.726446+00	\N	\N	{"age_group": "35_44", "gender": "female"}	TXN-20260316-00154	2026-03-16 18:52:15.726446+00
155	HN_CG	EDGE_HN_CG_01	face_recognized	2026-02-22 15:38:15.735091+00	\N	0.72	{"age_group": "18_24", "gender": "unisex"}	TXN-20260222-00155	2026-02-22 15:45:15.735091+00
156	HN_CG	EDGE_HN_CG_01	no_face	2026-02-16 11:32:15.743281+00	55	0.78	{"age_group": "45_54", "gender": "male"}	TXN-20260216-00156	2026-02-16 11:40:15.743281+00
157	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-02-17 14:49:15.751853+00	12	0.98	{"age_group": "35_44", "gender": "female"}	TXN-20260217-00157	2026-02-17 14:50:15.751853+00
158	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-04 07:56:15.760677+00	\N	0.95	{"age_group": "35_44", "gender": "male"}	TXN-20260304-00158	2026-03-04 08:03:15.760677+00
159	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-02-23 10:44:15.768848+00	\N	0.89	{"age_group": "45_54", "gender": "unisex"}	TXN-20260223-00159	2026-02-23 10:58:15.768848+00
160	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-22 23:01:15.777513+00	34	0.94	{"age_group": "45_54", "gender": "unisex"}	TXN-20260322-00160	2026-03-22 23:08:15.777513+00
161	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-04 15:01:15.785622+00	14	0.79	{"age_group": "45_54", "gender": "female"}	TXN-20260304-00161	2026-03-04 15:04:15.785622+00
162	HN_CG	EDGE_HN_CG_01	no_face	2026-03-04 05:37:15.793815+00	37	0.97	{"age_group": "45_54", "gender": "male"}	TXN-20260304-00162	2026-03-04 05:38:15.793815+00
163	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-02-25 17:32:15.80235+00	\N	\N	{"age_group": "45_54", "gender": "male"}	TXN-20260225-00163	2026-02-25 17:43:15.80235+00
164	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-02-14 12:42:15.811136+00	9	0.98	{"age_group": "25_34", "gender": "male"}	TXN-20260214-00164	2026-02-14 12:57:15.811136+00
165	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-12 03:49:15.818135+00	\N	0.83	{"age_group": "18_24", "gender": "male"}	TXN-20260312-00165	2026-03-12 03:50:15.818135+00
166	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-18 18:33:15.827304+00	33	0.94	{"age_group": "45_54", "gender": "male"}	TXN-20260318-00166	2026-03-18 18:39:15.827304+00
167	HN_CG	EDGE_HN_CG_01	no_face	2026-03-24 06:39:15.836466+00	\N	\N	{"age_group": "35_44", "gender": "male"}	TXN-20260324-00167	2026-03-24 06:41:15.836466+00
168	HN_CG	EDGE_HN_CG_01	no_face	2026-03-08 18:24:15.844024+00	\N	0.72	{"age_group": "45_54", "gender": "female"}	TXN-20260308-00168	2026-03-08 18:28:15.844024+00
169	HN_CG	EDGE_HN_CG_01	face_recognized	2026-03-19 23:41:15.852405+00	26	0.75	{"age_group": "18_24", "gender": "unisex"}	TXN-20260319-00169	2026-03-19 23:48:15.852405+00
170	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-02-28 20:18:15.859426+00	\N	\N	{"age_group": "18_24", "gender": "male"}	TXN-20260228-00170	2026-02-28 20:22:15.859426+00
171	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-10 03:53:15.867702+00	50	0.75	{"age_group": "18_24", "gender": "unisex"}	TXN-20260310-00171	2026-03-10 04:01:15.867702+00
172	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-24 18:52:15.87525+00	28	0.74	{"age_group": "18_24", "gender": "male"}	TXN-20260324-00172	2026-03-24 18:53:15.87525+00
173	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-04 02:30:15.883431+00	20	0.73	{"age_group": "18_24", "gender": "male"}	TXN-20260304-00173	2026-03-04 02:36:15.883431+00
174	HN_CG	EDGE_HN_CG_01	no_face	2026-03-20 09:00:15.891451+00	31	0.77	{"age_group": "25_34", "gender": "female"}	TXN-20260320-00174	2026-03-20 09:08:15.891451+00
175	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-02-21 14:30:15.900694+00	\N	\N	{"age_group": "25_34", "gender": "male"}	TXN-20260221-00175	2026-02-21 14:37:15.900694+00
176	HCM_Q1	EDGE_HCM_Q1_01	no_face	2026-03-08 02:57:15.909241+00	\N	0.74	{"age_group": "45_54", "gender": "male"}	TXN-20260308-00176	2026-03-08 02:59:15.909241+00
177	HN_CG	EDGE_HN_CG_01	no_face	2026-03-21 02:34:15.919049+00	\N	0.86	{"age_group": "18_24", "gender": "unisex"}	TXN-20260321-00177	2026-03-21 02:51:15.919049+00
178	HCM_Q7	EDGE_HCM_Q7_01	face_recognized	2026-03-16 08:25:15.927181+00	18	0.97	{"age_group": "18_24", "gender": "male"}	TXN-20260316-00178	2026-03-16 08:37:15.927181+00
179	HCM_Q7	EDGE_HCM_Q7_01	no_face	2026-03-13 07:16:15.936419+00	\N	\N	{"age_group": "25_34", "gender": "female"}	TXN-20260313-00179	2026-03-13 07:36:15.936419+00
180	HCM_Q1	EDGE_HCM_Q1_01	face_recognized	2026-03-04 06:20:15.947686+00	38	0.77	{"age_group": "18_24", "gender": "female"}	TXN-20260304-00180	2026-03-04 06:30:15.947686+00
\.


--
-- Data for Name: federated_client_updates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.federated_client_updates (id, round_number, branch_id, update_path, update_size_mb, local_loss, local_accuracy, local_samples_count, status, created_at) FROM stdin;
1	1	HCM_Q1	/fl/round_1/HCM_Q1.npy	7.75	0.3388	0.8467	1937	received	2026-03-31 17:39:16.54515
2	1	HCM_Q7	/fl/round_1/HCM_Q7.npy	12.07	0.6908	0.8109	761	aggregated	2026-03-31 17:39:16.54515
3	1	HN_CG	/fl/round_1/HN_CG.npy	8.07	0.2249	0.7372	1767	received	2026-03-31 17:39:16.54515
4	2	HCM_Q1	/fl/round_2/HCM_Q1.npy	16.7	0.6117	0.8119	669	received	2026-03-31 17:39:16.54515
5	2	HCM_Q7	/fl/round_2/HCM_Q7.npy	16.66	0.3201	0.7903	439	received	2026-03-31 17:39:16.54515
6	2	HN_CG	/fl/round_2/HN_CG.npy	7.6	0.4406	0.7581	446	aggregated	2026-03-31 17:39:16.54515
7	3	HCM_Q1	/fl/round_3/HCM_Q1.npy	17.57	0.2816	0.8576	317	received	2026-03-31 17:39:16.54515
8	3	HCM_Q7	/fl/round_3/HCM_Q7.npy	13.4	0.1987	0.7538	1817	received	2026-03-31 17:39:16.54515
9	3	HN_CG	/fl/round_3/HN_CG.npy	14.75	0.1191	0.9347	1924	received	2026-03-31 17:39:16.54515
\.


--
-- Data for Name: federated_learning_rounds; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.federated_learning_rounds (id, round_number, model_type, aggregation_method, participating_branches, total_branches, status, started_at, completed_at, created_at, updated_at) FROM stdin;
1	1	recommender	fedavg	["HCM_Q1", "HCM_Q7", "HN_CG"]	3	completed	2026-03-22 17:39:16.351345	2026-03-23 17:39:16.352353	2026-03-31 17:39:16.516015	2026-03-31 17:39:16.516015
2	2	recommender	fedavg	["HCM_Q1", "HCM_Q7", "HN_CG"]	3	completed	2026-03-23 17:39:16.352353	2026-03-24 17:39:16.352353	2026-03-31 17:39:16.516015	2026-03-31 17:39:16.516015
3	3	recommender	fedavg	["HCM_Q1", "HCM_Q7", "HN_CG"]	3	aggregating	2026-03-24 17:39:16.352353	\N	2026-03-31 17:39:16.516015	2026-03-31 17:39:16.516015
\.


--
-- Data for Name: inventory_optimizations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_optimizations (id, branch_id, product_id, action, quantity, priority, reason, status, created_at, updated_at) FROM stdin;
1	HCM_Q1	138	restock	33	medium	Cross-branch balancing suggestion	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
2	HCM_Q1	205	restock	13	medium	High demand in last 7 days	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
3	HCM_Q1	50	restock	19	low	High demand in last 7 days	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
4	HCM_Q1	2	restock	37	medium	Excess inventory detected	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
5	HCM_Q1	126	markdown	17	low	High demand in last 7 days	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
6	HCM_Q1	7	markdown	11	high	Cross-branch balancing suggestion	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
7	HCM_Q1	95	markdown	17	medium	Low stock threshold reached	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
8	HCM_Q1	53	markdown	2	low	High demand in last 7 days	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
9	HCM_Q1	73	restock	42	medium	Low stock threshold reached	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
10	HCM_Q1	147	restock	21	medium	Low stock threshold reached	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
11	HCM_Q1	110	restock	36	medium	Low stock threshold reached	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
12	HCM_Q1	188	markdown	3	low	Low stock threshold reached	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
13	HCM_Q1	114	transfer	9	medium	Low stock threshold reached	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
14	HCM_Q1	134	restock	7	medium	Excess inventory detected	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
15	HCM_Q1	33	transfer	45	low	Low stock threshold reached	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
16	HCM_Q1	117	transfer	35	low	Low stock threshold reached	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
17	HCM_Q1	76	restock	23	low	Cross-branch balancing suggestion	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
18	HCM_Q1	29	markdown	13	low	Excess inventory detected	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
19	HCM_Q1	184	transfer	23	high	Low stock threshold reached	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
20	HCM_Q1	181	transfer	31	medium	Excess inventory detected	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
21	HCM_Q7	170	transfer	37	high	Cross-branch balancing suggestion	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
22	HCM_Q7	109	markdown	11	medium	Excess inventory detected	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
23	HCM_Q7	30	transfer	33	medium	Cross-branch balancing suggestion	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
24	HCM_Q7	46	restock	22	medium	Low stock threshold reached	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
25	HCM_Q7	119	markdown	2	medium	Cross-branch balancing suggestion	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
26	HCM_Q7	82	restock	41	high	Low stock threshold reached	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
27	HCM_Q7	89	restock	44	low	Excess inventory detected	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
28	HCM_Q7	179	markdown	18	high	High demand in last 7 days	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
29	HCM_Q7	102	restock	50	medium	Excess inventory detected	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
30	HCM_Q7	181	restock	46	high	Low stock threshold reached	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
31	HCM_Q7	33	markdown	7	high	Cross-branch balancing suggestion	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
32	HCM_Q7	199	restock	23	high	Excess inventory detected	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
33	HCM_Q7	124	transfer	18	low	Low stock threshold reached	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
34	HCM_Q7	126	restock	6	low	High demand in last 7 days	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
35	HCM_Q7	154	transfer	36	high	Low stock threshold reached	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
36	HCM_Q7	106	transfer	6	high	Low stock threshold reached	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
37	HCM_Q7	176	transfer	12	medium	Cross-branch balancing suggestion	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
38	HCM_Q7	61	markdown	9	high	High demand in last 7 days	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
39	HCM_Q7	8	markdown	14	high	High demand in last 7 days	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
40	HCM_Q7	75	markdown	20	high	High demand in last 7 days	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
41	HN_CG	151	transfer	29	medium	Cross-branch balancing suggestion	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
42	HN_CG	203	restock	31	low	Excess inventory detected	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
43	HN_CG	101	transfer	49	low	Low stock threshold reached	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
44	HN_CG	50	restock	36	low	Cross-branch balancing suggestion	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
45	HN_CG	156	markdown	4	medium	Low stock threshold reached	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
46	HN_CG	80	restock	30	high	Cross-branch balancing suggestion	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
47	HN_CG	201	transfer	41	high	Excess inventory detected	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
48	HN_CG	83	restock	45	high	High demand in last 7 days	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
49	HN_CG	109	restock	18	medium	Low stock threshold reached	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
50	HN_CG	132	restock	30	low	Cross-branch balancing suggestion	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
51	HN_CG	191	markdown	19	high	High demand in last 7 days	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
52	HN_CG	6	transfer	31	medium	Excess inventory detected	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
53	HN_CG	78	restock	25	low	Cross-branch balancing suggestion	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
54	HN_CG	71	transfer	49	high	Cross-branch balancing suggestion	ignored	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
55	HN_CG	118	transfer	25	low	Low stock threshold reached	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
56	HN_CG	52	transfer	50	medium	High demand in last 7 days	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
57	HN_CG	26	transfer	49	high	Cross-branch balancing suggestion	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
58	HN_CG	68	restock	15	low	High demand in last 7 days	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
59	HN_CG	168	restock	33	high	High demand in last 7 days	applied	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
60	HN_CG	148	transfer	15	low	Cross-branch balancing suggestion	pending	2026-03-31 17:39:16.559314	2026-03-31 17:39:16.559314
\.


--
-- Data for Name: model_performance_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.model_performance_logs (id, model_version, date, branch_id, precision_at_5, recall_at_5, ndcg_at_5, ctr, avg_latency_ms, p95_latency_ms, created_at) FROM stdin;
1	recommender_v1.0.0	2026-03-31 17:39:16.30995	HCM_Q1	0.804	0.546	0.893	0.299	78.31	211.13	2026-03-31 17:39:16.326175
2	recommender_v1.0.0	2026-03-30 17:39:16.310943	HCM_Q1	0.78	0.863	0.808	0.26	82.6	231.55	2026-03-31 17:39:16.326175
3	recommender_v1.0.0	2026-03-29 17:39:16.310943	HCM_Q1	0.869	0.703	0.657	0.231	74.2	226.37	2026-03-31 17:39:16.326175
4	recommender_v1.0.0	2026-03-28 17:39:16.310943	HCM_Q1	0.905	0.769	0.552	0.289	48.1	103.67	2026-03-31 17:39:16.326175
5	recommender_v1.0.0	2026-03-27 17:39:16.310943	HCM_Q1	0.871	0.836	0.758	0.25	75.16	123.86	2026-03-31 17:39:16.326175
6	recommender_v1.0.0	2026-03-26 17:39:16.310943	HCM_Q1	0.81	0.672	0.772	0.17	103.55	155.06	2026-03-31 17:39:16.326175
7	recommender_v1.0.0	2026-03-25 17:39:16.310943	HCM_Q1	0.664	0.873	0.722	0.296	82.09	201.94	2026-03-31 17:39:16.326175
8	recommender_v1.0.0	2026-03-31 17:39:16.310943	HCM_Q7	0.763	0.627	0.613	0.133	112.45	117.69	2026-03-31 17:39:16.326175
9	recommender_v1.0.0	2026-03-30 17:39:16.310943	HCM_Q7	0.683	0.731	0.707	0.255	132.08	217.23	2026-03-31 17:39:16.326175
10	recommender_v1.0.0	2026-03-29 17:39:16.310943	HCM_Q7	0.695	0.629	0.587	0.086	46.1	207.8	2026-03-31 17:39:16.326175
11	recommender_v1.0.0	2026-03-28 17:39:16.310943	HCM_Q7	0.693	0.747	0.767	0.304	99.32	103.54	2026-03-31 17:39:16.326175
12	recommender_v1.0.0	2026-03-27 17:39:16.310943	HCM_Q7	0.856	0.893	0.804	0.259	62.72	191.35	2026-03-31 17:39:16.326175
13	recommender_v1.0.0	2026-03-26 17:39:16.310943	HCM_Q7	0.712	0.578	0.886	0.247	121.67	152.93	2026-03-31 17:39:16.326175
14	recommender_v1.0.0	2026-03-25 17:39:16.310943	HCM_Q7	0.723	0.521	0.583	0.113	47.2	237.87	2026-03-31 17:39:16.326175
15	recommender_v1.0.0	2026-03-31 17:39:16.310943	HN_CG	0.893	0.544	0.921	0.108	58.47	136.68	2026-03-31 17:39:16.326175
16	recommender_v1.0.0	2026-03-30 17:39:16.310943	HN_CG	0.701	0.531	0.888	0.29	64.76	114.09	2026-03-31 17:39:16.326175
17	recommender_v1.0.0	2026-03-29 17:39:16.310943	HN_CG	0.873	0.665	0.745	0.224	64.98	158.79	2026-03-31 17:39:16.326175
18	recommender_v1.0.0	2026-03-28 17:39:16.310943	HN_CG	0.899	0.753	0.73	0.117	73.38	226.51	2026-03-31 17:39:16.326175
19	recommender_v1.0.0	2026-03-27 17:39:16.310943	HN_CG	0.835	0.752	0.892	0.107	77.57	148.55	2026-03-31 17:39:16.326175
20	recommender_v1.0.0	2026-03-26 17:39:16.310943	HN_CG	0.929	0.74	0.552	0.2	69.18	117.02	2026-03-31 17:39:16.326175
21	recommender_v1.0.0	2026-03-25 17:39:16.311947	HN_CG	0.82	0.714	0.757	0.255	65.55	151.08	2026-03-31 17:39:16.326175
22	recommender_v1.1.0	2026-03-31 17:39:16.311947	HCM_Q1	0.902	0.512	0.605	0.099	110.7	117.72	2026-03-31 17:39:16.326175
23	recommender_v1.1.0	2026-03-30 17:39:16.311947	HCM_Q1	0.727	0.58	0.587	0.243	106.93	165.39	2026-03-31 17:39:16.326175
24	recommender_v1.1.0	2026-03-29 17:39:16.311947	HCM_Q1	0.877	0.674	0.929	0.292	68.76	127.7	2026-03-31 17:39:16.326175
25	recommender_v1.1.0	2026-03-28 17:39:16.311947	HCM_Q1	0.887	0.787	0.935	0.104	120.35	182.26	2026-03-31 17:39:16.326175
26	recommender_v1.1.0	2026-03-27 17:39:16.311947	HCM_Q1	0.696	0.582	0.839	0.18	87.38	183.49	2026-03-31 17:39:16.326175
27	recommender_v1.1.0	2026-03-26 17:39:16.311947	HCM_Q1	0.726	0.627	0.593	0.168	63.97	149.41	2026-03-31 17:39:16.326175
28	recommender_v1.1.0	2026-03-25 17:39:16.311947	HCM_Q1	0.901	0.828	0.73	0.285	136.02	135.43	2026-03-31 17:39:16.326175
29	recommender_v1.1.0	2026-03-31 17:39:16.311947	HCM_Q7	0.765	0.742	0.901	0.299	95.4	155.76	2026-03-31 17:39:16.326175
30	recommender_v1.1.0	2026-03-30 17:39:16.311947	HCM_Q7	0.682	0.824	0.722	0.123	68.31	130.13	2026-03-31 17:39:16.326175
31	recommender_v1.1.0	2026-03-29 17:39:16.312948	HCM_Q7	0.754	0.558	0.676	0.082	110.39	200.35	2026-03-31 17:39:16.326175
32	recommender_v1.1.0	2026-03-28 17:39:16.312948	HCM_Q7	0.71	0.727	0.679	0.134	51.29	139.71	2026-03-31 17:39:16.326175
33	recommender_v1.1.0	2026-03-27 17:39:16.312948	HCM_Q7	0.709	0.587	0.774	0.245	134.9	213.04	2026-03-31 17:39:16.326175
34	recommender_v1.1.0	2026-03-26 17:39:16.312948	HCM_Q7	0.838	0.73	0.809	0.237	86.34	213.88	2026-03-31 17:39:16.326175
35	recommender_v1.1.0	2026-03-25 17:39:16.312948	HCM_Q7	0.705	0.52	0.748	0.091	71.07	116.7	2026-03-31 17:39:16.326175
36	recommender_v1.1.0	2026-03-31 17:39:16.312948	HN_CG	0.777	0.741	0.786	0.134	47.02	102.5	2026-03-31 17:39:16.326175
37	recommender_v1.1.0	2026-03-30 17:39:16.312948	HN_CG	0.869	0.73	0.552	0.186	57.45	235.36	2026-03-31 17:39:16.326175
38	recommender_v1.1.0	2026-03-29 17:39:16.312948	HN_CG	0.66	0.713	0.761	0.158	46.55	165.79	2026-03-31 17:39:16.326175
39	recommender_v1.1.0	2026-03-28 17:39:16.312948	HN_CG	0.882	0.666	0.67	0.153	77.85	111.17	2026-03-31 17:39:16.326175
40	recommender_v1.1.0	2026-03-27 17:39:16.312948	HN_CG	0.867	0.698	0.569	0.149	138.48	169.07	2026-03-31 17:39:16.326175
41	recommender_v1.1.0	2026-03-26 17:39:16.312948	HN_CG	0.83	0.864	0.887	0.296	54.76	131.36	2026-03-31 17:39:16.326175
42	recommender_v1.1.0	2026-03-25 17:39:16.313948	HN_CG	0.881	0.555	0.947	0.278	113.8	131.69	2026-03-31 17:39:16.326175
\.


--
-- Data for Name: model_versions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.model_versions (id, version, model_type, model_path, model_size_mb, accuracy, "precision", recall, f1_score, training_date, deployed_to_branches, is_active, created_at, updated_at) FROM stdin;
1	recommender_v1.0.0	recommender	/models/recommender_v1.pkl	128.4	0.84	0.81	0.78	0.79	2026-03-01 17:39:16.30442	["HCM_Q1", "HCM_Q7", "HN_CG"]	f	2026-03-31 17:39:16.306414	2026-03-31 17:39:16.306414
2	recommender_v1.1.0	recommender	/models/recommender_v1_1.pkl	132.1	0.88	0.85	0.83	0.84	2026-03-24 17:39:16.30442	["HCM_Q1", "HCM_Q7", "HN_CG"]	t	2026-03-31 17:39:16.306414	2026-03-31 17:39:16.306414
\.


--
-- Data for Name: privacy_audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.privacy_audit_logs (id, customer_id, operation_type, operation_details, performed_by, performed_by_role, ip_address, success, error_message, "timestamp") FROM stdin;
1	1	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0001	customer	10.0.1.224	t	\N	2026-03-07 02:45:52.681538+00
2	2	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0002	customer	10.0.1.86	t	\N	2026-03-16 18:39:53.030687+00
3	3	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0003	customer	10.0.1.25	t	\N	2026-03-20 09:42:53.387231+00
4	4	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0004	customer	10.0.1.100	t	\N	2026-03-22 23:52:53.778572+00
5	5	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0005	customer	10.0.1.110	t	\N	2026-03-05 14:25:54.100549+00
6	6	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0006	customer	10.0.1.82	t	\N	2026-03-31 04:55:54.449225+00
7	7	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0007	customer	10.0.1.58	t	\N	2026-03-26 18:13:54.891869+00
8	8	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0008	customer	10.0.1.107	t	\N	2026-03-02 20:44:55.310488+00
9	9	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0009	customer	10.0.1.150	t	\N	2026-03-16 07:16:55.659677+00
10	10	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0010	customer	10.0.1.217	t	\N	2026-03-20 12:55:56.067324+00
11	11	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0011	customer	10.0.1.219	t	\N	2026-03-14 21:37:56.430956+00
12	12	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0012	customer	10.0.1.103	t	\N	2026-03-20 01:38:56.816341+00
13	13	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0013	customer	10.0.1.61	t	\N	2026-03-29 20:25:57.406846+00
14	14	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0014	customer	10.0.1.66	t	\N	2026-03-19 10:05:57.85253+00
15	15	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0015	customer	10.0.1.186	t	\N	2026-03-28 01:55:58.227326+00
16	16	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0016	customer	10.0.1.188	t	\N	2026-03-10 08:33:58.583567+00
17	17	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0017	customer	10.0.1.98	t	\N	2026-03-19 13:32:58.938442+00
18	18	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0018	customer	10.0.1.109	t	\N	2026-03-20 15:54:59.28657+00
19	19	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0019	customer	10.0.1.183	t	\N	2026-03-08 17:02:59.668393+00
20	20	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0020	customer	10.0.1.96	t	\N	2026-03-14 00:08:59.996727+00
21	21	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0021	customer	10.0.1.212	t	\N	2026-03-27 01:40:00.350898+00
22	22	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0022	customer	10.0.1.219	t	\N	2026-03-10 01:21:00.692487+00
23	23	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0023	customer	10.0.1.142	t	\N	2026-03-21 17:46:01.013057+00
24	24	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0024	customer	10.0.1.210	t	\N	2026-03-05 23:23:01.382285+00
25	25	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0025	customer	10.0.1.134	t	\N	2026-03-14 16:55:01.733953+00
26	26	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0026	customer	10.0.1.54	t	\N	2026-03-24 10:46:02.179102+00
27	27	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0027	customer	10.0.1.254	t	\N	2026-03-07 01:22:02.683936+00
28	28	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0028	customer	10.0.1.150	t	\N	2026-03-28 07:16:03.017644+00
29	29	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0029	customer	10.0.1.186	t	\N	2026-03-23 10:04:03.418528+00
30	30	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0030	customer	10.0.1.210	t	\N	2026-03-23 01:46:03.805751+00
31	31	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0031	customer	10.0.1.85	t	\N	2026-03-10 01:08:04.142662+00
32	32	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0032	customer	10.0.1.229	t	\N	2026-03-17 05:52:04.497052+00
33	33	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0033	customer	10.0.1.160	t	\N	2026-03-27 14:58:04.831127+00
34	34	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0034	customer	10.0.1.140	t	\N	2026-03-25 23:01:05.174097+00
35	35	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0035	customer	10.0.1.75	t	\N	2026-03-16 00:39:05.467985+00
36	36	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0036	customer	10.0.1.58	t	\N	2026-03-23 15:12:05.76392+00
37	37	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0037	customer	10.0.1.6	t	\N	2026-03-27 16:05:06.094481+00
38	38	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0038	customer	10.0.1.217	t	\N	2026-03-07 13:36:06.511686+00
39	39	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0039	customer	10.0.1.172	t	\N	2026-03-25 02:15:06.858341+00
40	40	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0040	customer	10.0.1.205	t	\N	2026-03-22 23:32:07.185172+00
41	41	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0041	customer	10.0.1.139	t	\N	2026-03-06 14:31:07.475403+00
42	42	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0042	customer	10.0.1.189	t	\N	2026-03-17 08:44:07.78414+00
43	43	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0043	customer	10.0.1.249	t	\N	2026-03-14 05:27:08.08273+00
44	44	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0044	customer	10.0.1.161	t	\N	2026-03-08 23:23:08.390947+00
45	45	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0045	customer	10.0.1.12	t	\N	2026-03-08 14:46:08.729412+00
46	46	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0046	customer	10.0.1.119	t	\N	2026-03-08 20:12:09.043899+00
47	47	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0047	customer	10.0.1.141	t	\N	2026-03-25 04:50:09.349812+00
48	48	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0048	customer	10.0.1.132	t	\N	2026-03-13 22:40:09.666987+00
49	49	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0049	customer	10.0.1.213	t	\N	2026-03-02 18:55:09.963885+00
50	50	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0050	customer	10.0.1.201	t	\N	2026-03-11 05:36:10.304636+00
51	51	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0051	customer	10.0.1.148	t	\N	2026-03-08 16:04:10.621579+00
52	52	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0052	customer	10.0.1.95	t	\N	2026-03-20 11:19:10.964652+00
53	53	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0053	customer	10.0.1.5	t	\N	2026-03-20 18:48:11.276325+00
54	54	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0054	customer	10.0.1.17	t	\N	2026-03-22 10:49:11.625196+00
55	55	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0055	customer	10.0.1.138	t	\N	2026-03-29 12:27:11.964038+00
56	56	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0056	customer	10.0.1.229	t	\N	2026-03-05 17:04:12.402951+00
57	57	consent_given	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0057	customer	10.0.1.169	t	\N	2026-03-26 23:05:12.779652+00
58	58	consent_updated	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0058	customer	10.0.1.79	t	\N	2026-03-16 17:40:13.122511+00
59	59	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0059	customer	10.0.1.218	t	\N	2026-03-12 01:54:13.460861+00
60	60	data_accessed	{"source": "seed_script", "note": "Generated for UI testing"}	CUS0060	customer	10.0.1.85	t	\N	2026-03-04 02:43:13.843313+00
\.


--
-- Data for Name: product_associations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_associations (id, product_id, related_product_id, confidence, lift, support) FROM stdin;
1	2	4	0.82	2.25	0.093
2	2	109	0.6	1.59	0.208
3	2	3	0.67	1.1	0.169
4	109	4	0.86	1.5	0.049
5	109	1	0.62	2.25	0.191
6	109	2	0.87	1.57	0.244
7	1	3	0.62	2.13	0.081
8	1	4	0.49	1.62	0.119
9	1	109	0.92	1.29	0.088
10	4	2	0.76	1.46	0.159
11	4	3	0.65	1.98	0.101
12	4	109	0.47	2.22	0.101
13	3	4	0.49	1.91	0.104
14	3	109	0.83	1.97	0.239
15	3	2	0.52	1.87	0.2
16	5	11	0.52	1.66	0.105
17	5	8	0.66	1.15	0.052
18	5	12	0.62	1.47	0.084
19	8	5	0.68	1.57	0.149
20	8	12	0.57	1.4	0.123
21	8	6	0.92	1.44	0.231
22	6	111	0.51	1.15	0.06
23	6	8	0.79	2.4	0.206
24	6	5	0.9	2.38	0.174
25	9	110	0.7	2.25	0.216
26	9	5	0.78	2.3	0.167
27	9	11	0.82	1.74	0.048
28	111	8	0.82	1.09	0.147
29	111	12	0.62	2.13	0.147
30	111	110	0.74	1.17	0.091
31	11	110	0.7	2.09	0.209
32	11	12	0.48	2.36	0.168
33	11	9	0.66	1.97	0.099
34	110	12	0.54	2.35	0.12
35	110	111	0.88	1.12	0.049
36	110	11	0.52	1.27	0.094
37	12	11	0.9	1.75	0.085
38	12	8	0.49	1.32	0.24
39	12	6	0.58	1.89	0.161
40	7	86	0.53	1.89	0.227
41	86	7	0.85	1.81	0.21
42	15	25	0.68	1.9	0.087
43	15	18	0.9	1.7	0.205
44	15	17	0.77	1.45	0.037
45	17	15	0.65	1.68	0.098
46	17	16	0.52	2.21	0.093
47	17	25	0.91	1.52	0.112
48	16	24	0.71	1.48	0.127
49	16	23	0.58	1.38	0.042
50	16	18	0.59	1.57	0.162
51	23	17	0.89	2.02	0.064
52	23	24	0.52	2.39	0.127
53	23	16	0.86	1.72	0.041
54	25	23	0.9	1.34	0.101
55	25	18	0.47	1.72	0.223
56	25	24	0.76	1.69	0.143
57	18	24	0.51	1.41	0.104
58	18	15	0.64	1.11	0.032
59	18	23	0.71	1.54	0.086
60	27	23	0.81	1.43	0.247
61	27	25	0.77	1.21	0.244
62	27	24	0.64	2.12	0.098
63	24	16	0.73	1.59	0.029
64	24	17	0.47	2.01	0.205
65	24	18	0.69	1.25	0.225
66	39	56	0.68	1.81	0.129
67	39	52	0.46	1.5	0.045
68	39	50	0.65	1.47	0.227
69	51	52	0.73	1.41	0.171
70	51	50	0.91	1.83	0.072
71	51	39	0.47	1.7	0.141
72	119	50	0.52	1.97	0.027
73	119	56	0.9	1.2	0.024
74	119	41	0.6	1.25	0.179
75	120	41	0.88	2.23	0.189
76	120	56	0.48	1.24	0.068
77	120	50	0.6	1.94	0.141
78	41	119	0.88	1.51	0.101
79	41	51	0.81	2.02	0.168
80	41	120	0.78	1.87	0.064
81	56	51	0.59	2.32	0.246
82	56	119	0.81	2	0.179
83	56	41	0.68	1.7	0.149
84	50	52	0.59	1.82	0.145
85	50	56	0.87	1.58	0.099
86	50	119	0.81	1.25	0.03
87	52	56	0.88	1.94	0.192
88	52	39	0.55	2.17	0.082
89	52	119	0.71	1.42	0.045
90	77	73	0.79	1.19	0.197
91	77	78	0.45	1.79	0.234
92	77	80	0.64	2.31	0.222
93	73	78	0.81	1.44	0.086
94	73	82	0.48	2.09	0.17
95	73	70	0.56	2.05	0.216
96	70	77	0.86	1.29	0.232
97	70	73	0.92	1.59	0.134
98	70	78	0.89	2.35	0.233
99	80	77	0.72	1.19	0.246
100	80	83	0.58	2.39	0.145
101	80	70	0.68	2.32	0.216
102	78	80	0.83	1.5	0.188
103	78	70	0.75	2.02	0.023
104	78	73	0.61	1.45	0.175
105	84	73	0.85	2.26	0.21
106	84	83	0.69	1.17	0.174
107	84	78	0.54	1.24	0.094
108	82	73	0.63	1.65	0.081
109	82	77	0.6	1.84	0.152
110	82	70	0.57	1.54	0.074
111	83	84	0.59	1.6	0.136
112	83	77	0.87	2	0.092
113	83	80	0.51	2.29	0.088
114	133	125	0.88	2.07	0.204
115	133	94	0.84	2.08	0.176
116	133	88	0.73	2.11	0.141
117	90	88	0.49	1.81	0.034
118	90	94	0.71	1.73	0.152
119	90	89	0.52	1.49	0.14
120	134	133	0.79	1.71	0.227
121	134	94	0.66	1.13	0.05
122	134	90	0.65	1.81	0.149
123	89	94	0.64	2.15	0.192
124	89	134	0.72	1.11	0.099
125	89	133	0.48	2.39	0.235
126	125	133	0.58	1.29	0.051
127	125	89	0.75	2.03	0.242
128	125	124	0.63	2.25	0.123
129	88	89	0.77	1.94	0.144
130	88	124	0.76	1.52	0.061
131	88	133	0.7	1.76	0.187
132	94	90	0.91	1.68	0.185
133	94	133	0.65	1.56	0.073
134	94	88	0.67	1.26	0.063
135	124	88	0.83	1.62	0.196
136	124	133	0.87	1.07	0.067
137	124	94	0.5	1.1	0.157
138	87	93	0.64	1.37	0.07
139	93	87	0.52	2.39	0.074
140	132	101	0.55	1.46	0.034
141	132	105	0.9	2.24	0.23
142	132	127	0.74	1.63	0.134
143	128	101	0.82	1.48	0.116
144	128	131	0.52	1.56	0.194
145	128	130	0.67	2.2	0.089
146	105	131	0.88	1.81	0.243
147	105	128	0.71	1.23	0.076
148	105	130	0.55	1.92	0.232
149	101	99	0.7	2.17	0.032
150	101	105	0.63	1.87	0.029
151	101	132	0.48	2.14	0.155
152	130	131	0.68	2.22	0.097
153	130	127	0.9	1.07	0.236
154	130	128	0.9	1.21	0.25
155	127	101	0.78	1.59	0.075
156	127	128	0.6	1.43	0.127
157	127	130	0.75	1.47	0.103
158	131	101	0.83	2.03	0.195
159	131	99	0.6	1.32	0.092
160	131	132	0.47	2.22	0.19
161	99	132	0.89	1.83	0.116
162	99	105	0.52	1.5	0.107
163	99	130	0.84	1.72	0.171
164	152	155	0.52	1.79	0.062
165	152	156	0.87	2.39	0.24
166	152	154	0.7	2.18	0.037
167	143	136	0.81	1.61	0.214
168	143	155	0.56	2	0.022
169	143	152	0.69	1.55	0.162
170	154	155	0.76	1.07	0.142
171	154	142	0.64	1.07	0.186
172	154	153	0.7	1.44	0.136
173	156	155	0.83	2.28	0.045
174	156	136	0.5	1.25	0.064
175	156	153	0.7	2.15	0.081
176	153	156	0.9	1.67	0.076
177	153	152	0.78	1.45	0.21
178	153	154	0.49	2.39	0.169
179	142	152	0.63	1.8	0.033
180	142	136	0.45	1.28	0.135
181	142	156	0.65	2.11	0.15
182	155	136	0.88	1.36	0.227
183	155	152	0.78	1.82	0.082
184	155	153	0.88	1.97	0.084
185	136	153	0.53	2.2	0.024
186	136	155	0.55	1.24	0.209
187	136	152	0.84	2.3	0.089
188	145	139	0.69	2.37	0.032
189	145	162	0.66	2.18	0.098
190	145	140	0.81	2.34	0.111
191	140	144	0.82	1.66	0.072
192	140	145	0.71	1.56	0.063
193	140	139	0.73	1.56	0.198
194	162	144	0.49	1.26	0.184
195	162	140	0.75	2.05	0.093
196	162	145	0.5	1.06	0.091
197	144	162	0.51	1.3	0.123
198	144	139	0.71	1.6	0.026
199	144	145	0.62	1.18	0.158
200	141	162	0.59	1.57	0.039
201	141	144	0.87	2.27	0.245
202	141	145	0.72	1.28	0.108
203	146	140	0.58	1.25	0.058
204	146	162	0.58	1.45	0.2
205	146	141	0.62	2.32	0.186
206	139	144	0.67	1.23	0.022
207	139	141	0.64	2.19	0.107
208	139	140	0.86	1.64	0.119
209	147	148	0.73	1.99	0.13
210	148	147	0.9	2.36	0.087
211	184	158	0.5	1.81	0.156
212	184	159	0.71	1.97	0.147
213	184	182	0.9	1.67	0.183
214	183	159	0.83	2.12	0.114
215	183	182	0.68	1.91	0.076
216	183	184	0.76	2.02	0.201
217	177	184	0.68	1.59	0.137
218	177	159	0.88	1.98	0.145
219	177	161	0.82	1.54	0.226
220	182	161	0.5	1.39	0.173
221	182	158	0.53	1.88	0.15
222	182	184	0.75	1.92	0.242
223	159	177	0.45	1.4	0.137
224	159	182	0.69	1.83	0.152
225	159	184	0.66	1.58	0.198
226	161	159	0.52	2.4	0.131
227	161	181	0.59	2.29	0.04
228	161	158	0.84	2.04	0.1
229	181	177	0.69	1.52	0.042
230	181	182	0.79	1.66	0.035
231	181	183	0.47	2.01	0.025
232	158	177	0.77	1.27	0.246
233	158	161	0.56	1.29	0.057
234	158	184	0.71	2.34	0.073
235	157	150	0.75	1.63	0.027
236	150	157	0.66	1.63	0.021
237	164	163	0.67	1.4	0.218
238	164	174	0.7	1.91	0.157
239	164	165	0.74	1.84	0.1
240	175	167	0.83	2	0.088
241	175	166	0.74	1.16	0.051
242	175	165	0.51	1.46	0.062
243	165	174	0.65	1.24	0.108
244	165	175	0.54	1.91	0.179
245	165	167	0.75	2.4	0.148
246	163	167	0.54	2.19	0.162
247	163	165	0.86	2.33	0.131
248	163	175	0.54	1.57	0.149
249	167	174	0.77	1.61	0.213
250	167	163	0.68	1.16	0.027
251	167	166	0.81	1.44	0.083
252	166	167	0.82	1.81	0.198
253	166	165	0.68	1.74	0.152
254	166	175	0.58	1.78	0.248
255	174	167	0.71	2.39	0.044
256	174	164	0.84	2.06	0.088
257	174	163	0.92	1.66	0.1
258	168	169	0.81	1.37	0.206
259	169	168	0.85	1.87	0.118
260	170	171	0.83	1.82	0.142
261	171	170	0.6	2	0.087
262	173	172	0.9	2.11	0.231
263	172	173	0.86	1.22	0.219
264	178	180	0.68	1.83	0.082
265	178	179	0.64	1.66	0.166
266	180	178	0.69	1.43	0.235
267	180	179	0.62	2.33	0.095
268	179	178	0.79	1.67	0.173
269	179	180	0.62	1.14	0.143
270	189	187	0.51	2.2	0.201
271	189	188	0.87	2.08	0.031
272	189	191	0.74	2.18	0.024
273	192	190	0.66	2.39	0.118
274	192	193	0.92	2.28	0.223
275	192	194	0.59	2.23	0.222
276	193	189	0.57	1.55	0.228
277	193	191	0.53	1.59	0.09
278	193	187	0.78	1.37	0.171
279	187	191	0.55	1.16	0.157
280	187	189	0.69	1.65	0.022
281	187	190	0.61	1.21	0.218
282	194	191	0.48	1.57	0.188
283	194	192	0.5	1.47	0.223
284	194	187	0.51	2.09	0.193
285	188	192	0.48	1.81	0.16
286	188	191	0.53	1.52	0.069
287	188	190	0.8	2.29	0.162
288	191	187	0.87	1.24	0.048
289	191	192	0.79	1.52	0.119
290	191	189	0.82	1.38	0.168
291	190	192	0.73	1.87	0.199
292	190	194	0.77	2.19	0.171
293	190	188	0.59	1.75	0.137
294	197	196	0.68	1.2	0.135
295	197	195	0.73	1.76	0.245
296	196	195	0.51	2.21	0.151
297	196	197	0.62	1.97	0.195
298	195	197	0.73	1.07	0.07
299	195	196	0.88	2.33	0.112
300	200	199	0.78	1.16	0.143
301	199	200	0.58	1.47	0.138
302	202	203	0.6	1.64	0.239
303	202	204	0.56	1.38	0.233
304	204	202	0.74	1.12	0.173
305	204	203	0.76	1.29	0.023
306	203	202	0.53	2.34	0.14
307	203	204	0.82	2.02	0.058
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, product_code, name, volume, price, discount_price, discount_percent, category, stock, description, image_url, emotion, target_age_group, target_gender, usage_context) FROM stdin;
1	9583297f-78a6-4dfc-84a5-82f214b9e86e	Dầu đậu nành tinh luyện Janbee	1 lít	69500.00	\N	\N	Dầu ăn	24	Dầu đậu nành tinh luyện Janbee thuộc nhóm Dầu ăn, phù hợp cho ngữ cảnh 'cooking'.	https://drive.google.com/uc?export=view&id=1Znb8L872Ftc-SFh26afcO92PGV-EBQoa	neutral	35_44	female	cooking
2	76e07498-8366-4687-a82e-2a47ecd1e994	Dầu thực vật tinh luyện Cái Lân	1 lít	46000.00	39100	15	Dầu ăn	139	Dầu thực vật tinh luyện Cái Lân thuộc nhóm Dầu ăn, phù hợp cho ngữ cảnh 'cooking'.	https://drive.google.com/uc?export=view&id=117xFuHs-11UrASZhcpa3QP3RzUFkiale	neutral	35_44	female	cooking
3	fb8b76f0-baea-440d-acf3-f80e738a7958	Dầu ăn thượng hạng Neptune Light	1 lít	69000.00	62100	10	Dầu ăn	102	Dầu ăn thượng hạng Neptune Light thuộc nhóm Dầu ăn, phù hợp cho ngữ cảnh 'cooking'.	https://drive.google.com/uc?export=view&id=1VKWc0TYgc4xxnRT4lqcgq8zI7BCYc8YU	neutral	35_44	female	cooking
4	2552366a-29a2-46a3-943a-3d8fb45b3fad	Dầu đậu nành nguyên chất Simply	1 lít	59000.00	\N	\N	Dầu ăn	79	Dầu đậu nành nguyên chất Simply thuộc nhóm Dầu ăn, phù hợp cho ngữ cảnh 'cooking'.	https://drive.google.com/uc?export=view&id=1Zco1o7WXG42g5QrsasNwD41xrhwEIlns	neutral	35_44	female	cooking
5	9258ca2f-5e05-4eac-be09-b5a69a4b9cd0	Nước mắm Nam Ngư nhãn vàng 14 độ đạm	650ml	41500.00	\N	\N	Gia vị	189	Nước mắm Nam Ngư nhãn vàng 14 độ đạm thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'cooking'.	https://drive.google.com/uc?export=view&id=1foQLbgq-0Hb8eJTdmD0bqAXSF98nZaw3	neutral	35_44	female	cooking
6	4261ad1a-adce-4554-9710-a9edbdc16f52	Nước chấm Nam Ngư Đệ Nhị	900ml	25500.00	\N	\N	Gia vị	83	Nước chấm Nam Ngư Đệ Nhị thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1BGTrRqN8smtxj-zOguViCeoXIT0cIR-q	neutral	25_34	unisex	daily
7	271cc8ca-e37c-4277-90dc-36f3b624ac9a	Nước chấm chua ngọt Nam Ngư ớt tỏi Lý Sơn	300ml	35000.00	28000	20	Rau gia vị	29	Nước chấm chua ngọt Nam Ngư ớt tỏi Lý Sơn thuộc nhóm Rau gia vị, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1wbQG83XdQ3X1LbcP8G2lzqOezqK10s8s	neutral	25_34	unisex	daily
8	f14b1d05-1fb7-4ffd-832c-bda06d1396e8	Nước mắm Barona Đại Nhất 12 độ đạm	750ml	39000.00	37050	5	Gia vị	75	Nước mắm Barona Đại Nhất 12 độ đạm thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'cooking'.	https://drive.google.com/uc?export=view&id=1ouzMlb9zQ6fusVqi0nKz1z91UZR0QHiX	neutral	35_44	female	cooking
9	e4c1b87f-da03-460d-970f-cccf1b363bc7	Nước mắm Chinsu cá cơm biển đông 25 độ đạm	720ml	51000.00	48450	5	Gia vị	92	Nước mắm Chinsu cá cơm biển đông 25 độ đạm thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'cooking'.	https://drive.google.com/uc?export=view&id=15lBaNVnu-vbSWMbfkbY-fGqQfk0rdi9z	neutral	35_44	female	cooking
10	63a338bb-de9f-45cb-b283-d0abab06015d	Nước tương Nhị Ca Tam Thái Tử chai	500ml	8800.00	\N	\N	Gia vị	86	Nước tương Nhị Ca Tam Thái Tử chai thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1Tz9giGGj57PB4uIK6RrBCQ1GM8T50Qq2	neutral	25_34	unisex	daily
11	c657b334-1d73-44af-b7cc-74d5d5bd1efa	Nước tương đậu nành Maggi đậm đặc	700ml	35000.00	\N	\N	Gia vị	77	Nước tương đậu nành Maggi đậm đặc thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1iKECt4Wv0p_o3K05YbOleT-4QXW4dt-9	neutral	25_34	unisex	daily
12	32c195be-0444-4c26-8b09-761cb0b32136	Nước tương đậu nành Maggi thanh dịu	700ml	22000.00	\N	\N	Gia vị	20	Nước tương đậu nành Maggi thanh dịu thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=18XJSC_64KITS-r0F1P1fHTvzQxbvnHtB	neutral	25_34	unisex	daily
13	2bcfabb7-eedf-4da1-ad8c-f464bb3e5ee6	Nước tương Tam Thái Tử Nhất Ca sánh đậm	500ml	26000.00	\N	\N	Gia vị	38	Nước tương Tam Thái Tử Nhất Ca sánh đậm thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1TJbDXViPN2FxPXsRGwExjDu8ji2lXtun	neutral	25_34	unisex	daily
14	7d31d029-8f17-4074-ad5e-96f50b6b9465	Nước tương thượng hạng Nam Dương chính hiệu Con Mèo Đen	500ml	41000.00	\N	\N	Gia vị	200	Nước tương thượng hạng Nam Dương chính hiệu Con Mèo Đen thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1eXojJfbfLO8zAqTLkic658UuPAbky3nr	neutral	25_34	unisex	daily
15	cebc7811-c35c-4a9d-8b37-854d28b07b22	Thùng 30 gói mì Hảo Hảo tôm chua cay 75g	1 thùng	116000.00	110200	5	Mì / Bún / Phở	145	Thùng 30 gói mì Hảo Hảo tôm chua cay 75g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://drive.google.com/uc?export=view&id=17rMg2KsxOtTCTB1OA2QC93n2kN7me9G7	anger	18_24	unisex	quick_meal
16	9ce59ad8-ccbb-49de-9acf-155792a5655f	Thùng 30 gói mì Hảo Hảo sa tế hành tím 75g	1 thùng	119000.00	\N	\N	Mì / Bún / Phở	102	Thùng 30 gói mì Hảo Hảo sa tế hành tím 75g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://drive.google.com/uc?export=view&id=1sdbVTAmCSC3oik5SiRBV6Or6HZbj2gIk	tired	18_24	unisex	quick_meal
17	85b32dea-9fe5-4511-aa87-20e9db48996c	Thùng 30 gói mì xào Hảo Hảo tôm xào chua ngọt 75g	1 thùng	119000.00	95200	20	Mì / Bún / Phở	98	Thùng 30 gói mì xào Hảo Hảo tôm xào chua ngọt 75g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2565/87000/bhx/slide-2_202410151117466632.jpg	tired	18_24	unisex	quick_meal
18	fc0359c0-800a-40c9-8e49-660ab593f7e3	Thùng 30 gói mì Kokomi 90 tôm chua cay 90g	1 thùng	117000.00	105300	10	Mì / Bún / Phở	182	Thùng 30 gói mì Kokomi 90 tôm chua cay 90g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2565/212760/bhx/thung-30-goi-mi-kokomi-90-tom-chua-cay-90g_202504011327571500.jpg	anger	18_24	unisex	quick_meal
19	aca2f004-f76e-481b-abe7-d495d4a2d9d1	Thùng 24 ly mì Handy Hảo Hảo tôm chua cay 67g	1 thùng	208000.00	176800	15	Mì / Bún / Phở	57	Thùng 24 ly mì Handy Hảo Hảo tôm chua cay 67g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdn.tgdd.vn/Products/Images/2565/175906/bhx/thung-24-ly-mi-handy-hao-hao-tom-chua-cay-67g-201912051406241113.jpg	anger	18_24	unisex	quick_meal
20	d9f8c780-f6e0-408f-9147-1072585bee2d	Mì Kokomi 90 tôm chua cay gói 90g	1 gói	4500.00	3600	20	Mì / Bún / Phở	149	Mì Kokomi 90 tôm chua cay gói 90g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2565/212759/bhx/mi-kokomi-90-tom-chua-cay-goi-90g_202504011313272490.jpg	anger	18_24	unisex	quick_meal
21	9ad51e21-230b-486c-abce-5487f7b09ed3	Mì Hảo 100 tôm chua cay gói 65g	1 gói	3400.00	2890	15	Mì / Bún / Phở	142	Mì Hảo 100 tôm chua cay gói 65g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2565/77617/bhx/mi-hao-100-tom-chua-cay-65g_202506302046333086.jpg	anger	18_24	unisex	quick_meal
22	4f92b81a-203d-4ec7-b261-f1ffbe9b5ec4	Mì xào khô Indomie Mi Goreng vị đặc biệt gói 85g	1 gói	5900.00	\N	\N	Mì / Bún / Phở	123	Mì xào khô Indomie Mi Goreng vị đặc biệt gói 85g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdn.tgdd.vn/Products/Images/2565/106457/bhx/mi-xao-kho-indomie-mi-goreng-goi-85g-201912111531110055.jpg	tired	18_24	unisex	quick_meal
23	9d0cd1db-dbef-4a18-b865-111036abce29	Thùng 24 gói miến Phú Hương thịt bằm 55g	1 thùng	250000.00	\N	\N	Mì / Bún / Phở	119	Thùng 24 gói miến Phú Hương thịt bằm 55g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdn.tgdd.vn/Products/Images/2965/86012/bhx/thung-24-goi-mien-phu-huong-thit-bam-55g-202209121417388176.jpg	tired	18_24	unisex	quick_meal
24	0c8ccc68-ac2a-4543-99d6-166020d0dbfa	Thùng 24 gói miến Phú Hương sườn heo 55g	1 thùng 	250000.00	\N	\N	Mì / Bún / Phở	86	Thùng 24 gói miến Phú Hương sườn heo 55g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdn.tgdd.vn/Products/Images/2965/86017/bhx/thung-24-goi-mien-phu-huong-suon-heo-58g-202209101649442959.jpg	tired	18_24	unisex	quick_meal
25	6ea2d57b-df3a-4461-8a6e-db601dd728eb	Miến trộn Phú Hương hải sản cay gói 66g	1 gói	11500.00	\N	\N	Mì / Bún / Phở	83	Miến trộn Phú Hương hải sản cay gói 66g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2965/332970/bhx/thiet-ke-chua-co-ten-2024-12-10t144324627_202412101443467397.jpg	anger	18_24	unisex	quick_meal
26	92e98c7f-ab4f-4150-b20a-c06c519dc674	Miến trộn Phú Hương gà xào chua ngọt gói 69g	1 gói	11500.00	\N	\N	Mì / Bún / Phở	127	Miến trộn Phú Hương gà xào chua ngọt gói 69g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2965/332962/bhx/thiet-ke-chua-co-ten-2024-12-10t104556328_202412101049169053.jpg	tired	18_24	unisex	quick_meal
27	b048d361-49e5-4b05-8560-1b82458ef15b	Bún cá cay Hằng Nga gói 70g	1 gói	10000.00	\N	\N	Mì / Bún / Phở	146	Bún cá cay Hằng Nga gói 70g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2566/348005/bhx/anh-slide-1_202509160941138646.jpg	anger	18_24	unisex	quick_meal
28	91aed179-28dd-4cb2-96db-44c239795d5f	Phở bò Vifon gói 90g (có gói thịt thật)	1 gói	17000.00	\N	\N	Mì / Bún / Phở	87	Phở bò Vifon gói 90g (có gói thịt thật) thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2566/342372/bhx/pho-bo-vifon-goi-90g-co-goi-thit-that_202508211334203532.jpg	tired	18_24	unisex	quick_meal
29	0e9e5f9f-bf21-41ba-b432-761f82316db3	Lốc 5 gói phở bò tái lăn Đệ Nhất gói 68g	1 lốc	52000.00	\N	\N	Mì / Bún / Phở	68	Lốc 5 gói phở bò tái lăn Đệ Nhất gói 68g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2566/333862/bhx/bs9a0644_202501061621212353.jpg	tired	18_24	unisex	quick_meal
30	f91639d0-6dfc-4083-a260-a2ad3c65eb41	Lốc 5 gói phở gà Đệ Nhất gói 65g	1 lốc 	43000.00	\N	\N	Mì / Bún / Phở	90	Lốc 5 gói phở gà Đệ Nhất gói 65g thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2566/333860/bhx/loc-5-goi-pho-de-nhat-goi-65g_202504240949457726.jpg	tired	18_24	unisex	quick_meal
31	26cbd778-6e9e-46de-a952-c88d7b54be33	Thùng 24 bịch sữa dinh dưỡng ít đường Dutch Lady 180ml	1 thùng	170000.00	\N	\N	Sữa & chế phẩm	35	Thùng 24 bịch sữa dinh dưỡng ít đường Dutch Lady 180ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2386/241457/bhx/thung-24-bich-sua-tuoi-tiet-trung-it-duong-dutch-lady-canxi-protein-180ml_202504211356194586.jpg	neutral	25_34	unisex	daily
32	58fe169c-bca1-464e-a180-f17b0a59883e	Thùng 48 hộp sữa tươi tiệt trùng có đường Dutch Lady 180ml	1 thùng	345000.00	\N	\N	Sữa & chế phẩm	37	Thùng 48 hộp sữa tươi tiệt trùng có đường Dutch Lady 180ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2386/86175/bhx/sua-tt-cghl-duong-180ml-thung_202504211602138584.jpg	neutral	25_34	unisex	daily
33	f5833d36-7b7f-4702-937f-8d1286c31a38	Thùng 48 hộp sữa tươi tiệt trùng ít đường TH true MILK 110ml	1 thùng	270000.00	\N	\N	Sữa & chế phẩm	116	Thùng 48 hộp sữa tươi tiệt trùng ít đường TH true MILK 110ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2386/85876/bhx/thung-48-hop-sua-tuoi-tiet-trung-it-duong-th-true-milk-110ml-202211171539239485.jpg	neutral	25_34	unisex	daily
34	15458477-33d0-4386-bf74-bc53f8887361	Thùng 48 bịch sữa tươi tiệt trùng ít đường TH true MILK 220ml	1 thùng	375000.00	337500	10	Sữa & chế phẩm	21	Thùng 48 bịch sữa tươi tiệt trùng ít đường TH true MILK 220ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2386/86199/bhx/thung-48-bich-sua-tuoi-tiet-trung-it-duong-th-true-milk-220ml-202208011002337875.jpg	neutral	25_34	unisex	daily
35	313a33b8-b547-45a7-ae0a-92edf3d8ed09	Thùng 12 hộp sữa tươi tiệt trùng không đường Vinamilk Sữa tươi 100% 1 lít	1 thùng	385000.00	\N	\N	Sữa & chế phẩm	164	Thùng 12 hộp sữa tươi tiệt trùng không đường Vinamilk Sữa tươi 100% 1 lít thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2386/88762/bhx/thung-12-hop-sua-tuoi-tiet-trung-khong-duong-vinamilk-sua-tuoi-100-1-lit-202404021058296104.jpg	neutral	25_34	unisex	daily
36	6ea649b0-f9e4-44cb-9fb9-768d1889cdf6	Thùng 48 hộp sữa tươi tiệt trùng ít đường TH true MILK 180ml	1 thùng	425000.00	\N	\N	Sữa & chế phẩm	122	Thùng 48 hộp sữa tươi tiệt trùng ít đường TH true MILK 180ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2386/85853/bhx/thung-48-hop-sua-tuoi-tiet-trung-it-duong-th-true-milk-180ml-202104081706329168.jpg	neutral	25_34	unisex	daily
52	ea03fd89-98bb-42ca-900a-59f1006717b8	Thùng 48 hộp sữa chua uống hương bạc hà và việt quất YoMost 170ml	1 thùng	298000.00	\N	\N	Sữa & chế phẩm	40	Thùng 48 hộp sữa chua uống hương bạc hà và việt quất YoMost 170ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2944/178948/bhx/thung-sua-chua-uong-yomost-vi-bac-ha-va-viet-quat_202510301512243610.jpg	neutral	25_34	unisex	daily
37	6f831c1e-17cc-4ea1-848a-33cbc4c7ec9a	Thùng 48 bịch sữa tươi tiệt trùng nguyên chất không đường TH true MILK 220ml	1 thùng	375000.00	\N	\N	Sữa & chế phẩm	180	Thùng 48 bịch sữa tươi tiệt trùng nguyên chất không đường TH true MILK 220ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2386/86201/bhx/thung-48-bich-sua-tuoi-tiet-trung-nguyen-chat-khong-duong-th-true-milk-220ml-202104090010317648.jpg	neutral	25_34	unisex	daily
38	bd3729b1-38e4-4118-8d61-d2cb460b770e	Thùng 48 hộp sữa tươi tiệt trùng có đường TH true MILK 180ml	1 thùng	425000.00	\N	\N	Sữa & chế phẩm	90	Thùng 48 hộp sữa tươi tiệt trùng có đường TH true MILK 180ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2386/85859/bhx/thung-48-hop-sua-tuoi-tiet-trung-co-duong-th-true-milk-180ml-202104091503000890.jpg	neutral	25_34	unisex	daily
39	0e3740f8-9d6f-4f7b-b1bb-3b719c18c93b	Thùng 48 bịch sữa dinh dưỡng có đường Vinamilk 220ml	1 thùng	330000.00	\N	\N	Sữa & chế phẩm	96	Thùng 48 bịch sữa dinh dưỡng có đường Vinamilk 220ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2386/85837/bhx/thung-48-bich-sua-dinh-duong-co-duong-vinamilk-a-d3-220ml-202401241421584327.jpg	neutral	25_34	unisex	daily
40	662bdd0b-b218-4630-b448-3d2702743375	Thùng 48 hộp sữa tươi tiệt trùng nguyên chất TH true MILK 180ml	1 thùng	425000.00	\N	\N	Sữa & chế phẩm	96	Thùng 48 hộp sữa tươi tiệt trùng nguyên chất TH true MILK 180ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2386/85872/bhx/thung-48-hop-sua-tuoi-tiet-trung-nguyen-chat-khong-duong-th-true-milk-180ml-202104091501209650.jpg	neutral	25_34	unisex	daily
41	8c0bd0e0-9c72-4d67-9c29-61b269b31df8	Thùng 48 hộp sữa tươi tiệt trùng ít đường Vinamilk 100% Sữa tươi 180ml	1 thùng	355000.00	\N	\N	Sữa & chế phẩm	171	Thùng 48 hộp sữa tươi tiệt trùng ít đường Vinamilk 100% Sữa tươi 180ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2386/85530/bhx/thung-48-hop-sua-tuoi-tiet-trung-it-duong-vinamilk-100-sua-tuoi-180ml-202310071419459272.jpg	neutral	25_34	unisex	daily
42	13cbc909-c57c-4c13-8304-1abb2e7d16e6	Thùng 12 hộp sữa tươi tiệt trùng nguyên chất không đường TH true MILK hộp 1 lít	1 thùng	455000.00	386750	15	Sữa & chế phẩm	51	Thùng 12 hộp sữa tươi tiệt trùng nguyên chất không đường TH true MILK hộp 1 lít thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2386/92114/bhx/thung-12-hop-sua-tuoi-tiet-trung-nguyen-chat-khong-duong-th-true-milk-hop-1-lit-202209261451014805.jpg	neutral	25_34	unisex	daily
43	d4bfaf6c-3b76-40b5-b6d1-ff43f5cd2555	Thùng 48 hộp sữa tươi tiệt trùng vị tự nhiên TH true MILK Hilo 180ml	1 thùng	470000.00	399500	15	Sữa & chế phẩm	59	Thùng 48 hộp sữa tươi tiệt trùng vị tự nhiên TH true MILK Hilo 180ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2386/264128/bhx/thung-48-hop-sua-tuoi-tiet-trung-vi-tu-nhien-th-true-milk-hilo-180ml-202203301614110704.jpg	neutral	25_34	unisex	daily
44	5fa3eef2-4d7e-4720-b97e-5173a5175c91	Thùng 48 hộp sữa tươi tiệt trùng có đường Vinamilk 100% Sữa tươi 180ml	1 thùng	355000.00	\N	\N	Sữa & chế phẩm	67	Thùng 48 hộp sữa tươi tiệt trùng có đường Vinamilk 100% Sữa tươi 180ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2386/85844/bhx/thung-48-hop-sua-tuoi-tiet-trung-co-duong-vinamilk-100-sua-tuoi-180ml-202404020950234025.jpg	neutral	25_34	unisex	daily
45	70aecc30-273a-4640-ae9e-bf45c96ba51b	Thùng 48 hộp sữa tươi tiệt trùng có đường lof Kun 100% Sữa tươi 180ml	1 thùng	376000.00	\N	\N	Sữa & chế phẩm	96	Thùng 48 hộp sữa tươi tiệt trùng có đường lof Kun 100% Sữa tươi 180ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2386/311185/bhx/thung-48-hop-sua-tuoi-tiet-trung-co-duong-lof-kun-100-sua-tuoi-180ml-202308161315279959.jpg	neutral	25_34	unisex	daily
46	8636600f-9b6f-4cb4-a120-cf70c55c20e6	Lốc 4 hộp sữa lúa mạch ít đường Milo A2 180ml	1 lốc	35000.00	31500	10	Sữa & chế phẩm	70	Lốc 4 hộp sữa lúa mạch ít đường Milo A2 180ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2945/336177/bhx/loc-4-hop-sua-lua-mach-it-duong-milo-a2-180ml_202504101051223453.jpg	neutral	25_34	unisex	daily
47	a38415d3-461f-40db-836e-c2658544e3ff	Lốc 4 hộp Sữa socola lúa mạch Lof Kun có thạch 170ml	1 lốc	33500.00	\N	\N	Sữa & chế phẩm	62	Lốc 4 hộp Sữa socola lúa mạch Lof Kun có thạch 170ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2945/327986/bhx/loc-4-hop-sua-socola-lua-mach-lif-kun-co-thach-170ml-202407161553487408.jpg	neutral	25_34	unisex	daily
48	daa15e61-ad90-41f8-aecf-9db0eefdf004	Lốc 4 hộp Sữa lúa mạch vị socola Ovaltine bổ sung canxi 180ml	1 lốc	34000.00	27200	20	Sữa & chế phẩm	67	Lốc 4 hộp Sữa lúa mạch vị socola Ovaltine bổ sung canxi 180ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2945/306189/bhx/loc-4-hop-sua-lua-mach-vi-socola-ovaltine-bo-sung-canxi-180ml-202305061029435525.jpg	neutral	25_34	unisex	daily
49	7ca3de98-74e3-4a43-9113-06cb5c8f9e50	Lốc 4 hộp sữa lúa mạch Ovaltine DHA+ 180ml	1 lốc	34000.00	\N	\N	Sữa & chế phẩm	54	Lốc 4 hộp sữa lúa mạch Ovaltine DHA+ 180ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2945/250744/bhx/loc-4-hop-thuc-uong-dinh-duong-ovaltine-dha-180ml-202112200952265125.jpg	neutral	25_34	unisex	daily
50	16150fd4-8086-42ac-a03a-6bcfd77425f2	Lốc 4 hộp Sữa lúa mạch BFAST bổ sung canxi 180ml	1 lốc	27000.00	\N	\N	Sữa & chế phẩm	99	Lốc 4 hộp Sữa lúa mạch BFAST bổ sung canxi 180ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2945/240661/bhx/loc-4-hop-sua-lua-mach-bfast-180ml-202106020921059723.jpg	neutral	25_34	unisex	daily
51	11f2305b-4158-4922-83d3-32a4ec214596	Thùng 48 hộp sữa chua uống hương cam YoMost 170ml	1 thùng	298000.00	\N	\N	Sữa & chế phẩm	156	Thùng 48 hộp sữa chua uống hương cam YoMost 170ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2944/86162/bhx/scu-yomost-cam-170ml-thung_202510301416044859.jpg	neutral	25_34	unisex	daily
53	d5b1b057-5bcf-4629-a973-7f8e9c0bca3c	Thùng 48 hộp sữa chua lên men tự nhiên hương nho có thạch LOF Malto 170ml	1 thùng	273000.00	\N	\N	Sữa & chế phẩm	84	Thùng 48 hộp sữa chua lên men tự nhiên hương nho có thạch LOF Malto 170ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2944/339218/bhx/loc-4-hop-sua-chua-len-men-tu-nhien-huong-nho-co-thach-lof-malto-170ml-clone_202506051414593308.jpg	neutral	25_34	unisex	daily
54	c5544e90-b58e-4a17-89af-5f131087703b	Lốc 4 hộp sữa chua lên men tự nhiên hương nho có thạch LOF Malto 170ml	1 lốc	34500.00	\N	\N	Sữa & chế phẩm	29	Lốc 4 hộp sữa chua lên men tự nhiên hương nho có thạch LOF Malto 170ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2944/339217/bhx/loc-4-hop-sua-chua-len-men-tu-nhien-huong-nho-lof-malto-180ml-clone_202506051408491703.jpg	neutral	25_34	unisex	daily
55	4deccf3e-0f6b-4f7e-932a-5acf275d938f	Lốc 4 chai sữa chua uống hương việt quất Nutriboost Hy Lạp 170ml	1 lốc	37000.00	\N	\N	Sữa & chế phẩm	12	Lốc 4 chai sữa chua uống hương việt quất Nutriboost Hy Lạp 170ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2947/331455/bhx/z-1_202410260910183398.jpg	neutral	25_34	unisex	daily
56	c11379c8-f11b-4bc0-bc6b-32483cb53628	Lốc 4 chai sữa chua uống hương cam Nutriboost Hy Lạp 170ml	1 lốc	37000.00	35150	5	Sữa & chế phẩm	17	Lốc 4 chai sữa chua uống hương cam Nutriboost Hy Lạp 170ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2947/331454/bhx/z_202410260909016033.jpg	neutral	25_34	unisex	daily
57	e56f880f-1868-440c-aef9-7faa345362ed	Sữa chua uống hương cam Nutriboost Hy Lạp chai 170ml	1 chai	10000.00	\N	\N	Sữa & chế phẩm	92	Sữa chua uống hương cam Nutriboost Hy Lạp chai 170ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2944/322885/bhx/nuoc-uong-sua-chua-hy-lap-nutriboost-huong-viet-quat-170ml-clone-202403091221289021.jpg	neutral	25_34	unisex	daily
58	54ee9149-caee-4c90-9f0d-8a89945ffa5f	Sữa chua uống hương việt quất Nutriboost Hy Lạp chai 170ml	1 chai	10000.00	\N	\N	Sữa & chế phẩm	122	Sữa chua uống hương việt quất Nutriboost Hy Lạp chai 170ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/2944/322884/bhx/sua-trai-cay-nutriboost-huong-banh-quy-kem-297ml-clone-202403091152182464.jpg	neutral	25_34	unisex	daily
59	b9c6ad3b-cba2-4de1-96f6-b27fe38a368f	Lốc 4 hộp sữa chua uống hương bạc hà và việt quất YoMost 170ml	1 lốc	29000.00	24650	15	Sữa & chế phẩm	197	Lốc 4 hộp sữa chua uống hương bạc hà và việt quất YoMost 170ml thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2944/178947/bhx/sua-chua-uong-yomost-vi-bac-ha-va-viet-quat-4-hop_202510301511214809.jpg	neutral	25_34	unisex	daily
60	af2ba8ff-ed0a-4780-9152-5d873dba29b3	Lốc 4 hộp sữa chua có đường Nutimilk 100g	1 lốc	26000.00	20800	20	Sữa & chế phẩm	154	Lốc 4 hộp sữa chua có đường Nutimilk 100g thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/7558/222522/bhx/loc-4-hop-sua-chua-nutifood-co-duong-100g-202103300934287321.jpg	neutral	25_34	unisex	daily
61	cfcd4967-30f5-4502-acbe-6b72adfab32b	Lốc 4 hũ sữa chua ăn có đường Lothamilk 100g	1 lốc	25500.00	\N	\N	Sữa & chế phẩm	149	Lốc 4 hũ sữa chua ăn có đường Lothamilk 100g thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/7558/239327/bhx/loc-4-hu-sua-chua-an-lothamilk-co-duong-100g_202510211129104224.jpg	neutral	25_34	unisex	daily
62	8e6ed997-217f-4dc4-ba92-611c2a6bbd91	Lốc 4 hộp sữa chua ăn ít đường Nutimilk 100g	1 lốc	26000.00	\N	\N	Sữa & chế phẩm	95	Lốc 4 hộp sữa chua ăn ít đường Nutimilk 100g thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/7558/324700/bhx/loc-4-hop-sua-chua-an-it-duong-nutimilk-100g-202405200928563578.jpg	neutral	25_34	unisex	daily
63	ffab1e43-67a3-4455-b9f5-ece65ebd4ebb	Lốc 4 hộp sữa chua ăn nha đam Lothamilk 100g	1 lốc	30000.00	\N	\N	Sữa & chế phẩm	39	Lốc 4 hộp sữa chua ăn nha đam Lothamilk 100g thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/7558/333033/bhx/loc-4-hop-sua-chua-an-nha-dam-lothamilk-100g_202510211118293630.jpg	neutral	25_34	unisex	daily
64	0f123724-4435-43b5-a850-de579646313d	Lốc 4 hộp sữa chua nha đam Nutimilk 100g	1 lốc	31000.00	27900	10	Sữa & chế phẩm	66	Lốc 4 hộp sữa chua nha đam Nutimilk 100g thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/7558/222523/bhx/loc-4-hop-sua-chua-nutimilk-nha-dam-100g-202401230920278850.jpg	neutral	25_34	unisex	daily
65	0433b59d-902c-4298-8e26-55d4ccbaf182	Lốc 4 hộp sữa chua ăn không đường Nutimilk 100g	1 lốc	26000.00	\N	\N	Sữa & chế phẩm	56	Lốc 4 hộp sữa chua ăn không đường Nutimilk 100g thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/7558/333973/bhx/loc-4-hop-sua-chua-an-khong-duong-nutimilk-100g_202511082156122563.jpg	neutral	25_34	unisex	daily
66	59989980-7fbb-4c6a-bf32-5d2cb1fa21c5	Lốc 4 hộp sữa chua có đường Happy Star Vinamilk 100g	1 lốc	25500.00	\N	\N	Sữa & chế phẩm	25	Lốc 4 hộp sữa chua có đường Happy Star Vinamilk 100g thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/7558/333017/bhx/frame-2-4_202412111402186906.jpg	neutral	25_34	unisex	daily
67	a67c2aa4-d081-41f2-a440-30d00cd60c5b	Lốc 2 hũ sữa chua nếp cẩm Sài Gòn Milk 120g	1 lốc	27000.00	\N	\N	Sữa & chế phẩm	186	Lốc 2 hũ sữa chua nếp cẩm Sài Gòn Milk 120g thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/7558/290308/bhx/loc-2-hu-sua-chua-sai-gon-milk-nep-cam-120g-202209171649472335.jpg	neutral	25_34	unisex	daily
68	5d22b162-c9c6-4540-ab8a-ff709f7148e3	Lốc 4 hộp váng sữa hương vani Hoff 55g	1 lốc	65000.00	\N	\N	Sữa & chế phẩm	80	Lốc 4 hộp váng sữa hương vani Hoff 55g thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/7558/323731/bhx/loc-4-hop-vang-sua-huong-vani-hoff-55g_202510281104441650.jpg	neutral	25_34	unisex	daily
69	c6db64ee-92ea-4113-8297-a2e94c4f6be6	Lốc 4 hộp váng sữa dinh dưỡng Gotz 55g	1 lốc	34500.00	\N	\N	Sữa & chế phẩm	29	Lốc 4 hộp váng sữa dinh dưỡng Gotz 55g thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/7558/323717/bhx/loc-4-hop-vang-sua-dinh-duong-gotz-55g-202403221236478534.jpg	neutral	25_34	unisex	daily
70	83bab65c-5e02-45a8-936d-58eaa4e206a2	Thùng 24 lon Bia Tiger lon 250ml	1 thùng	258000.00	\N	\N	Đồ uống có cồn	52	Thùng 24 lon Bia Tiger lon 250ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'party'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2282/328904/bhx/412208-3-1_202501040858596027.jpg	happy	25_34	unisex	party
71	bbd97816-ba62-4a9a-8384-7d7bff031ab1	Thùng 24 lon Bia Heineken Silver 250ml	1 thùng	355000.00	\N	\N	Đồ uống có cồn	18	Thùng 24 lon Bia Heineken Silver 250ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'party'.	https://cdn.tgdd.vn/Products/Images/2282/268673/bhx/thung-24-lon-bia-heineken-silver-250ml-202307071033264741.jpg	happy	25_34	unisex	party
72	ecb6b5c5-539c-4c4a-89a3-ad676f69c353	Thùng 24 lon Bia Sài Gòn Lager 330ml	1 thùng	258000.00	206400	20	Đồ uống có cồn	139	Thùng 24 lon Bia Sài Gòn Lager 330ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'party'.	https://cdn.tgdd.vn/Products/Images/2282/158349/bhx/thung-24-lon-bia-sai-gon-lager-330ml-202110111038141085.jpg	happy	25_34	unisex	party
73	c57b5193-7c6a-4e72-be5f-bf08951cd0ec	Thùng 24 lon Bia Tiger Bạc 330ml	1 thùng	395000.00	375250	5	Đồ uống có cồn	166	Thùng 24 lon Bia Tiger Bạc 330ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'party'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2282/77606/bhx/412208-7_202501040910505920.jpg	happy	25_34	unisex	party
74	bfc156f1-4268-4720-ba38-b2f6882dc6bd	Thùng 24 lon Bia Tiger Bạc 250ml	1 thùng	276000.00	\N	\N	Đồ uống có cồn	15	Thùng 24 lon Bia Tiger Bạc 250ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'party'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2282/328902/bhx/412208-4-1_202501040903412829.jpg	happy	25_34	unisex	party
75	adaf187e-c86b-4ead-a4fc-fa93d98d1735	Thùng 24 lon Bia Blanc 1664 330ml	1 thùng	410000.00	369000	10	Đồ uống có cồn	167	Thùng 24 lon Bia Blanc 1664 330ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'party'.	https://cdn.tgdd.vn/Products/Images/2282/252737/bhx/thung-24-lon-bia-blanc-1664-330ml-202407061001226425.jpg	happy	25_34	unisex	party
76	aa017cb5-b496-42a5-9417-beec7b243112	Thùng 12 lon bia Hoegaarden Peach vị đào 500ml	1 thùng	445000.00	\N	\N	Đồ uống có cồn	14	Thùng 12 lon bia Hoegaarden Peach vị đào 500ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'party'.	https://cdn.tgdd.vn/Products/Images/2282/303826/bhx/thung-12-lon-bia-hoegaarden-peach-vi-dao-500ml-202303151341125768.jpg	happy	25_34	unisex	party
77	48e76a9b-f890-482e-8a03-cd6700870620	Thùng 12 lon bia Budweiser 500ml	1 thùng	349000.00	\N	\N	Đồ uống có cồn	194	Thùng 12 lon bia Budweiser 500ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'party'.	https://cdn.tgdd.vn/Products/Images/2282/176454/bhx/thung-12-lon-bia-budweiser-500ml-202103162311285122.jpg	happy	25_34	unisex	party
78	23ac668a-0cd2-437b-8ff2-4e7f09f1f70e	Bia Lạc Việt lon 330ml	1 lon	12000.00	9600	20	Đồ uống có cồn	135	Bia Lạc Việt lon 330ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'party'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2282/277840/bhx/bia-lac-viet-lon-330ml_202505281337499597.jpg	happy	25_34	unisex	party
79	dcf4b890-c91e-4ef3-bf6e-b4433d191182	Bia Corona Extra chai 250ml	1 lon	31000.00	\N	\N	Đồ uống có cồn	141	Bia Corona Extra chai 250ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'party'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2282/335844/bhx/bia-corona-extra-300ml-clone_202503181510233947.jpg	happy	25_34	unisex	party
80	77e0bf6d-eb78-4ab7-8a73-d61458d018c6	Rượu soju Heejin vị việt quất 12% chai 360ml	1 chai	45000.00	\N	\N	Đồ uống có cồn	74	Rượu soju Heejin vị việt quất 12% chai 360ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/9498/329239/bhx/z-7_202410221349597530.jpg	neutral	25_34	unisex	daily
81	1485f5ea-a1a9-4383-98c4-338a415c5e3d	Rượu soju Heejin vị đào 12% chai 360ml	1 chai	45000.00	42750	5	Đồ uống có cồn	21	Rượu soju Heejin vị đào 12% chai 360ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/9498/329238/bhx/z-8_202410221351142717.jpg	neutral	25_34	unisex	daily
82	7301020d-0402-4b78-969e-9e061a2a830f	Rượu soju Heejin vị dâu 12% chai 360ml	1 chai	45000.00	\N	\N	Đồ uống có cồn	95	Rượu soju Heejin vị dâu 12% chai 360ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'daily'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/9498/329237/bhx/z-6_202410221352004307.jpg	neutral	25_34	unisex	daily
83	a0500366-8dd9-44bc-ad93-6e2f9241f1bf	Rượu soju Rice+ hương dứa 12.5% chai 360ml	1 chai	45000.00	38250	15	Đồ uống có cồn	120	Rượu soju Rice+ hương dứa 12.5% chai 360ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/9498/320034/bhx/ruou-soju-rice-huong-dua-125-chai-360ml-202401071911290498.jpg	neutral	25_34	unisex	daily
84	a4592c5b-8367-4468-b3e8-cbda4d9c38fa	Rượu soju Rice+ hương vải 12.5% chai 360ml	1 chai	45000.00	\N	\N	Đồ uống có cồn	116	Rượu soju Rice+ hương vải 12.5% chai 360ml thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'daily'.	https://cdn.tgdd.vn/Products/Images/9498/319969/bhx/ruou-soju-rice-huong-vai-125-chai-360ml-202401071912573306.jpg	neutral	25_34	unisex	daily
85	c34d6ee1-5a04-45bf-9b79-84e2f5289aef	Thùng 24 lon nước ngọt Pepsi không calo vị chanh 320ml	1 thùng	168000.00	142800	15	Nước giải khát	144	Thùng 24 lon nước ngọt Pepsi không calo vị chanh 320ml thuộc nhóm Nước giải khát, phù hợp cho ngữ cảnh 'party'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2443/227311/bhx/thung-24-lon-nuoc-ngot-pepsi-khong-calo-vi-chanh-330ml_202510311433238230.jpg	happy	25_34	unisex	party
86	4544a866-890a-460f-93db-542521c75fa7	Thùng 24 chai nước ngọt 7 Up vị chanh 390ml	1 thùng	118000.00	\N	\N	Rau gia vị	22	Thùng 24 chai nước ngọt 7 Up vị chanh 390ml thuộc nhóm Rau gia vị, phù hợp cho ngữ cảnh 'party'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2443/79125/bhx/nuoc-ngot-7-up-thung-24-chai-390_202509050857354535.jpg	happy	25_34	unisex	party
87	b336ff02-4595-449e-ada1-c89697da7fc2	Thùng 12 chai nước ngọt Mirinda vị soda kem 1.5 lít	1 thùng	180000.00	\N	\N	Kem	155	Thùng 12 chai nước ngọt Mirinda vị soda kem 1.5 lít thuộc nhóm Kem, phù hợp cho ngữ cảnh 'party'.	https://cdn.tgdd.vn/Products/Images/2443/200782/bhx/thung-12-chai-nuoc-ngot-mirinda-vi-soda-kem-15-lit-202403281442114638.jpg	happy	25_34	unisex	party
88	e26b7e68-b6d3-48b3-afc4-352c85e6962a	Thùng 24 chai nước ngọt Mirinda hương xá xị 390ml	1 thùng	118000.00	\N	\N	Nước giải khát	197	Thùng 24 chai nước ngọt Mirinda hương xá xị 390ml thuộc nhóm Nước giải khát, phù hợp cho ngữ cảnh 'party'.	https://cdn.tgdd.vn/Products/Images/2443/79149/bhx/thung-24-chai-nuoc-ngot-mirinda-huong-xa-xi-390ml-202310311417451013.jpg	happy	25_34	unisex	party
89	4362ec25-fdc1-4b2a-9588-6642962e5302	Thùng 24 chai nước ngọt Pepsi Cola 390ml	1 thùng	118000.00	\N	\N	Nước giải khát	132	Thùng 24 chai nước ngọt Pepsi Cola 390ml thuộc nhóm Nước giải khát, phù hợp cho ngữ cảnh 'party'.	https://cdn.tgdd.vn/Products/Images/2443/83601/bhx/thung-24-chai-nuoc-ngot-pepsi-cola-390ml-202405131540090674.jpg	happy	25_34	unisex	party
90	61c35ff1-5a92-4568-9870-e345bc73a24c	Nước ngọt Coca Cola lon 320ml	1 thùng	10000.00	9000	10	Nước giải khát	70	Nước ngọt Coca Cola lon 320ml thuộc nhóm Nước giải khát, phù hợp cho ngữ cảnh 'party'.	https://cdn.tgdd.vn/Products/Images/2443/76451/bhx/nuoc-ngot-coca-cola-lon-320ml-202304131107525481.jpg	happy	25_34	unisex	party
91	845e5e02-35a6-498e-9420-f6d30ae72b04	6 lon nước ngọt Coca Cola 320ml	1 lốc	52000.00	\N	\N	Nước giải khát	159	6 lon nước ngọt Coca Cola 320ml thuộc nhóm Nước giải khát, phù hợp cho ngữ cảnh 'party'.	https://cdn.tgdd.vn/Products/Images/2443/125398/bhx/6-lon-nuoc-ngot-coca-cola-320ml-202303181532309738.jpg	happy	25_34	unisex	party
92	6774e6fd-3534-44d2-8bf7-40170e50ac56	Nước ngọt Fanta hương xá xị chai 1.5 lít	1 chai	21000.00	17850	15	Nước giải khát	156	Nước ngọt Fanta hương xá xị chai 1.5 lít thuộc nhóm Nước giải khát, phù hợp cho ngữ cảnh 'party'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/2443/76457/bhx/z-18_202411041433399075.jpg	happy	25_34	unisex	party
93	204e5daa-e27a-42e2-ad34-d29fcb5d84a5	6 lon nước ngọt Mirinda vị soda kem 320ml	1 lốc	63000.00	\N	\N	Kem	141	6 lon nước ngọt Mirinda vị soda kem 320ml thuộc nhóm Kem, phù hợp cho ngữ cảnh 'party'.	https://cdn.tgdd.vn/Products/Images/2443/195220/bhx/6-lon-nuoc-ngot-mirinda-vi-soda-kem-320ml-202312260911089105.jpg	happy	25_34	unisex	party
94	d1b9db4c-7740-417c-9d54-b450251614c9	Nước ngọt Mirinda hương xá xị lon 320ml	1 lon	10000.00	\N	\N	Nước giải khát	134	Nước ngọt Mirinda hương xá xị lon 320ml thuộc nhóm Nước giải khát, phù hợp cho ngữ cảnh 'party'.	https://cdn.tgdd.vn/Products/Images/2443/86628/bhx/nuoc-ngot-mirinda-huong-xa-xi-lon-320ml-202312252213207503.jpg	happy	25_34	unisex	party
95	0f57e196-eacf-4d9f-89a6-5fdd236a80c9	Bánh cracker rau củ chà bông Tipo hộp 132g	1 hộp	27000.00	22950	15	Rau củ tươi	35	Bánh cracker rau củ chà bông Tipo hộp 132g thuộc nhóm Rau củ tươi, phù hợp cho ngữ cảnh 'snack'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/3357/339261/bhx/banh-cracker-rau-cu-cha-bong-tipo-hop-132g_202506251958074162.jpg	happy	25_34	unisex	snack
96	a903b525-93ec-4602-bf74-099d44d3ea67	Bánh cuộn phủ socola hương vani Gery Crunch Roll gói 23g	1 bánh	5000.00	\N	\N	Snack	70	Bánh cuộn phủ socola hương vani Gery Crunch Roll gói 23g thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/3357/339260/bhx/banh-cuon-phu-socola-gery-crunch-roll-hop-299g-clone_202506061624289163.jpg	happy	25_34	unisex	snack
97	37f71635-5dd1-431a-b46d-bc5c35acb0ec	Bánh cuộn phủ socola Gery Crunch Roll gói 23g	1 bánh	5000.00	\N	\N	Snack	152	Bánh cuộn phủ socola Gery Crunch Roll gói 23g thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/3357/339259/bhx/anh-slide-41_202506061602367848.jpg	happy	25_34	unisex	snack
98	ee26af7b-4793-4bac-83ef-42dcff20b99a	Bánh cracker vị dừa sầu riêng Bibica Gooka Nougat Filling hộp 360g	1 hộp	65000.00	\N	\N	Snack	37	Bánh cracker vị dừa sầu riêng Bibica Gooka Nougat Filling hộp 360g thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/3357/332446/bhx/anh-slide-11_202411251536233594.jpg	happy	25_34	unisex	snack
99	14b30760-cebe-46ff-8768-3e7e7bbdcae5	Bánh quy bơ và cacao Danisa Abbracci hộp 168g	1 hộp	35500.00	\N	\N	Snack	163	Bánh quy bơ và cacao Danisa Abbracci hộp 168g thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/3357/332445/bhx/sderffff_202411251522384110.jpg	happy	25_34	unisex	snack
100	46b1b7b5-3a08-4c49-96c5-44e9cf02c72d	Thùng 20 hộp Bánh quy socola Orion Miz 54g	1 thùng	290000.00	246500	15	Snack	189	Thùng 20 hộp Bánh quy socola Orion Miz 54g thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/3357/331351/bhx/frame-3476037-1_202411241701446531.jpg	happy	25_34	unisex	snack
101	26b41c6b-4f50-45ec-b945-2a2e9eb74025	Thùng 20 hộp Bánh cá vị tôm nướng môi đỏ Orion Marine Boy 35g	1 thùng	260000.00	\N	\N	Snack	164	Thùng 20 hộp Bánh cá vị tôm nướng môi đỏ Orion Marine Boy 35g thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/3357/331226/bhx/anh-slide-3-1_202410181910042375.jpg	happy	UNDER_18	unisex	snack
102	81606b2f-15e4-4ffc-a73b-fe9afc07043e	Bánh quy socola chip nhân kem dâu Parle Platina Hide & Seek gói 112.5g	1 bánh	25000.00	21250	15	Snack	51	Bánh quy socola chip nhân kem dâu Parle Platina Hide & Seek gói 112.5g thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/3357/330758/bhx/anh-slide-54_202410071449349188.jpg	happy	25_34	unisex	snack
103	215bb35c-37c7-451d-8a5e-19d774e2ec28	Bánh quy socola chip nhân socola Parle Platina Hide & Seek gói 112.5g	1 bánh	26000.00	\N	\N	Snack	38	Bánh quy socola chip nhân socola Parle Platina Hide & Seek gói 112.5g thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/3357/330755/bhx/anh-slide-53_202410071439116611.jpg	happy	25_34	unisex	snack
104	28a42565-eba9-41ff-b3ad-4eda339d7363	Bánh quy phô mai Gery hộp 180g	1 bánh	39000.00	\N	\N	Snack	141	Bánh quy phô mai Gery hộp 180g thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://cdnv2.tgdd.vn/bhx-static/bhx/Products/Images/3357/96264/bhx/banh-quy-cracker-gery-pho-mai-hop-200gr_202510131639047799.jpg	happy	25_34	unisex	snack
105	aa137a76-b19a-456d-abc9-fefb303c0521	Bánh cá vị rong biển tuyết xanh Orion Marine Boy hộp 32g	1 bánh	13000.00	12350	5	Snack	167	Bánh cá vị rong biển tuyết xanh Orion Marine Boy hộp 32g thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://cdn.tgdd.vn/Products/Images/3357/83216/bhx/banh-ca-vi-rong-bien-tuyet-xanh-orion-marine-boy-hop-32g-201912151632169943.jpg	anger	18_24	unisex	snack
106	b612273d-326d-4837-811f-90d838f60748	Gạo ST25 (Túi 5kg)	1 túi	160000.00	152000	5	Gạo	145	Gạo ST25 (Túi 5kg) thuộc nhóm Gạo, phù hợp cho ngữ cảnh 'cooking'.	https://drive.google.com/uc?export=view&id=16vn7TVGAui6wqsLDzwEsSawscAtn_m_y	neutral	35_44	female	cooking
107	950bc1a0-a654-4c1f-937a-91b5753c75c0	Mì Hảo Hảo Tôm Chua Cay	1 gói	4500.00	3600	20	Mì / Bún / Phở	47	Mì Hảo Hảo Tôm Chua Cay thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://drive.google.com/uc?export=view&id=1PxM-OPZir_XDhWZSApjIrGiRoPAjQQSy	anger	18_24	unisex	quick_meal
108	ba0eeecc-e4ce-4bd7-b4f0-91117d028872	Thùng Mì 3 Miền (30 gói)	1 thùng	85000.00	\N	\N	Mì / Bún / Phở	105	Thùng Mì 3 Miền (30 gói) thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://drive.google.com/uc?export=view&id=1FANjTaEPu6oyWD1yQcrcY3dnBNt96-7Q	tired	18_24	unisex	quick_meal
109	013d09af-48c5-4c50-9709-5b6183c5e8cc	Dầu ăn Tường An	1 lít	48000.00	\N	\N	Dầu ăn	90	Dầu ăn Tường An thuộc nhóm Dầu ăn, phù hợp cho ngữ cảnh 'cooking'.	https://drive.google.com/uc?export=view&id=1kiTFIZLeadggKMoXrT5bFnXxdDXsAleP	neutral	35_44	female	cooking
110	5c3c9117-2fac-436a-b807-4cba00d3d6a1	Nước mắm Nam Ngư	750ml	42000.00	\N	\N	Gia vị	190	Nước mắm Nam Ngư thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'cooking'.	https://drive.google.com/uc?export=view&id=1BNsBFkDPq6jLAsoWhsjNCaOzlbsJeso6	neutral	35_44	female	cooking
111	39db55d0-6784-4457-900f-d85d7b17e783	Hạt nêm Knorr (400g)	1 gói	38000.00	30400	20	Gia vị	138	Hạt nêm Knorr (400g) thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'cooking'.	https://drive.google.com/uc?export=view&id=11gM-gBEU322jwRcI_bWHzHcTF_xHniQZ	neutral	35_44	female	cooking
112	26a9aea3-5f05-45b5-81af-801b4e2e9d24	Bột ngọt Ajinomoto (454g)	1 gói	32000.00	\N	\N	Gia vị	38	Bột ngọt Ajinomoto (454g) thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1NLjMiL1LMHdyiDiF8AztSyCCkHM6LavO	neutral	25_34	unisex	daily
113	e7753b8d-850e-4de8-935e-b4cb3e98063a	Đường tinh luyện Biên Hòa (1kg)	1 gói	22000.00	17600	20	Gia vị	135	Đường tinh luyện Biên Hòa (1kg) thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1t-nvgwBVIxrrCIGTtilcx4ZllEdWjfBp	neutral	25_34	unisex	daily
114	ce2da010-513b-4127-8f02-30e3f362500e	Muối I-ốt (Gói 500g)	1 gói	5000.00	\N	\N	Gia vị	66	Muối I-ốt (Gói 500g) thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1xEHY8k9zmu9c-tYTV34c0t8AQLSREuWV	neutral	25_34	unisex	daily
115	11086cc9-d30a-4145-acaf-8e2084c851f0	Tương ớt Chinsu (250g)	1 chai	12000.00	\N	\N	Gia vị	156	Tương ớt Chinsu (250g) thuộc nhóm Gia vị, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1kJ-y9pWd2EZo_bIRWRRmV5y5sLUZiZaY	neutral	25_34	unisex	daily
116	de0f18f5-f3b9-44bb-9d2d-ca990368168e	Trứng gà tươi (Vỉ 10 quả)	1 vỉ	30000.00	\N	\N	Trứng	94	Trứng gà tươi (Vỉ 10 quả) thuộc nhóm Trứng, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1sqB3KjGygo_hcjcrWS2MonCeXJZbtr8v	neutral	25_34	unisex	daily
117	44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f	Xúc xích Vissan (Gói 5 cây)	1 gói	18000.00	\N	\N	Thịt chế biến	58	Xúc xích Vissan (Gói 5 cây) thuộc nhóm Thịt chế biến, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1_vKIp4jgGlMkIqbSmDqmJOsOKHpclwzI	neutral	25_34	unisex	daily
118	071cea0f-3714-449f-b21f-86ddce66fd4d	Cá hộp 3 Cô Gái	1 hộp	20000.00	\N	\N	Đồ hộp	175	Cá hộp 3 Cô Gái thuộc nhóm Đồ hộp, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1EbQfB98L9w1mZBxTZ_t1OlQmcg0eKmnO	neutral	25_34	unisex	daily
119	b3278e99-958a-4236-81bc-9cd0c9604c9c	Lốc 4 sữa tươi TH True Milk	1 lốc	32000.00	\N	\N	Sữa & chế phẩm	48	Lốc 4 sữa tươi TH True Milk thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1erfosPXL8myD2B5UolfFUChsvl9xB9te	neutral	25_34	unisex	daily
120	95bd5a46-0188-4553-927a-64cb57498ebc	Lốc 4 sữa chua Vinamilk	1 lốc	24000.00	\N	\N	Sữa & chế phẩm	12	Lốc 4 sữa chua Vinamilk thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1tGXeuY67m_3hJ5JYW1lSOp64ITDToeg9	neutral	25_34	unisex	daily
121	827e4a51-3225-4f53-a04f-e03b0e5b9f8d	Sữa đặc Ông Thọ (Lon)	1 lon	26000.00	\N	\N	Sữa & chế phẩm	190	Sữa đặc Ông Thọ (Lon) thuộc nhóm Sữa & chế phẩm, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1dvLxnYBoCB9jHpQnO57CfMcUndKSQffH	neutral	25_34	unisex	daily
122	eb6dd78c-2cff-4373-a62a-ad27ce8d8d87	Cà phê G7 3in1 (Hộp 18 gói)	1 hộp	52000.00	\N	\N	Cà phê	175	Cà phê G7 3in1 (Hộp 18 gói) thuộc nhóm Cà phê, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1YdDsZgCbP4ViPHl3WDZ4G9_4qgIh69_J	neutral	25_34	unisex	daily
123	b5986a34-443f-4122-a13b-528f10e97ea5	Trà Lipton Túi lọc (Hộp 25 gói)	1 hộp	35000.00	\N	\N	Trà	43	Trà Lipton Túi lọc (Hộp 25 gói) thuộc nhóm Trà, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1Ww-YJPOZp9vN5y5BhJze6ff6zM7BeRmi	neutral	25_34	unisex	daily
124	4603c6b9-3f0e-4455-9c80-afad12742d51	Nước suối Aquafina (500ml)	1 chai	5000.00	4750	5	Nước giải khát	198	Nước suối Aquafina (500ml) thuộc nhóm Nước giải khát, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1uP0Xb-licw2YBtC367DcjmiUPxkz5ZRN	neutral	25_34	unisex	daily
125	0865ac34-b3ed-4b11-8a79-3e59ecf6d80f	Coca Cola (Chai 1.5L)	1 chai	20000.00	18000	10	Nước giải khát	121	Coca Cola (Chai 1.5L) thuộc nhóm Nước giải khát, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=11VYZZ6JGdKjyXSvowGgqfwfhToCEHyPw	neutral	25_34	unisex	daily
126	d487390c-5ffd-47eb-b891-e9feeaeb0830	Bia Tiger Nâu (Lon 330ml)	1 lon	16000.00	\N	\N	Đồ uống có cồn	182	Bia Tiger Nâu (Lon 330ml) thuộc nhóm Đồ uống có cồn, phù hợp cho ngữ cảnh 'party'.	https://drive.google.com/uc?export=view&id=16cOmrN9gpGfA4dA-ZPKuQw_S2udmoaPV	happy	25_34	unisex	party
127	93732245-6096-4556-a353-202308e968d1	Bánh ChocoPie (Hộp 6 cái)	1 hộp	30000.00	28500	5	Snack	143	Bánh ChocoPie (Hộp 6 cái) thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://drive.google.com/uc?export=view&id=1r2gGuC6vJ6pYYfd4YoFsuyOmev0TFvxL	sad	18_24	unisex	snack
128	a010e906-1854-42a0-944b-8bcd42f82e55	Snack Khoai tây O'Star	1 bịch	10000.00	9500	5	Snack	182	Snack Khoai tây O'Star thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://drive.google.com/uc?export=view&id=1ao9jN_8dly7IxSQLu60B9wN5vVS1DBqy	happy	25_34	unisex	snack
129	fb1ea21f-cda1-4678-a372-358a68f83a9c	Kẹo cứng Dynamite	1 bịch	8000.00	\N	\N	Kẹo	132	Kẹo cứng Dynamite thuộc nhóm Kẹo, phù hợp cho ngữ cảnh 'snack'.	https://drive.google.com/uc?export=view&id=1QOFoiJ-neLa60MWzxRN1yjV7WD-fHWSM	happy	25_34	unisex	snack
130	260fa104-9d28-45a7-bb5e-06b373367221	Bánh quy Cosy (Gói 200g)	1 gói	15000.00	13500	10	Snack	106	Bánh quy Cosy (Gói 200g) thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://drive.google.com/uc?export=view&id=1JCx4DkS8W-LhEMt_SJ5WEKdlTKAMAoje	happy	25_34	unisex	snack
131	596df514-3b1f-463c-92f3-fdfb93e41684	Ngũ cốc dinh dưỡng (Gói 500g)	1 gói	55000.00	44000	20	Snack	143	Ngũ cốc dinh dưỡng (Gói 500g) thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://drive.google.com/uc?export=view&id=1E9rj60Xw9QwprVb-wQoWTvL9XoNNq1QM	happy	25_34	unisex	snack
132	df4e7bad-75ab-4bb8-822a-e66ec36f0a38	Đậu phộng da cá (Hũ 200g)	1 hũ	25000.00	22500	10	Snack	46	Đậu phộng da cá (Hũ 200g) thuộc nhóm Snack, phù hợp cho ngữ cảnh 'snack'.	https://drive.google.com/uc?export=view&id=1kuQWxypCd8M8Apxg3xaL5cxFiN_dNhBP	happy	UNDER_18	unisex	snack
133	7a904b8a-d0d0-4b76-95cf-4b2020758a9e	Nước tăng lực Redbull (Lon)	1 lon	12000.00	\N	\N	Nước giải khát	44	Nước tăng lực Redbull (Lon) thuộc nhóm Nước giải khát, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1FwglisycLKblrZFzBeysoV7y3FuCSKc1	neutral	25_34	unisex	daily
134	f321fc35-eb7c-428c-a6bd-77a3f0df00a4	Trà xanh C2 (Chai 360ml)	1 chai	7000.00	\N	\N	Nước giải khát	20	Trà xanh C2 (Chai 360ml) thuộc nhóm Nước giải khát, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1YnS6dFyMy9Y8SPQiax1rZg2nQmkbXckh	neutral	25_34	unisex	daily
135	c7f42ff3-6047-4f08-866c-1b32209e3f90	Bún khô Safoco (Gói 400g)	1 gói	18000.00	\N	\N	Mì / Bún / Phở	74	Bún khô Safoco (Gói 400g) thuộc nhóm Mì / Bún / Phở, phù hợp cho ngữ cảnh 'quick_meal'.	https://drive.google.com/uc?export=view&id=1EKhKtHjTtfaMinMcC9vLLkRTBa_156mg	tired	18_24	unisex	quick_meal
136	53ec6e96-b534-42e0-a986-9d6d2d36e86d	Dầu gội Sunsilk (Chai 650g)	1 chai	110000.00	88000	20	Chăm sóc cá nhân	178	Dầu gội Sunsilk (Chai 650g) thuộc nhóm Chăm sóc cá nhân, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1P8U6eNLdIL7PAYj7_n7JrVHwDNEOZxb3	neutral	25_34	unisex	daily
137	f0cac878-618a-41d5-9319-8b85e8c0fc27	Dầu gội Clear Men (Chai 630g)	1 chai	135000.00	\N	\N	Chăm sóc cá nhân	136	Dầu gội Clear Men (Chai 630g) thuộc nhóm Chăm sóc cá nhân, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=15Adp0ovdFGabFHQW5XaQ-Sf5pUhCvOY_	neutral	25_34	unisex	daily
138	8e13d676-f7e9-477f-940b-813f80469993	Sữa tắm Lifebuoy (Chai 850g)	1 chai	150000.00	142500	5	Chăm sóc cá nhân	22	Sữa tắm Lifebuoy (Chai 850g) thuộc nhóm Chăm sóc cá nhân, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1vHsujbX12hCDcPxos74I7WVaof349id5	neutral	25_34	unisex	daily
139	efbd986b-4531-4883-afb4-194c9b59a109	Bột giặt OMO (Túi 3kg)	1 túi	125000.00	\N	\N	Hóa phẩm tẩy rửa	90	Bột giặt OMO (Túi 3kg) thuộc nhóm Hóa phẩm tẩy rửa, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1m0zsvJDd1RvS1go3BuSrMV6owu1PZiOH	neutral	25_34	unisex	daily
140	47c22c5d-813f-4e12-9e3f-a450c8a3121f	Nước giặt Ariel (Túi 2.1kg)	1 túi	140000.00	\N	\N	Hóa phẩm tẩy rửa	109	Nước giặt Ariel (Túi 2.1kg) thuộc nhóm Hóa phẩm tẩy rửa, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1N_lBiQwspb8agQjPrGEueo1PrjDizTd9	neutral	25_34	unisex	daily
141	0b4a4b09-46ec-4a6b-bc41-df4393645a3e	Nước xả vải Comfort (Túi 1.6L)	1 túi	115000.00	\N	\N	Hóa phẩm tẩy rửa	137	Nước xả vải Comfort (Túi 1.6L) thuộc nhóm Hóa phẩm tẩy rửa, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1OuCk0vBN1Bia8wO-8s2jvKKm143XZt0F	neutral	25_34	unisex	daily
142	11c60194-88d2-4816-997a-5553a8cb6196	Kem đánh răng P/S (180g)	1 cái	28000.00	\N	\N	Chăm sóc cá nhân	101	Kem đánh răng P/S (180g) thuộc nhóm Chăm sóc cá nhân, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1R59afvJDCYkR52HMjKs_DPMZCxgg8LsV	neutral	25_34	unisex	daily
143	a3a7acbd-4cf2-4f56-9930-63c15fc00ecc	Bàn chải đánh răng Colgate	1 cái	15000.00	14250	5	Chăm sóc cá nhân	35	Bàn chải đánh răng Colgate thuộc nhóm Chăm sóc cá nhân, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1m9ddwD3qr7NJP6w-EyZLqJY72xvETN42	neutral	25_34	unisex	daily
144	2869b301-5fec-407f-b472-6e72ee034c9f	Nước rửa chén Sunlight (750ml)	1 chai	25000.00	21250	15	Hóa phẩm tẩy rửa	97	Nước rửa chén Sunlight (750ml) thuộc nhóm Hóa phẩm tẩy rửa, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1k4uVqs0F80066T6ggTaTXSmShU7FVTw_	neutral	25_34	unisex	daily
145	3f023ad8-02a4-4e95-8ec6-553c622e7d9d	Nước lau sàn Gift (1 Lít)	1 chai	22000.00	\N	\N	Hóa phẩm tẩy rửa	170	Nước lau sàn Gift (1 Lít) thuộc nhóm Hóa phẩm tẩy rửa, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1Srig_rAfecvcUHMDJKuOPb7zV21ziwv5	neutral	25_34	unisex	daily
146	fd9f259d-1ea9-4994-ae7d-d00f930fcde4	Nước tẩy bồn cầu Vim (900ml)	1 chai	32000.00	28800	10	Hóa phẩm tẩy rửa	50	Nước tẩy bồn cầu Vim (900ml) thuộc nhóm Hóa phẩm tẩy rửa, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1j7TNgfxMHlIVgpiuzR0qmBaLqFR9X-mN	neutral	25_34	unisex	daily
147	3518ef51-5bc7-4266-bbc2-6ce2d3acbc53	Giấy vệ sinh E'mos (Lốc 10)	1 lốc	60000.00	48000	20	Sản phẩm giấy	131	Giấy vệ sinh E'mos (Lốc 10) thuộc nhóm Sản phẩm giấy, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1hZJTqWZAbRjECY0dVkB7BdCeaHno1aA6	neutral	25_34	unisex	daily
148	d6f2920e-e16a-4096-8159-a938f4b8ce59	Khăn giấy rút Pulppy (Hộp)	1 hộp	18000.00	16200	10	Sản phẩm giấy	135	Khăn giấy rút Pulppy (Hộp) thuộc nhóm Sản phẩm giấy, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1KahD7t9Q7iJtFHLS3y49Ch-hlDXAmbhy	neutral	25_34	unisex	daily
149	37ee0bd9-0b99-403e-96ab-f314af9c2e8e	Băng vệ sinh Diana (Gói 8)	1 gói	18000.00	16200	10	Khác	13	Băng vệ sinh Diana (Gói 8) thuộc nhóm Khác, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1vXhadeTMrYUu3QfV5dyTbInLXr0Rbjw6	neutral	25_34	unisex	daily
150	8f4dc2fd-7d0d-449f-88a4-47cad03d38d2	Tã quần Bobby (Bịch M40)	1 bịch	210000.00	\N	\N	Chăm sóc em bé	171	Tã quần Bobby (Bịch M40) thuộc nhóm Chăm sóc em bé, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1FHIzwDvi6ilU6IXsrcj2BqxjSgSomMjU	neutral	25_34	unisex	daily
151	4e6b1095-a3cb-4d03-b747-0b3080e9a160	Xà bông cục X-Men	1 cái	15000.00	14250	5	Khác	24	Xà bông cục X-Men thuộc nhóm Khác, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1bCoabksxY-SLOv1Smut-xlv07o7wbiMX	neutral	25_34	unisex	daily
152	a544d61d-edb8-4b54-ad19-8f4745d8307a	Sữa rửa mặt Acnes (100g)	1 chai	55000.00	52250	5	Chăm sóc cá nhân	65	Sữa rửa mặt Acnes (100g) thuộc nhóm Chăm sóc cá nhân, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1T9n3sCvHiC3PYzV0UjVtiN_PlIzhc5xu	neutral	25_34	unisex	daily
153	0fae3be1-0f57-4a82-aba9-d13e180c1943	Dao cạo râu Gillette (Cây)	1 cây	12000.00	\N	\N	Chăm sóc cá nhân	86	Dao cạo râu Gillette (Cây) thuộc nhóm Chăm sóc cá nhân, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1-R6crhn6FrTRBq2HG-MVPrRwIXU6Y-XO	neutral	25_34	unisex	daily
154	5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970	Bọt cạo râu (Chai 200ml)	1 chai	65000.00	\N	\N	Chăm sóc cá nhân	49	Bọt cạo râu (Chai 200ml) thuộc nhóm Chăm sóc cá nhân, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1LOJFxS3IEB5V8c7v7Jw2OOhqTMhye_7S	neutral	25_34	unisex	daily
155	4dd70e94-850f-406f-a440-c4a161d99325	Dung dịch vệ sinh phụ nữ (Chai)	1 chai	35000.00	\N	\N	Chăm sóc cá nhân	55	Dung dịch vệ sinh phụ nữ (Chai) thuộc nhóm Chăm sóc cá nhân, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=15YM38yUX3xR-L5TA4WujTA3bUZ7YEAIC	neutral	25_34	unisex	daily
156	88a52c8d-5e20-4da9-b186-dba57601f4c2	Tăm bông ráy tai (Hộp)	1 hộp	10000.00	8000	20	Chăm sóc cá nhân	73	Tăm bông ráy tai (Hộp) thuộc nhóm Chăm sóc cá nhân, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1VrZEcVgxMKP0joZsc5zvO6zJ9-cookcM	neutral	25_34	unisex	daily
157	9945b4f0-0b1d-46e2-b225-2cded06debbf	Khăn ướt Baby (Gói 80 tờ)	1 gói	25000.00	\N	\N	Chăm sóc em bé	87	Khăn ướt Baby (Gói 80 tờ) thuộc nhóm Chăm sóc em bé, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1DItoPhpMgjsY6h3mPtk2mjwYlrDkDSGs	neutral	25_34	unisex	daily
158	8526f078-cb9e-4c78-ae7a-ab1526ddda7d	Nước rửa tay khô (Chai 100ml)	1 chai	30000.00	\N	\N	Khác	52	Nước rửa tay khô (Chai 100ml) thuộc nhóm Khác, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1_fSYvzyigE7Cvnu4tgSjFGbAgL_aPPoE	neutral	25_34	unisex	daily
159	faa88516-1182-495d-981d-3a5f206d2770	Sáp khử mùi phòng (Hộp)	1 hộp	40000.00	\N	\N	Khác	26	Sáp khử mùi phòng (Hộp) thuộc nhóm Khác, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1QNyd-GZiRpl26TKF4lr1-ZLykNJ3JLYK	neutral	25_34	unisex	daily
160	d560d1cf-83fa-47da-9467-26fa419a73ba	Thuốc xịt muỗi Raid (600ml)	1 chai	65000.00	61750	5	Khác	52	Thuốc xịt muỗi Raid (600ml) thuộc nhóm Khác, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=11Tgr9wYJqwHjuep0vDQEAag_SDo3b-9_	neutral	25_34	unisex	daily
161	d0ce3076-c06f-42af-ba23-221c0ee27198	Nhang muỗi (Hộp 10 khoanh)	1 hộp	8000.00	\N	\N	Khác	200	Nhang muỗi (Hộp 10 khoanh) thuộc nhóm Khác, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1uzW03tW_Gj_n-d5LArZ45Rq6oL5wn-Gq	neutral	25_34	unisex	daily
162	8f8b80aa-8a45-4b12-add5-6d36bd69dcdf	Javel tẩy trắng (Chai 1L)	1 chai	15000.00	12000	20	Hóa phẩm tẩy rửa	31	Javel tẩy trắng (Chai 1L) thuộc nhóm Hóa phẩm tẩy rửa, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1vZRPlFHzFg5NewLcw4AUnkx020Wp-LZE	neutral	25_34	unisex	daily
163	5acdac1a-898e-4a9f-8acd-f8590ce29d7b	Cọ rửa bồn cầu (Cây)	1 cây	15000.00	12000	20	Dụng cụ vệ sinh	183	Cọ rửa bồn cầu (Cây) thuộc nhóm Dụng cụ vệ sinh, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1ljh2Bi31evTyp3zkb8--FMd-9JpTufOi	neutral	25_34	unisex	daily
164	5576682c-00ee-4aab-8888-3526e2bf7626	Bao tay cao su (Đôi)	1 đôi	18000.00	15300	15	Dụng cụ vệ sinh	82	Bao tay cao su (Đôi) thuộc nhóm Dụng cụ vệ sinh, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1xHbrJH9B4N4cQJjk8jVC1m4bOxPGvjV7	neutral	25_34	unisex	daily
165	e7082b36-2f83-4c1f-a986-57c985941c24	Túi đựng rác (Cuộn 3 màu)	1 cuộn	25000.00	23750	5	Dụng cụ vệ sinh	17	Túi đựng rác (Cuộn 3 màu) thuộc nhóm Dụng cụ vệ sinh, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1eOKzL-Uke93VJAVu83RlcRksFsVyOdWm	neutral	25_34	unisex	daily
166	96957d5e-8c41-4952-9b85-b76b950196f3	Chổi đót quét nhà	1 cái	35000.00	\N	\N	Dụng cụ vệ sinh	136	Chổi đót quét nhà thuộc nhóm Dụng cụ vệ sinh, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1I2ErYd2FBh2ctCPc63pUcBS9yCdkIQ1j	neutral	25_34	unisex	daily
167	1922c25c-8820-4cc8-9b62-4ffe1c5b9704	Cây lau nhà 360 độ (Bộ)	1 bộ	180000.00	\N	\N	Dụng cụ vệ sinh	25	Cây lau nhà 360 độ (Bộ) thuộc nhóm Dụng cụ vệ sinh, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1PEuOcvaIp9NXh0iA1mMtelkdnlIqvmbK	neutral	25_34	unisex	daily
168	131a23d6-1d20-4d98-b9dd-2d0eb19e0b54	Bóng đèn LED Điện Quang 20W	1 cái	45000.00	\N	\N	Phụ kiện điện	16	Bóng đèn LED Điện Quang 20W thuộc nhóm Phụ kiện điện, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1ewO6qHl9Kq1RAkI-XsmVQZvC3NAJGTa_	neutral	25_34	unisex	daily
169	8531a0bb-c2d8-42da-b318-d7a1cf5a767b	Ổ cắm điện nối dài (3 mét)	1 cái	85000.00	68000	20	Phụ kiện điện	198	Ổ cắm điện nối dài (3 mét) thuộc nhóm Phụ kiện điện, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1OlCsivPh9awJOCROzgdOLjWsqDjPof8Y	neutral	25_34	unisex	daily
170	b3ddb87e-8557-4283-bd9e-e384d80b0026	Pin AA Con Ó (Vỉ 4 viên)	1 vỉ	10000.00	\N	\N	Pin	96	Pin AA Con Ó (Vỉ 4 viên) thuộc nhóm Pin, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1NFC83wPfTiAc9V0LwrlaDQJi8BXRWFI_	neutral	25_34	unisex	daily
171	34b1c04a-0e91-4eaf-ae2d-f379c0324d29	Pin AAA Panasonic (Vỉ 2 viên)	1 vỉ	15000.00	\N	\N	Pin	23	Pin AAA Panasonic (Vỉ 2 viên) thuộc nhóm Pin, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1CaKTjy-ojCzMF7V-dGGnieYkvAaNxrRm	neutral	25_34	unisex	daily
172	17f75c8c-ac61-4e32-8355-90e37f46cc3c	Màng bọc thực phẩm (Cuộn)	1 cuộn	20000.00	19000	5	Đồ dùng nhà bếp	92	Màng bọc thực phẩm (Cuộn) thuộc nhóm Đồ dùng nhà bếp, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1x_vzL71Bd9tpEe7mfy_el8Th0_csY50d	neutral	25_34	unisex	daily
173	78a22c2f-8513-49ba-95df-227bbb48543e	Giấy bạc nướng (Cuộn)	1 cuộn	25000.00	\N	\N	Đồ dùng nhà bếp	31	Giấy bạc nướng (Cuộn) thuộc nhóm Đồ dùng nhà bếp, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1DpOUNv2FiZSYFzk1A3t_OZ21_TTLi6oI	neutral	25_34	unisex	daily
174	fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0	Miếng rửa chén (Miếng)	1 miếng	5000.00	4750	5	Dụng cụ vệ sinh	79	Miếng rửa chén (Miếng) thuộc nhóm Dụng cụ vệ sinh, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1DCY_aW1L4ArKHi8nPM4JixI27W2wRR20	neutral	25_34	unisex	daily
175	c55a887f-03c5-45e6-9934-5f8a9a007306	Bùi nhùi sắt (Gói)	1 gói	10000.00	\N	\N	Dụng cụ vệ sinh	75	Bùi nhùi sắt (Gói) thuộc nhóm Dụng cụ vệ sinh, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1ZzI6k3aSwmRNKajTvd5SyQaZvhGyL8pw	neutral	25_34	unisex	daily
176	2eab34da-0a77-4a39-acbb-0e800b733966	Móc phơi quần áo (Vỉ 10)	1 vỉ	35000.00	33250	5	Khác	184	Móc phơi quần áo (Vỉ 10) thuộc nhóm Khác, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1Ns2nbAXw3o6dklMTwiwn5g5PCoGBbrSp	neutral	25_34	unisex	daily
177	991f1b12-1dc2-498a-83bb-75bf860ad56b	Kẹp quần áo (Vỉ 20)	1 vỉ	15000.00	\N	\N	Khác	103	Kẹp quần áo (Vỉ 20) thuộc nhóm Khác, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1SxtlhlkoPLJCv_1nvy7qksRCg2w9nZA0	neutral	25_34	unisex	daily
178	d266d4ae-3907-4253-8443-ae1cf4103dde	Thớt nhựa tròn	1 cái	40000.00	\N	\N	Dụng cụ bếp	22	Thớt nhựa tròn thuộc nhóm Dụng cụ bếp, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1qB-xy4JB2dMcNoKhhNpPKzVc4Y3-YDZw	neutral	25_34	unisex	daily
179	116ca6a2-d366-440f-951e-05cd8176868b	Dao thái lan cán vàng	1 cái	12000.00	\N	\N	Dụng cụ bếp	23	Dao thái lan cán vàng thuộc nhóm Dụng cụ bếp, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=11Z4iBTlEAyx1nPADYn2tnrg2C3GazGlh	neutral	25_34	unisex	daily
180	8f382477-a9b4-44d6-bf2a-59fae61d9166	Kéo cắt giấy/bếp	1 cái	20000.00	19000	5	Dụng cụ bếp	154	Kéo cắt giấy/bếp thuộc nhóm Dụng cụ bếp, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1uI7imbhQUu-csykuWIuF8JjJiduMtpuY	neutral	25_34	unisex	daily
181	e483f862-1cbe-45fd-bdb1-169e28072fc2	Bật lửa gas	1 cái	3000.00	\N	\N	Khác	162	Bật lửa gas thuộc nhóm Khác, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1hSqu8r_6PxrGBxFeXHkJPg7dzwrFyP-G	neutral	25_34	unisex	daily
182	04931d60-d635-4729-8b9e-1171306f235b	Nến cây (Gói 5 cây)	1 gói	10000.00	\N	\N	Khác	64	Nến cây (Gói 5 cây) thuộc nhóm Khác, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1kLWZySIxqwG26vlVa-eFO4UNkoSz7Nwu	neutral	25_34	unisex	daily
183	5a20e1d3-d558-4cad-ae30-cbb947a1256f	Băng keo trong (Cuộn lớn)	1 cuộn	15000.00	\N	\N	Khác	186	Băng keo trong (Cuộn lớn) thuộc nhóm Khác, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1Rb6ITA9lWZKi93w9euSEyoBU9V5syxM5	neutral	25_34	unisex	daily
184	e366d057-07fc-4551-a1ee-ee55890fbff7	Keo 502 (Chai)	1 chai	5000.00	\N	\N	Khác	76	Keo 502 (Chai) thuộc nhóm Khác, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1gCZApy-6mDjC_E0i4_7AU_oFxkTYyPmD	neutral	25_34	unisex	daily
185	cf4e420e-2ede-4a08-8209-0eaa5a110cf5	Dây rút nhựa (Túi 100 sợi)	1 túi	15000.00	12750	15	Khác	62	Dây rút nhựa (Túi 100 sợi) thuộc nhóm Khác, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=14bpYPcUYPVvJeL_IJwlCa7jdhb7e2Q8k	neutral	25_34	unisex	daily
186	da5a3390-cf73-4a9f-bffc-f6e02a0905b2	Bút bi Thiên Long (Cây)	1 cây	4000.00	3200	20	Văn phòng phẩm	40	Bút bi Thiên Long (Cây) thuộc nhóm Văn phòng phẩm, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1vdI7aLTSWGrAAuzVJe1wpvEKxednP7_P	neutral	25_34	unisex	daily
187	8d1b6427-b718-48bd-8808-6af55eca8d5a	Vở học sinh 96 trang	1 cái	8000.00	6800	15	Văn phòng phẩm	169	Vở học sinh 96 trang thuộc nhóm Văn phòng phẩm, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1azYZjzn6_V9e1AzrwmS99Zs6stsHZ7ve	neutral	25_34	unisex	daily
188	4a5f7c93-02f6-48e0-bcb4-a1c7ae3aec53	Bút chì gỗ 2B	1 cây	3000.00	\N	\N	Văn phòng phẩm	148	Bút chì gỗ 2B thuộc nhóm Văn phòng phẩm, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1OXYhugr2dqWjZyyaBp5PwatPuosvkv3_	neutral	25_34	unisex	daily
189	93e833a2-fb76-46e8-90d0-51b4a2067b2a	Gôm tẩy (Cục)	1 cái	5000.00	\N	\N	Văn phòng phẩm	89	Gôm tẩy (Cục) thuộc nhóm Văn phòng phẩm, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1aq2OSEGvYveqg9JM7Fg2uM5dUkv6Xrvv	neutral	25_34	unisex	daily
190	91a2bcb3-d18b-47dc-ab24-5af040967bf2	Thước kẻ 20cm	1 cái	5000.00	\N	\N	Văn phòng phẩm	13	Thước kẻ 20cm thuộc nhóm Văn phòng phẩm, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1KTF1ommUXC2Cct8BXBNks4sRadeijahe	neutral	25_34	unisex	daily
191	1e416e03-2048-4d85-8f63-b6085adb65ae	Hồ dán giấy (Chai)	1 cái	4000.00	3800	5	Văn phòng phẩm	44	Hồ dán giấy (Chai) thuộc nhóm Văn phòng phẩm, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1t9f5cPRs5UI8b1U3Ye7tuRGau9MlQdUU	neutral	25_34	unisex	daily
192	b812638a-f73d-4a60-9695-eac88da8a809	Bấm kim số 10 (Cái)	1 cái	20000.00	18000	10	Văn phòng phẩm	102	Bấm kim số 10 (Cái) thuộc nhóm Văn phòng phẩm, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1bgT9HvfIn9AlwdrpavgO28Jo_AaCsRxD	neutral	25_34	unisex	daily
193	057d7a10-7e86-4899-a4d3-2bbb14ab8e8d	Bìa hồ sơ Clearbag (Cái)	1 cái	3000.00	\N	\N	Văn phòng phẩm	28	Bìa hồ sơ Clearbag (Cái) thuộc nhóm Văn phòng phẩm, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1JxtEFmMRe_sv9ikaAgkDEc9IS7-NFSg3	neutral	25_34	unisex	daily
194	3fe5094c-900b-4c6d-9730-f0f768c3f1e1	Dao rọc giấy (Cây)	1 cây	10000.00	8500	15	Văn phòng phẩm	161	Dao rọc giấy (Cây) thuộc nhóm Văn phòng phẩm, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1Tn9PHlU92AO5zjTEysYgia7U9OdqkBGO	neutral	25_34	unisex	daily
195	0c817e5a-0d94-4f29-be97-bc218296a244	Khẩu trang y tế (Hộp 50)	1 hộp	35000.00	\N	\N	Chăm sóc sức khỏe	147	Khẩu trang y tế (Hộp 50) thuộc nhóm Chăm sóc sức khỏe, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1YGt-Ik0UsnHKs8WuLlc1pt63QdXPLhF2	neutral	25_34	unisex	daily
196	c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe	Băng cá nhân Urgo (Hộp 100)	1 hộp	25000.00	\N	\N	Chăm sóc sức khỏe	165	Băng cá nhân Urgo (Hộp 100) thuộc nhóm Chăm sóc sức khỏe, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1mplJQKbChmrf_K0xwoWS5K5B8dszuDyW	neutral	25_34	unisex	daily
197	068f6987-474e-4559-aac7-6903691b2dad	Dầu gió xanh Con Ó (Chai)	1 chai	30000.00	\N	\N	Chăm sóc sức khỏe	179	Dầu gió xanh Con Ó (Chai) thuộc nhóm Chăm sóc sức khỏe, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1c51TzpwuJAByCYHKPIcY7571KjInnVlz	neutral	25_34	unisex	daily
198	2c790f44-7ee9-4c1d-9170-0f67eaf7e736	Mũ bảo hiểm nửa đầu	1 cái	80000.00	68000	15	Mũ bảo hiểm	16	Mũ bảo hiểm nửa đầu thuộc nhóm Mũ bảo hiểm, phù hợp cho ngữ cảnh 'travel'.	https://drive.google.com/uc?export=view&id=14UqYYXM9AvJiPhULigAPC7GP4Zs2Sy3i	neutral	25_34	unisex	travel
199	78df9983-9047-45ca-8867-aa9f19c6e3d6	Áo mưa tiện lợi (Cái)	1 cái	10000.00	\N	\N	Đồ dùng thời tiết	104	Áo mưa tiện lợi (Cái) thuộc nhóm Đồ dùng thời tiết, phù hợp cho ngữ cảnh 'rain'.	https://drive.google.com/uc?export=view&id=1UtI3Y9wiYdFwq1Ue59tWA-CNYnILtKHT	fear	25_34	unisex	rain
200	44e0b85c-6165-439b-84b4-6f85374c19e1	Dù cầm tay gấp gọn	1 cái	70000.00	\N	\N	Đồ dùng thời tiết	198	Dù cầm tay gấp gọn thuộc nhóm Đồ dùng thời tiết, phù hợp cho ngữ cảnh 'rain'.	https://drive.google.com/uc?export=view&id=1oaYckH5EK5rhpPdBq1zrU2pj_3JgLIHU	fear	25_34	unisex	rain
201	e2b8c4e1-00d7-476e-9541-5da23db32d9e	Vớ chân nam/nữ (Đôi)	1 đôi	12000.00	\N	\N	Phụ kiện & quần áo nhỏ	122	Vớ chân nam/nữ (Đôi) thuộc nhóm Phụ kiện & quần áo nhỏ, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1DPK8baEyAkvTT-2192x1eoXQ3dMSNvap	neutral	18_24	male	daily
202	0a2dc91b-cdf6-46b2-99d4-697dbd70067f	Tai nghe có dây (Cái)	1 cái	50000.00	42500	15	Phụ kiện điện thoại	12	Tai nghe có dây (Cái) thuộc nhóm Phụ kiện điện thoại, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1EczD1ZsVYD2BN7IA4n0fi2VW1nrJLyrz	neutral	25_34	unisex	daily
203	cd3322e6-fa79-4ff1-9ec1-017716f5f8af	Cáp sạc Android/iPhone	1 cái	40000.00	\N	\N	Phụ kiện điện thoại	87	Cáp sạc Android/iPhone thuộc nhóm Phụ kiện điện thoại, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1b28JXgGaArAF01Hlec8RFE9eRq28zATH	neutral	25_34	unisex	daily
204	e03863a3-5056-43ed-af9e-77bdb148f682	Củ sạc USB 2 cổng	1 cái	50000.00	45000	10	Phụ kiện điện thoại	25	Củ sạc USB 2 cổng thuộc nhóm Phụ kiện điện thoại, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1lMq5Xx21BnxbNYYoDIP-12GeN3Po-9JS	neutral	25_34	unisex	daily
205	57f232f5-1156-4349-a927-f00ce7a05827	Thẻ cào điện thoại 20k	1 cái	20000.00	19000	5	Thẻ cào	17	Thẻ cào điện thoại 20k thuộc nhóm Thẻ cào, phù hợp cho ngữ cảnh 'daily'.	https://drive.google.com/uc?export=view&id=1xFF9qyg7eTPJE4dCCRZOFjjlqpL_25_W	neutral	25_34	unisex	daily
\.


--
-- Data for Name: promotion_branches; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_branches (id, promotion_id, branch_id) FROM stdin;
1	1	HCM_Q7
2	2	HCM_Q7
3	2	HN_CG
\.


--
-- Data for Name: promotion_products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_products (id, promotion_id, product_id, discount_value, max_qty_per_customer) FROM stdin;
1	1	104	10	1
2	1	199	10	1
3	1	11	10	\N
4	1	156	10	\N
5	1	189	10	1
6	1	98	10	2
7	1	185	10	\N
8	1	81	10	1
9	1	101	10	\N
10	1	157	10	1
11	1	191	10	2
12	1	147	10	3
13	2	199	10000	1
14	2	74	15000	1
15	2	119	5000	2
16	2	43	10000	\N
17	2	109	10000	\N
18	2	76	5000	2
19	2	157	10000	2
20	2	14	10000	1
21	2	177	10000	3
22	2	133	15000	2
23	2	37	15000	1
24	2	166	5000	1
\.


--
-- Data for Name: promotions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotions (id, code, name, discount_type, start_at, end_at, is_active, created_at) FROM stdin;
1	WEEKEND10	Cuối tuần giảm 10%	PERCENT	2026-03-28 17:39:14.087287	2026-04-07 17:39:14.087287	t	2026-03-31 17:39:14.089796
2	COMBOFIX	Combo ưu đãi giá cố định	FIXED	2026-03-26 17:39:14.087287	2026-04-10 17:39:14.08828	t	2026-03-31 17:39:14.089796
\.


--
-- Data for Name: recommendations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recommendations (id, branch_id, transaction_id, "timestamp", customer_id, device_id, face_attributes, recommended_products, items_count, accepted, purchased_items, created_at) FROM stdin;
1	HN_CG	TXN-20260220-00001	2026-02-20 12:07:14.118651+00	6	EDGE_HN_CG_01	{"age_group": "35_44", "gender": "female"}	[{"product_id": 39, "product_code": "0e3740f8-9d6f-4f7b-b1bb-3b719c18c93b", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "score": 0.89}, {"product_id": 42, "product_code": "13cbc909-c57c-4c13-8304-1abb2e7d16e6", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "score": 0.62}, {"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "score": 0.72}, {"product_id": 46, "product_code": "8636600f-9b6f-4cb4-a120-cf70c55c20e6", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "score": 0.88}]	4	f	[{"product_id": 182, "product_code": "04931d60-d635-4729-8b9e-1171306f235b", "name": "N\\u1ebfn c\\u00e2y (G\\u00f3i 5 c\\u00e2y)", "qty": 3, "unit_price": 10000.0}, {"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "qty": 2, "unit_price": 35500.0}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 1, "unit_price": 6800.0}, {"product_id": 203, "product_code": "cd3322e6-fa79-4ff1-9ec1-017716f5f8af", "name": "C\\u00e1p s\\u1ea1c Android/iPhone", "qty": 1, "unit_price": 40000.0}, {"product_id": 131, "product_code": "596df514-3b1f-463c-92f3-fdfb93e41684", "name": "Ng\\u0169 c\\u1ed1c dinh d\\u01b0\\u1ee1ng (G\\u00f3i 500g)", "qty": 2, "unit_price": 44000.0}]	2026-02-20 12:15:14.118651
2	HCM_Q1	TXN-20260228-00002	2026-02-28 01:55:14.132516+00	17	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "female"}	[{"product_id": 61, "product_code": "cfcd4967-30f5-4502-acbe-6b72adfab32b", "name": "L\\u1ed1c 4 h\\u0169 s\\u1eefa chua \\u0103n co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Lothamilk 100g", "score": 0.85}, {"product_id": 56, "product_code": "c11379c8-f11b-4bc0-bc6b-32483cb53628", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p 170ml", "score": 0.77}, {"product_id": 151, "product_code": "4e6b1095-a3cb-4d03-b747-0b3080e9a160", "name": "X\\u00e0 b\\u00f4ng c\\u1ee5c X-Men", "score": 0.77}]	3	f	[{"product_id": 118, "product_code": "071cea0f-3714-449f-b21f-86ddce66fd4d", "name": "C\\u00e1 h\\u1ed9p 3 C\\u00f4 G\\u00e1i", "qty": 1, "unit_price": 20000.0}]	2026-02-28 02:05:14.132516
3	HN_CG	TXN-20260309-00003	2026-03-09 16:20:14.15531+00	10	EDGE_HN_CG_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "score": 0.64}, {"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.98}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "score": 0.66}, {"product_id": 13, "product_code": "2bcfabb7-eedf-4da1-ad8c-f464bb3e5ee6", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Tam Th\\u00e1i T\\u1eed Nh\\u1ea5t Ca s\\u00e1nh \\u0111\\u1eadm", "score": 0.71}]	4	f	[{"product_id": 168, "product_code": "131a23d6-1d20-4d98-b9dd-2d0eb19e0b54", "name": "B\\u00f3ng \\u0111\\u00e8n LED \\u0110i\\u1ec7n Quang 20W", "qty": 1, "unit_price": 45000.0}]	2026-03-09 16:30:14.15531
4	HCM_Q1	TXN-20260304-00004	2026-03-04 00:33:14.165717+00	21	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "unisex"}	[{"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.8}, {"product_id": 135, "product_code": "c7f42ff3-6047-4f08-866c-1b32209e3f90", "name": "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "score": 0.86}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "score": 0.83}]	3	t	[{"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "qty": 2, "unit_price": 65000.0}, {"product_id": 18, "product_code": "fc0359c0-800a-40c9-8e49-660ab593f7e3", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "qty": 2, "unit_price": 105300.0}, {"product_id": 195, "product_code": "0c817e5a-0d94-4f29-be97-bc218296a244", "name": "Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "qty": 1, "unit_price": 35000.0}]	2026-03-04 00:35:14.165717
5	HN_CG	TXN-20260220-00005	2026-02-20 05:38:14.176984+00	55	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "score": 0.94}, {"product_id": 128, "product_code": "a010e906-1854-42a0-944b-8bcd42f82e55", "name": "Snack Khoai t\\u00e2y O'Star", "score": 0.69}, {"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "score": 0.71}, {"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "score": 0.67}]	4	f	[{"product_id": 67, "product_code": "a67c2aa4-d081-41f2-a440-30d00cd60c5b", "name": "L\\u1ed1c 2 h\\u0169 s\\u01b0\\u0303a chua n\\u00ea\\u0301p c\\u00e2\\u0309m Sa\\u0300i Go\\u0300n Milk 120g", "qty": 1, "unit_price": 27000.0}, {"product_id": 135, "product_code": "c7f42ff3-6047-4f08-866c-1b32209e3f90", "name": "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "qty": 3, "unit_price": 18000.0}, {"product_id": 148, "product_code": "d6f2920e-e16a-4096-8159-a938f4b8ce59", "name": "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "qty": 3, "unit_price": 16200.0}]	2026-02-20 05:40:14.176984
6	HCM_Q1	TXN-20260330-00006	2026-03-30 21:21:14.188043+00	22	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "score": 0.72}, {"product_id": 130, "product_code": "260fa104-9d28-45a7-bb5e-06b373367221", "name": "B\\u00e1nh quy Cosy (G\\u00f3i 200g)", "score": 0.6}, {"product_id": 141, "product_code": "0b4a4b09-46ec-4a6b-bc41-df4393645a3e", "name": "N\\u01b0\\u1edbc x\\u1ea3 v\\u1ea3i Comfort (T\\u00fai 1.6L)", "score": 0.86}]	3	f	[{"product_id": 144, "product_code": "2869b301-5fec-407f-b472-6e72ee034c9f", "name": "N\\u01b0\\u1edbc r\\u1eeda ch\\u00e9n Sunlight (750ml)", "qty": 3, "unit_price": 21250.0}, {"product_id": 164, "product_code": "5576682c-00ee-4aab-8888-3526e2bf7626", "name": "Bao tay cao su (\\u0110\\u00f4i)", "qty": 2, "unit_price": 15300.0}, {"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "qty": 2, "unit_price": 37000.0}]	2026-03-30 21:27:14.188043
19	HN_CG	TXN-20260314-00019	2026-03-14 03:32:14.324943+00	55	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 146, "product_code": "fd9f259d-1ea9-4994-ae7d-d00f930fcde4", "name": "N\\u01b0\\u1edbc t\\u1ea9y b\\u1ed3n c\\u1ea7u Vim (900ml)", "score": 0.87}, {"product_id": 124, "product_code": "4603c6b9-3f0e-4455-9c80-afad12742d51", "name": "N\\u01b0\\u1edbc su\\u1ed1i Aquafina (500ml)", "score": 0.64}]	2	t	[{"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "qty": 3, "unit_price": 15000.0}, {"product_id": 129, "product_code": "fb1ea21f-cda1-4678-a372-358a68f83a9c", "name": "K\\u1eb9o c\\u1ee9ng Dynamite", "qty": 3, "unit_price": 8000.0}]	2026-03-14 03:40:14.324943
7	HCM_Q1	TXN-20260323-00007	2026-03-23 02:21:14.20472+00	22	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "score": 0.71}, {"product_id": 15, "product_code": "cebc7811-c35c-4a9d-8b37-854d28b07b22", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g", "score": 0.88}, {"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "score": 0.72}]	3	f	[{"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 3, "unit_price": 52000.0}, {"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "qty": 2, "unit_price": 19000.0}, {"product_id": 10, "product_code": "63a338bb-de9f-45cb-b283-d0abab06015d", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Nh\\u1ecb Ca Tam Th\\u00e1i T\\u1eed chai", "qty": 3, "unit_price": 8800.0}, {"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "qty": 2, "unit_price": 35000.0}]	2026-03-23 02:30:14.20472
8	HCM_Q7	TXN-20260218-00008	2026-02-18 23:38:14.217184+00	\N	EDGE_HCM_Q7_01	{"age_group": "25_34", "gender": "female"}	[{"product_id": 30, "product_code": "f91639d0-6dfc-4083-a260-a2ad3c65eb41", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf g\\u00e0 \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 65g", "score": 0.87}, {"product_id": 201, "product_code": "e2b8c4e1-00d7-476e-9541-5da23db32d9e", "name": "V\\u1edb ch\\u00e2n nam/n\\u1eef (\\u0110\\u00f4i)", "score": 0.72}, {"product_id": 193, "product_code": "057d7a10-7e86-4899-a4d3-2bbb14ab8e8d", "name": "B\\u00eca h\\u1ed3 s\\u01a1 Clearbag (C\\u00e1i)", "score": 0.61}, {"product_id": 79, "product_code": "dcf4b890-c91e-4ef3-bf6e-b4433d191182", "name": "Bia Corona Extra chai 250ml", "score": 0.76}]	4	t	[{"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 1, "unit_price": 37050.0}, {"product_id": 87, "product_code": "b336ff02-4595-449e-ada1-c89697da7fc2", "name": "Th\\u00f9ng 12 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 1.5 l\\u00edt", "qty": 3, "unit_price": 180000.0}, {"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "qty": 3, "unit_price": 5000.0}]	2026-02-18 23:46:14.217184
9	HCM_Q1	TXN-20260227-00009	2026-02-27 16:46:14.227101+00	3	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 124, "product_code": "4603c6b9-3f0e-4455-9c80-afad12742d51", "name": "N\\u01b0\\u1edbc su\\u1ed1i Aquafina (500ml)", "score": 0.72}, {"product_id": 188, "product_code": "4a5f7c93-02f6-48e0-bcb4-a1c7ae3aec53", "name": "B\\u00fat ch\\u00ec g\\u1ed7 2B", "score": 0.72}, {"product_id": 135, "product_code": "c7f42ff3-6047-4f08-866c-1b32209e3f90", "name": "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "score": 0.89}]	3	t	[{"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "qty": 2, "unit_price": 250000.0}, {"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "qty": 3, "unit_price": 5000.0}]	2026-02-27 16:48:14.227101
10	HN_CG	TXN-20260221-00010	2026-02-21 15:08:14.23688+00	60	EDGE_HN_CG_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "score": 0.85}, {"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "score": 0.72}]	2	f	[{"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "qty": 2, "unit_price": 33250.0}]	2026-02-21 15:18:14.23688
11	HCM_Q7	TXN-20260322-00011	2026-03-22 12:17:14.24567+00	43	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "unisex"}	[{"product_id": 144, "product_code": "2869b301-5fec-407f-b472-6e72ee034c9f", "name": "N\\u01b0\\u1edbc r\\u1eeda ch\\u00e9n Sunlight (750ml)", "score": 0.81}, {"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "score": 0.81}, {"product_id": 27, "product_code": "b048d361-49e5-4b05-8560-1b82458ef15b", "name": "B\\u00fan c\\u00e1 cay H\\u1eb1ng Nga g\\u00f3i 70g", "score": 0.7}, {"product_id": 53, "product_code": "d5b1b057-5bcf-4629-a973-7f8e9c0bca3c", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "score": 0.96}]	4	t	[{"product_id": 70, "product_code": "83bab65c-5e02-45a8-936d-58eaa4e206a2", "name": "Th\\u00f9ng 24 lon Bia Tiger lon 250ml", "qty": 1, "unit_price": 258000.0}]	2026-03-22 12:22:14.24567
12	HCM_Q7	TXN-20260328-00012	2026-03-28 15:03:14.254948+00	2	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 177, "product_code": "991f1b12-1dc2-498a-83bb-75bf860ad56b", "name": "K\\u1eb9p qu\\u1ea7n \\u00e1o (V\\u1ec9 20)", "score": 0.74}, {"product_id": 180, "product_code": "8f382477-a9b4-44d6-bf2a-59fae61d9166", "name": "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "score": 0.73}, {"product_id": 115, "product_code": "11086cc9-d30a-4145-acaf-8e2084c851f0", "name": "T\\u01b0\\u01a1ng \\u1edbt Chinsu (250g)", "score": 0.68}, {"product_id": 158, "product_code": "8526f078-cb9e-4c78-ae7a-ab1526ddda7d", "name": "N\\u01b0\\u1edbc r\\u1eeda tay kh\\u00f4 (Chai 100ml)", "score": 0.89}]	4	f	[{"product_id": 173, "product_code": "78a22c2f-8513-49ba-95df-227bbb48543e", "name": "Gi\\u1ea5y b\\u1ea1c n\\u01b0\\u1edbng (Cu\\u1ed9n)", "qty": 2, "unit_price": 25000.0}, {"product_id": 13, "product_code": "2bcfabb7-eedf-4da1-ad8c-f464bb3e5ee6", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Tam Th\\u00e1i T\\u1eed Nh\\u1ea5t Ca s\\u00e1nh \\u0111\\u1eadm", "qty": 1, "unit_price": 26000.0}, {"product_id": 28, "product_code": "91aed179-28dd-4cb2-96db-44c239795d5f", "name": "Ph\\u1edf b\\u00f2 Vifon g\\u00f3i 90g (c\\u00f3 g\\u00f3i th\\u1ecbt th\\u1eadt)", "qty": 3, "unit_price": 17000.0}, {"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "qty": 3, "unit_price": 35500.0}]	2026-03-28 15:12:14.254948
27	HN_CG	TXN-20260328-00027	2026-03-28 05:08:14.396564+00	50	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 68, "product_code": "5d22b162-c9c6-4540-ab8a-ff709f7148e3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa h\\u01b0\\u01a1ng vani Hoff 55g", "score": 0.63}, {"product_id": 46, "product_code": "8636600f-9b6f-4cb4-a120-cf70c55c20e6", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "score": 0.97}, {"product_id": 113, "product_code": "e7753b8d-850e-4de8-935e-b4cb3e98063a", "name": "\\u0110\\u01b0\\u1eddng tinh luy\\u1ec7n Bi\\u00ean H\\u00f2a (1kg)", "score": 0.68}]	3	f	[{"product_id": 71, "product_code": "bbd97816-ba62-4a9a-8384-7d7bff031ab1", "name": "Th\\u00f9ng 24 lon Bia Heineken Silver 250ml", "qty": 2, "unit_price": 355000.0}]	2026-03-28 05:15:14.396564
13	HN_CG	TXN-20260220-00013	2026-02-20 08:33:14.262969+00	20	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "score": 0.79}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.62}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "score": 0.64}]	3	f	[{"product_id": 121, "product_code": "827e4a51-3225-4f53-a04f-e03b0e5b9f8d", "name": "S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "qty": 2, "unit_price": 26000.0}, {"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "qty": 2, "unit_price": 20800.0}, {"product_id": 58, "product_code": "54ee9149-caee-4c90-9f0d-8a89945ffa5f", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p chai 170ml", "qty": 1, "unit_price": 10000.0}, {"product_id": 37, "product_code": "6f831c1e-17cc-4ea1-848a-33cbc4c7ec9a", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 3, "unit_price": 375000.0}]	2026-02-20 08:41:14.262969
14	HN_CG	TXN-20260223-00014	2026-02-23 21:28:14.272251+00	26	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 152, "product_code": "a544d61d-edb8-4b54-ad19-8f4745d8307a", "name": "S\\u1eefa r\\u1eeda m\\u1eb7t Acnes (100g)", "score": 0.84}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "score": 0.81}, {"product_id": 62, "product_code": "8e6ed997-217f-4dc4-ba92-611c2a6bbd91", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n \\u00edt \\u0111\\u01b0\\u1eddng Nutimilk 100g", "score": 0.97}]	3	f	[{"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "qty": 2, "unit_price": 45000.0}]	2026-02-23 21:35:14.272251
15	HCM_Q7	TXN-20260326-00015	2026-03-26 17:38:14.283835+00	22	EDGE_HCM_Q7_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 143, "product_code": "a3a7acbd-4cf2-4f56-9930-63c15fc00ecc", "name": "B\\u00e0n ch\\u1ea3i \\u0111\\u00e1nh r\\u0103ng Colgate", "score": 0.67}, {"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.96}, {"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "score": 0.63}]	3	f	[{"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "qty": 3, "unit_price": 40000.0}, {"product_id": 61, "product_code": "cfcd4967-30f5-4502-acbe-6b72adfab32b", "name": "L\\u1ed1c 4 h\\u0169 s\\u1eefa chua \\u0103n co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Lothamilk 100g", "qty": 3, "unit_price": 25500.0}, {"product_id": 45, "product_code": "70aecc30-273a-4640-ae9e-bf45c96ba51b", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng lof Kun 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 2, "unit_price": 376000.0}, {"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "qty": 1, "unit_price": 10000.0}, {"product_id": 172, "product_code": "17f75c8c-ac61-4e32-8355-90e37f46cc3c", "name": "M\\u00e0ng b\\u1ecdc th\\u1ef1c ph\\u1ea9m (Cu\\u1ed9n)", "qty": 3, "unit_price": 19000.0}]	2026-03-26 17:40:14.283835
16	HCM_Q1	TXN-20260322-00016	2026-03-22 02:59:14.294506+00	\N	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 82, "product_code": "7301020d-0402-4b78-969e-9e061a2a830f", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb d\\u00e2u 12% chai 360ml", "score": 0.95}, {"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "score": 0.72}, {"product_id": 146, "product_code": "fd9f259d-1ea9-4994-ae7d-d00f930fcde4", "name": "N\\u01b0\\u1edbc t\\u1ea9y b\\u1ed3n c\\u1ea7u Vim (900ml)", "score": 0.96}, {"product_id": 204, "product_code": "e03863a3-5056-43ed-af9e-77bdb148f682", "name": "C\\u1ee7 s\\u1ea1c USB 2 c\\u1ed5ng", "score": 0.77}]	4	t	[{"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "qty": 2, "unit_price": 8500.0}, {"product_id": 163, "product_code": "5acdac1a-898e-4a9f-8acd-f8590ce29d7b", "name": "C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)", "qty": 2, "unit_price": 12000.0}, {"product_id": 1, "product_code": "9583297f-78a6-4dfc-84a5-82f214b9e86e", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh tinh luy\\u1ec7n Janbee", "qty": 3, "unit_price": 69500.0}, {"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "qty": 3, "unit_price": 425000.0}, {"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "qty": 2, "unit_price": 10000.0}]	2026-03-22 03:05:14.294506
17	HCM_Q7	TXN-20260316-00017	2026-03-16 03:51:14.305518+00	36	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "score": 0.81}, {"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "score": 0.85}, {"product_id": 112, "product_code": "26a9aea3-5f05-45b5-81af-801b4e2e9d24", "name": "B\\u1ed9t ng\\u1ecdt Ajinomoto (454g)", "score": 0.78}]	3	t	[{"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "qty": 3, "unit_price": 52000.0}, {"product_id": 73, "product_code": "c57b5193-7c6a-4e72-be5f-bf08951cd0ec", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "qty": 2, "unit_price": 375250.0}, {"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 3, "unit_price": 37050.0}]	2026-03-16 03:55:14.305518
18	HN_CG	TXN-20260227-00018	2026-02-27 20:03:14.315636+00	5	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 107, "product_code": "950bc1a0-a654-4c1f-937a-91b5753c75c0", "name": "M\\u00ec H\\u1ea3o H\\u1ea3o T\\u00f4m Chua Cay", "score": 0.83}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "score": 0.76}, {"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "score": 0.67}, {"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "score": 0.79}]	4	t	[{"product_id": 37, "product_code": "6f831c1e-17cc-4ea1-848a-33cbc4c7ec9a", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 1, "unit_price": 375000.0}]	2026-02-27 20:12:14.315636
20	HCM_Q7	TXN-20260216-00020	2026-02-16 20:29:14.334038+00	34	EDGE_HCM_Q7_01	{"age_group": "45_54", "gender": "unisex"}	[{"product_id": 137, "product_code": "f0cac878-618a-41d5-9319-8b85e8c0fc27", "name": "D\\u1ea7u g\\u1ed9i Clear Men (Chai 630g)", "score": 0.78}, {"product_id": 200, "product_code": "44e0b85c-6165-439b-84b4-6f85374c19e1", "name": "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "score": 0.79}, {"product_id": 3, "product_code": "fb8b76f0-baea-440d-acf3-f80e738a7958", "name": "D\\u1ea7u \\u0103n th\\u01b0\\u1ee3ng h\\u1ea1ng Neptune Light", "score": 0.78}]	3	f	[{"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "qty": 3, "unit_price": 250000.0}, {"product_id": 63, "product_code": "ffab1e43-67a3-4455-b9f5-ece65ebd4ebb", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n nha \\u0111am Lothamilk 100g", "qty": 3, "unit_price": 30000.0}, {"product_id": 121, "product_code": "827e4a51-3225-4f53-a04f-e03b0e5b9f8d", "name": "S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "qty": 3, "unit_price": 26000.0}, {"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "qty": 3, "unit_price": 12000.0}, {"product_id": 190, "product_code": "91a2bcb3-d18b-47dc-ab24-5af040967bf2", "name": "Th\\u01b0\\u1edbc k\\u1ebb 20cm", "qty": 2, "unit_price": 5000.0}]	2026-02-16 20:35:14.334038
21	HCM_Q7	TXN-20260315-00021	2026-03-15 15:54:14.342716+00	60	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "score": 0.71}, {"product_id": 160, "product_code": "d560d1cf-83fa-47da-9467-26fa419a73ba", "name": "Thu\\u1ed1c x\\u1ecbt mu\\u1ed7i Raid (600ml)", "score": 0.63}, {"product_id": 7, "product_code": "271cc8ca-e37c-4277-90dc-36f3b624ac9a", "name": "N\\u01b0\\u1edbc ch\\u1ea5m chua ng\\u1ecdt Nam Ng\\u01b0 \\u1edbt t\\u1ecfi L\\u00fd S\\u01a1n", "score": 0.79}]	3	f	[{"product_id": 192, "product_code": "b812638a-f73d-4a60-9695-eac88da8a809", "name": "B\\u1ea5m kim s\\u1ed1 10 (C\\u00e1i)", "qty": 2, "unit_price": 18000.0}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 3, "unit_price": 9600.0}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 1, "unit_price": 6800.0}, {"product_id": 201, "product_code": "e2b8c4e1-00d7-476e-9541-5da23db32d9e", "name": "V\\u1edb ch\\u00e2n nam/n\\u1eef (\\u0110\\u00f4i)", "qty": 3, "unit_price": 12000.0}, {"product_id": 145, "product_code": "3f023ad8-02a4-4e95-8ec6-553c622e7d9d", "name": "N\\u01b0\\u1edbc lau s\\u00e0n Gift (1 L\\u00edt)", "qty": 1, "unit_price": 22000.0}]	2026-03-15 15:59:14.342716
22	HCM_Q7	TXN-20260321-00022	2026-03-21 20:01:14.3519+00	39	EDGE_HCM_Q7_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 61, "product_code": "cfcd4967-30f5-4502-acbe-6b72adfab32b", "name": "L\\u1ed1c 4 h\\u0169 s\\u1eefa chua \\u0103n co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Lothamilk 100g", "score": 0.8}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "score": 0.61}, {"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "score": 0.97}, {"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "score": 0.97}]	4	t	[{"product_id": 152, "product_code": "a544d61d-edb8-4b54-ad19-8f4745d8307a", "name": "S\\u1eefa r\\u1eeda m\\u1eb7t Acnes (100g)", "qty": 2, "unit_price": 52250.0}, {"product_id": 190, "product_code": "91a2bcb3-d18b-47dc-ab24-5af040967bf2", "name": "Th\\u01b0\\u1edbc k\\u1ebb 20cm", "qty": 1, "unit_price": 5000.0}]	2026-03-21 20:11:14.3519
23	HCM_Q7	TXN-20260309-00023	2026-03-09 15:54:14.361431+00	47	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "female"}	[{"product_id": 103, "product_code": "215bb35c-37c7-451d-8a5e-19d774e2ec28", "name": "B\\u00e1nh quy socola chip nh\\u00e2n socola Parle Platina Hide & Seek g\\u00f3i 112.5g", "score": 0.78}, {"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "score": 0.96}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.95}]	3	t	[{"product_id": 54, "product_code": "c5544e90-b58e-4a17-89af-5f131087703b", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "qty": 2, "unit_price": 34500.0}, {"product_id": 148, "product_code": "d6f2920e-e16a-4096-8159-a938f4b8ce59", "name": "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "qty": 1, "unit_price": 16200.0}]	2026-03-09 15:58:14.361431
24	HCM_Q7	TXN-20260216-00024	2026-02-16 16:29:14.369984+00	52	EDGE_HCM_Q7_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 70, "product_code": "83bab65c-5e02-45a8-936d-58eaa4e206a2", "name": "Th\\u00f9ng 24 lon Bia Tiger lon 250ml", "score": 0.7}, {"product_id": 86, "product_code": "4544a866-890a-460f-93db-542521c75fa7", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt 7 Up v\\u1ecb chanh 390ml", "score": 0.82}, {"product_id": 69, "product_code": "c6db64ee-92ea-4113-8297-a2e94c4f6be6", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa dinh d\\u01b0\\u1ee1ng Gotz 55g", "score": 0.78}, {"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "score": 0.86}]	4	f	[{"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "qty": 3, "unit_price": 65000.0}, {"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "qty": 3, "unit_price": 4750.0}, {"product_id": 81, "product_code": "1485f5ea-a1a9-4383-98c4-338a415c5e3d", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb \\u0111\\u00e0o 12% chai 360ml", "qty": 2, "unit_price": 42750.0}, {"product_id": 136, "product_code": "53ec6e96-b534-42e0-a986-9d6d2d36e86d", "name": "D\\u1ea7u g\\u1ed9i Sunsilk (Chai 650g)", "qty": 2, "unit_price": 88000.0}]	2026-02-16 16:33:14.369984
25	HCM_Q1	TXN-20260331-00025	2026-03-31 04:31:14.378846+00	44	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 90, "product_code": "61c35ff1-5a92-4568-9870-e345bc73a24c", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml", "score": 0.71}, {"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.67}, {"product_id": 186, "product_code": "da5a3390-cf73-4a9f-bffc-f6e02a0905b2", "name": "B\\u00fat bi Thi\\u00ean Long (C\\u00e2y)", "score": 0.61}]	3	t	[{"product_id": 18, "product_code": "fc0359c0-800a-40c9-8e49-660ab593f7e3", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "qty": 3, "unit_price": 105300.0}]	2026-03-31 04:33:14.378846
26	HN_CG	TXN-20260323-00026	2026-03-23 04:55:14.388386+00	8	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "score": 0.67}, {"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "score": 0.71}]	2	f	[{"product_id": 155, "product_code": "4dd70e94-850f-406f-a440-c4a161d99325", "name": "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "qty": 3, "unit_price": 35000.0}]	2026-03-23 04:57:14.388386
28	HCM_Q7	TXN-20260327-00028	2026-03-27 14:56:14.404976+00	7	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 168, "product_code": "131a23d6-1d20-4d98-b9dd-2d0eb19e0b54", "name": "B\\u00f3ng \\u0111\\u00e8n LED \\u0110i\\u1ec7n Quang 20W", "score": 0.6}, {"product_id": 164, "product_code": "5576682c-00ee-4aab-8888-3526e2bf7626", "name": "Bao tay cao su (\\u0110\\u00f4i)", "score": 0.61}]	2	f	[{"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "qty": 3, "unit_price": 5000.0}, {"product_id": 67, "product_code": "a67c2aa4-d081-41f2-a440-30d00cd60c5b", "name": "L\\u1ed1c 2 h\\u0169 s\\u01b0\\u0303a chua n\\u00ea\\u0301p c\\u00e2\\u0309m Sa\\u0300i Go\\u0300n Milk 120g", "qty": 2, "unit_price": 27000.0}, {"product_id": 27, "product_code": "b048d361-49e5-4b05-8560-1b82458ef15b", "name": "B\\u00fan c\\u00e1 cay H\\u1eb1ng Nga g\\u00f3i 70g", "qty": 2, "unit_price": 10000.0}, {"product_id": 9, "product_code": "e4c1b87f-da03-460d-970f-cccf1b363bc7", "name": "N\\u01b0\\u1edbc m\\u1eafm Chinsu c\\u00e1 c\\u01a1m bi\\u1ec3n \\u0111\\u00f4ng 25 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 1, "unit_price": 48450.0}]	2026-03-27 15:03:14.404976
29	HN_CG	TXN-20260327-00029	2026-03-27 00:16:14.413933+00	50	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "score": 0.75}, {"product_id": 86, "product_code": "4544a866-890a-460f-93db-542521c75fa7", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt 7 Up v\\u1ecb chanh 390ml", "score": 0.84}, {"product_id": 175, "product_code": "c55a887f-03c5-45e6-9934-5f8a9a007306", "name": "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "score": 0.96}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.63}]	4	t	[{"product_id": 123, "product_code": "b5986a34-443f-4122-a13b-528f10e97ea5", "name": "Tr\\u00e0 Lipton T\\u00fai l\\u1ecdc (H\\u1ed9p 25 g\\u00f3i)", "qty": 1, "unit_price": 35000.0}, {"product_id": 112, "product_code": "26a9aea3-5f05-45b5-81af-801b4e2e9d24", "name": "B\\u1ed9t ng\\u1ecdt Ajinomoto (454g)", "qty": 2, "unit_price": 32000.0}, {"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "qty": 3, "unit_price": 39000.0}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 2, "unit_price": 6800.0}]	2026-03-27 00:25:14.413933
30	HCM_Q7	TXN-20260307-00030	2026-03-07 13:55:14.424241+00	3	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "score": 0.61}, {"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "score": 0.61}, {"product_id": 36, "product_code": "6ea649b0-f9e4-44cb-9fb9-768d1889cdf6", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "score": 0.98}]	3	f	[{"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "qty": 3, "unit_price": 10000.0}, {"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "qty": 2, "unit_price": 34000.0}, {"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "qty": 2, "unit_price": 349000.0}, {"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "qty": 1, "unit_price": 12000.0}]	2026-03-07 13:59:14.424241
31	HCM_Q7	TXN-20260309-00031	2026-03-09 18:34:14.433793+00	54	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "unisex"}	[{"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "score": 0.88}, {"product_id": 138, "product_code": "8e13d676-f7e9-477f-940b-813f80469993", "name": "S\\u1eefa t\\u1eafm Lifebuoy (Chai 850g)", "score": 0.69}, {"product_id": 39, "product_code": "0e3740f8-9d6f-4f7b-b1bb-3b719c18c93b", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "score": 0.63}]	3	f	[{"product_id": 5, "product_code": "9258ca2f-5e05-4eac-be09-b5a69a4b9cd0", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0 nh\\u00e3n v\\u00e0ng 14 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 2, "unit_price": 41500.0}, {"product_id": 10, "product_code": "63a338bb-de9f-45cb-b283-d0abab06015d", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Nh\\u1ecb Ca Tam Th\\u00e1i T\\u1eed chai", "qty": 1, "unit_price": 8800.0}, {"product_id": 87, "product_code": "b336ff02-4595-449e-ada1-c89697da7fc2", "name": "Th\\u00f9ng 12 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 1.5 l\\u00edt", "qty": 1, "unit_price": 180000.0}, {"product_id": 15, "product_code": "cebc7811-c35c-4a9d-8b37-854d28b07b22", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g", "qty": 3, "unit_price": 110200.0}]	2026-03-09 18:37:14.433793
32	HCM_Q1	TXN-20260219-00032	2026-02-19 15:40:14.442963+00	9	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "score": 0.66}, {"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "score": 0.82}]	2	f	[{"product_id": 45, "product_code": "70aecc30-273a-4640-ae9e-bf45c96ba51b", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng lof Kun 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 2, "unit_price": 376000.0}]	2026-02-19 15:42:14.442963
33	HCM_Q1	TXN-20260225-00033	2026-02-25 13:13:14.453237+00	52	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 71, "product_code": "bbd97816-ba62-4a9a-8384-7d7bff031ab1", "name": "Th\\u00f9ng 24 lon Bia Heineken Silver 250ml", "score": 0.89}, {"product_id": 37, "product_code": "6f831c1e-17cc-4ea1-848a-33cbc4c7ec9a", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "score": 0.66}]	2	t	[{"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "qty": 1, "unit_price": 45000.0}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 1, "unit_price": 170000.0}, {"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "qty": 3, "unit_price": 33250.0}, {"product_id": 148, "product_code": "d6f2920e-e16a-4096-8159-a938f4b8ce59", "name": "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "qty": 1, "unit_price": 16200.0}]	2026-02-25 13:19:14.453237
104	HCM_Q1	TXN-20260311-00104	2026-03-11 05:21:15.209137+00	27	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 139, "product_code": "efbd986b-4531-4883-afb4-194c9b59a109", "name": "B\\u1ed9t gi\\u1eb7t OMO (T\\u00fai 3kg)", "score": 0.71}, {"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "score": 0.67}]	2	t	[{"product_id": 136, "product_code": "53ec6e96-b534-42e0-a986-9d6d2d36e86d", "name": "D\\u1ea7u g\\u1ed9i Sunsilk (Chai 650g)", "qty": 1, "unit_price": 88000.0}]	2026-03-11 05:23:15.209137
34	HCM_Q1	TXN-20260326-00034	2026-03-26 17:34:14.461893+00	41	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "score": 0.78}, {"product_id": 203, "product_code": "cd3322e6-fa79-4ff1-9ec1-017716f5f8af", "name": "C\\u00e1p s\\u1ea1c Android/iPhone", "score": 0.65}, {"product_id": 198, "product_code": "2c790f44-7ee9-4c1d-9170-0f67eaf7e736", "name": "M\\u0169 b\\u1ea3o hi\\u1ec3m n\\u1eeda \\u0111\\u1ea7u", "score": 0.65}]	3	f	[{"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "qty": 1, "unit_price": 5000.0}, {"product_id": 200, "product_code": "44e0b85c-6165-439b-84b4-6f85374c19e1", "name": "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "qty": 1, "unit_price": 70000.0}, {"product_id": 41, "product_code": "8c0bd0e0-9c72-4d67-9c29-61b269b31df8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 3, "unit_price": 355000.0}, {"product_id": 5, "product_code": "9258ca2f-5e05-4eac-be09-b5a69a4b9cd0", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0 nh\\u00e3n v\\u00e0ng 14 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 3, "unit_price": 41500.0}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "qty": 3, "unit_price": 18000.0}]	2026-03-26 17:39:14.461893
35	HN_CG	TXN-20260312-00035	2026-03-12 06:09:14.472206+00	46	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.97}, {"product_id": 159, "product_code": "faa88516-1182-495d-981d-3a5f206d2770", "name": "S\\u00e1p kh\\u1eed m\\u00f9i ph\\u00f2ng (H\\u1ed9p)", "score": 0.79}, {"product_id": 93, "product_code": "204e5daa-e27a-42e2-ad34-d29fcb5d84a5", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 320ml", "score": 0.78}, {"product_id": 195, "product_code": "0c817e5a-0d94-4f29-be97-bc218296a244", "name": "Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "score": 0.84}]	4	t	[{"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 1, "unit_price": 25000.0}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "qty": 3, "unit_price": 250000.0}, {"product_id": 161, "product_code": "d0ce3076-c06f-42af-ba23-221c0ee27198", "name": "Nhang mu\\u1ed7i (H\\u1ed9p 10 khoanh)", "qty": 1, "unit_price": 8000.0}, {"product_id": 201, "product_code": "e2b8c4e1-00d7-476e-9541-5da23db32d9e", "name": "V\\u1edb ch\\u00e2n nam/n\\u1eef (\\u0110\\u00f4i)", "qty": 1, "unit_price": 12000.0}]	2026-03-12 06:13:14.472206
36	HN_CG	TXN-20260218-00036	2026-02-18 06:18:14.481737+00	11	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 158, "product_code": "8526f078-cb9e-4c78-ae7a-ab1526ddda7d", "name": "N\\u01b0\\u1edbc r\\u1eeda tay kh\\u00f4 (Chai 100ml)", "score": 0.62}, {"product_id": 195, "product_code": "0c817e5a-0d94-4f29-be97-bc218296a244", "name": "Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "score": 0.88}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "score": 0.95}]	3	t	[{"product_id": 14, "product_code": "7d31d029-8f17-4074-ad5e-96f50b6b9465", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en", "qty": 1, "unit_price": 41000.0}]	2026-02-18 06:21:14.481737
37	HCM_Q1	TXN-20260317-00037	2026-03-17 14:18:14.491143+00	21	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "unisex"}	[{"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "score": 0.63}, {"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.82}]	2	t	[{"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "qty": 1, "unit_price": 298000.0}, {"product_id": 192, "product_code": "b812638a-f73d-4a60-9695-eac88da8a809", "name": "B\\u1ea5m kim s\\u1ed1 10 (C\\u00e1i)", "qty": 1, "unit_price": 18000.0}, {"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "qty": 1, "unit_price": 4750.0}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "qty": 3, "unit_price": 45000.0}]	2026-03-17 14:19:14.491143
38	HCM_Q1	TXN-20260314-00038	2026-03-14 11:11:14.499686+00	30	EDGE_HCM_Q1_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 72, "product_code": "ecb6b5c5-539c-4c4a-89a3-ad676f69c353", "name": "Th\\u00f9ng 24 lon Bia S\\u00e0i G\\u00f2n Lager 330ml", "score": 0.64}, {"product_id": 35, "product_code": "313a33b8-b547-45a7-ae0a-92edf3d8ed09", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng kh\\u00f4ng \\u0111\\u01b0\\u1eddng Vinamilk S\\u1eefa t\\u01b0\\u01a1i 100% 1 l\\u00edt", "score": 0.78}]	2	f	[{"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "qty": 1, "unit_price": 12000.0}, {"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "qty": 1, "unit_price": 17850.0}]	2026-03-14 11:18:14.499686
39	HCM_Q1	TXN-20260226-00039	2026-02-26 01:37:14.508959+00	36	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 72, "product_code": "ecb6b5c5-539c-4c4a-89a3-ad676f69c353", "name": "Th\\u00f9ng 24 lon Bia S\\u00e0i G\\u00f2n Lager 330ml", "score": 0.76}, {"product_id": 4, "product_code": "2552366a-29a2-46a3-943a-3d8fb45b3fad", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "score": 0.93}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "score": 0.69}]	3	f	[{"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "qty": 1, "unit_price": 250000.0}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "qty": 3, "unit_price": 152000.0}]	2026-02-26 01:44:14.508959
40	HCM_Q1	TXN-20260227-00040	2026-02-27 16:08:14.518193+00	\N	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "female"}	[{"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "score": 0.63}, {"product_id": 116, "product_code": "de0f18f5-f3b9-44bb-9d2d-ca990368168e", "name": "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "score": 0.89}, {"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "score": 0.86}, {"product_id": 62, "product_code": "8e6ed997-217f-4dc4-ba92-611c2a6bbd91", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n \\u00edt \\u0111\\u01b0\\u1eddng Nutimilk 100g", "score": 0.75}]	4	t	[{"product_id": 121, "product_code": "827e4a51-3225-4f53-a04f-e03b0e5b9f8d", "name": "S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "qty": 3, "unit_price": 26000.0}]	2026-02-27 16:12:14.518193
41	HCM_Q7	TXN-20260322-00041	2026-03-22 19:04:14.528944+00	30	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 19, "product_code": "aca2f004-f76e-481b-abe7-d495d4a2d9d1", "name": "Th\\u00f9ng 24 ly m\\u00ec Handy H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 67g", "score": 0.8}, {"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "score": 0.71}, {"product_id": 177, "product_code": "991f1b12-1dc2-498a-83bb-75bf860ad56b", "name": "K\\u1eb9p qu\\u1ea7n \\u00e1o (V\\u1ec9 20)", "score": 0.89}, {"product_id": 86, "product_code": "4544a866-890a-460f-93db-542521c75fa7", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt 7 Up v\\u1ecb chanh 390ml", "score": 0.87}]	4	f	[{"product_id": 192, "product_code": "b812638a-f73d-4a60-9695-eac88da8a809", "name": "B\\u1ea5m kim s\\u1ed1 10 (C\\u00e1i)", "qty": 1, "unit_price": 18000.0}, {"product_id": 150, "product_code": "8f4dc2fd-7d0d-449f-88a4-47cad03d38d2", "name": "T\\u00e3 qu\\u1ea7n Bobby (B\\u1ecbch M40)", "qty": 2, "unit_price": 210000.0}, {"product_id": 7, "product_code": "271cc8ca-e37c-4277-90dc-36f3b624ac9a", "name": "N\\u01b0\\u1edbc ch\\u1ea5m chua ng\\u1ecdt Nam Ng\\u01b0 \\u1edbt t\\u1ecfi L\\u00fd S\\u01a1n", "qty": 3, "unit_price": 28000.0}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "qty": 2, "unit_price": 18000.0}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "qty": 3, "unit_price": 32000.0}]	2026-03-22 19:14:14.528944
42	HCM_Q1	TXN-20260308-00042	2026-03-08 02:56:14.540657+00	\N	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "female"}	[{"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "score": 0.87}, {"product_id": 144, "product_code": "2869b301-5fec-407f-b472-6e72ee034c9f", "name": "N\\u01b0\\u1edbc r\\u1eeda ch\\u00e9n Sunlight (750ml)", "score": 0.81}]	2	t	[{"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "qty": 1, "unit_price": 35500.0}]	2026-03-08 03:00:14.540657
43	HN_CG	TXN-20260314-00043	2026-03-14 00:47:14.549397+00	49	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 89, "product_code": "4362ec25-fdc1-4b2a-9588-6642962e5302", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Pepsi Cola 390ml", "score": 0.79}, {"product_id": 116, "product_code": "de0f18f5-f3b9-44bb-9d2d-ca990368168e", "name": "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "score": 0.92}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "score": 0.78}]	3	t	[{"product_id": 83, "product_code": "a0500366-8dd9-44bc-ad93-6e2f9241f1bf", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng d\\u1ee9a 12.5% chai 360ml", "qty": 2, "unit_price": 38250.0}, {"product_id": 91, "product_code": "845e5e02-35a6-498e-9420-f6d30ae72b04", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Coca Cola 320ml", "qty": 2, "unit_price": 52000.0}]	2026-03-14 00:56:14.549397
44	HN_CG	TXN-20260313-00044	2026-03-13 15:26:14.557926+00	57	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "unisex"}	[{"product_id": 53, "product_code": "d5b1b057-5bcf-4629-a973-7f8e9c0bca3c", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "score": 0.96}, {"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "score": 0.61}]	2	t	[{"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "qty": 1, "unit_price": 250000.0}, {"product_id": 21, "product_code": "9ad51e21-230b-486c-abce-5487f7b09ed3", "name": "M\\u00ec H\\u1ea3o 100 t\\u00f4m chua cay g\\u00f3i 65g", "qty": 2, "unit_price": 2890.0}, {"product_id": 101, "product_code": "26b41c6b-4f50-45ec-b945-2a2e9eb74025", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh c\\u00e1 v\\u1ecb t\\u00f4m n\\u01b0\\u1edbng m\\u00f4i \\u0111\\u1ecf Orion Marine Boy 35g", "qty": 1, "unit_price": 260000.0}, {"product_id": 46, "product_code": "8636600f-9b6f-4cb4-a120-cf70c55c20e6", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "qty": 3, "unit_price": 31500.0}]	2026-03-13 15:33:14.557926
45	HN_CG	TXN-20260225-00045	2026-02-25 21:13:14.567284+00	5	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "score": 0.83}, {"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "score": 0.86}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.92}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "score": 0.77}]	4	f	[{"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "qty": 2, "unit_price": 20800.0}]	2026-02-25 21:18:14.567284
46	HCM_Q7	TXN-20260309-00046	2026-03-09 08:07:14.575394+00	\N	EDGE_HCM_Q7_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "score": 0.71}, {"product_id": 138, "product_code": "8e13d676-f7e9-477f-940b-813f80469993", "name": "S\\u1eefa t\\u1eafm Lifebuoy (Chai 850g)", "score": 0.97}]	2	f	[{"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "qty": 1, "unit_price": 425000.0}]	2026-03-09 08:10:14.575394
47	HCM_Q7	TXN-20260322-00047	2026-03-22 06:02:14.582922+00	14	EDGE_HCM_Q7_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 128, "product_code": "a010e906-1854-42a0-944b-8bcd42f82e55", "name": "Snack Khoai t\\u00e2y O'Star", "score": 0.96}, {"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "score": 0.95}, {"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "score": 0.66}]	3	f	[{"product_id": 182, "product_code": "04931d60-d635-4729-8b9e-1171306f235b", "name": "N\\u1ebfn c\\u00e2y (G\\u00f3i 5 c\\u00e2y)", "qty": 3, "unit_price": 10000.0}, {"product_id": 9, "product_code": "e4c1b87f-da03-460d-970f-cccf1b363bc7", "name": "N\\u01b0\\u1edbc m\\u1eafm Chinsu c\\u00e1 c\\u01a1m bi\\u1ec3n \\u0111\\u00f4ng 25 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 1, "unit_price": 48450.0}, {"product_id": 171, "product_code": "34b1c04a-0e91-4eaf-ae2d-f379c0324d29", "name": "Pin AAA Panasonic (V\\u1ec9 2 vi\\u00ean)", "qty": 3, "unit_price": 15000.0}, {"product_id": 82, "product_code": "7301020d-0402-4b78-969e-9e061a2a830f", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb d\\u00e2u 12% chai 360ml", "qty": 2, "unit_price": 45000.0}, {"product_id": 89, "product_code": "4362ec25-fdc1-4b2a-9588-6642962e5302", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Pepsi Cola 390ml", "qty": 1, "unit_price": 118000.0}]	2026-03-22 06:11:14.582922
48	HN_CG	TXN-20260301-00048	2026-03-01 16:26:14.590249+00	47	EDGE_HN_CG_01	{"age_group": "35_44", "gender": "female"}	[{"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.72}, {"product_id": 115, "product_code": "11086cc9-d30a-4145-acaf-8e2084c851f0", "name": "T\\u01b0\\u01a1ng \\u1edbt Chinsu (250g)", "score": 0.83}, {"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "score": 0.67}, {"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "score": 0.8}]	4	t	[{"product_id": 87, "product_code": "b336ff02-4595-449e-ada1-c89697da7fc2", "name": "Th\\u00f9ng 12 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 1.5 l\\u00edt", "qty": 3, "unit_price": 180000.0}, {"product_id": 177, "product_code": "991f1b12-1dc2-498a-83bb-75bf860ad56b", "name": "K\\u1eb9p qu\\u1ea7n \\u00e1o (V\\u1ec9 20)", "qty": 3, "unit_price": 15000.0}, {"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "qty": 1, "unit_price": 52000.0}, {"product_id": 188, "product_code": "4a5f7c93-02f6-48e0-bcb4-a1c7ae3aec53", "name": "B\\u00fat ch\\u00ec g\\u1ed7 2B", "qty": 2, "unit_price": 3000.0}]	2026-03-01 16:31:14.590249
49	HN_CG	TXN-20260221-00049	2026-02-21 01:28:14.600486+00	\N	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 95, "product_code": "0f57e196-eacf-4d9f-89a6-5fdd236a80c9", "name": "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "score": 0.6}, {"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "score": 0.73}, {"product_id": 96, "product_code": "a903b525-93ec-4602-bf74-099d44d3ea67", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola h\\u01b0\\u01a1ng vani Gery Crunch Roll g\\u00f3i 23g", "score": 0.72}]	3	f	[{"product_id": 50, "product_code": "16150fd4-8086-42ac-a03a-6bcfd77425f2", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch BFAST b\\u1ed5 sung canxi 180ml", "qty": 3, "unit_price": 27000.0}, {"product_id": 126, "product_code": "d487390c-5ffd-47eb-b891-e9feeaeb0830", "name": "Bia Tiger N\\u00e2u (Lon 330ml)", "qty": 2, "unit_price": 16000.0}, {"product_id": 82, "product_code": "7301020d-0402-4b78-969e-9e061a2a830f", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb d\\u00e2u 12% chai 360ml", "qty": 2, "unit_price": 45000.0}, {"product_id": 155, "product_code": "4dd70e94-850f-406f-a440-c4a161d99325", "name": "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "qty": 1, "unit_price": 35000.0}]	2026-02-21 01:36:14.600486
50	HCM_Q1	TXN-20260326-00050	2026-03-26 13:23:14.608082+00	27	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 86, "product_code": "4544a866-890a-460f-93db-542521c75fa7", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt 7 Up v\\u1ecb chanh 390ml", "score": 0.74}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "score": 0.6}, {"product_id": 152, "product_code": "a544d61d-edb8-4b54-ad19-8f4745d8307a", "name": "S\\u1eefa r\\u1eeda m\\u1eb7t Acnes (100g)", "score": 0.84}, {"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "score": 0.7}]	4	f	[{"product_id": 151, "product_code": "4e6b1095-a3cb-4d03-b747-0b3080e9a160", "name": "X\\u00e0 b\\u00f4ng c\\u1ee5c X-Men", "qty": 2, "unit_price": 14250.0}, {"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "qty": 2, "unit_price": 65000.0}]	2026-03-26 13:26:14.608082
51	HCM_Q1	TXN-20260222-00051	2026-02-22 08:00:14.617622+00	32	EDGE_HCM_Q1_01	{"age_group": "35_44", "gender": "unisex"}	[{"product_id": 7, "product_code": "271cc8ca-e37c-4277-90dc-36f3b624ac9a", "name": "N\\u01b0\\u1edbc ch\\u1ea5m chua ng\\u1ecdt Nam Ng\\u01b0 \\u1edbt t\\u1ecfi L\\u00fd S\\u01a1n", "score": 0.6}, {"product_id": 203, "product_code": "cd3322e6-fa79-4ff1-9ec1-017716f5f8af", "name": "C\\u00e1p s\\u1ea1c Android/iPhone", "score": 0.7}]	2	f	[{"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 3, "unit_price": 9600.0}]	2026-02-22 08:08:14.617622
52	HN_CG	TXN-20260307-00052	2026-03-07 23:06:14.624829+00	49	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "score": 0.79}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.82}, {"product_id": 96, "product_code": "a903b525-93ec-4602-bf74-099d44d3ea67", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola h\\u01b0\\u01a1ng vani Gery Crunch Roll g\\u00f3i 23g", "score": 0.92}]	3	f	[{"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "qty": 3, "unit_price": 28500.0}, {"product_id": 18, "product_code": "fc0359c0-800a-40c9-8e49-660ab593f7e3", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "qty": 2, "unit_price": 105300.0}, {"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "qty": 2, "unit_price": 65000.0}]	2026-03-07 23:09:14.624829
53	HCM_Q1	TXN-20260328-00053	2026-03-28 08:16:14.633055+00	18	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "score": 0.89}, {"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "score": 0.81}, {"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.93}, {"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "score": 0.91}]	4	f	[{"product_id": 108, "product_code": "ba0eeecc-e4ce-4bd7-b4f0-91117d028872", "name": "Th\\u00f9ng M\\u00ec 3 Mi\\u1ec1n (30 g\\u00f3i)", "qty": 3, "unit_price": 85000.0}, {"product_id": 163, "product_code": "5acdac1a-898e-4a9f-8acd-f8590ce29d7b", "name": "C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)", "qty": 3, "unit_price": 12000.0}, {"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "qty": 1, "unit_price": 17850.0}]	2026-03-28 08:21:14.633055
54	HCM_Q1	TXN-20260310-00054	2026-03-10 12:24:14.640057+00	19	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 204, "product_code": "e03863a3-5056-43ed-af9e-77bdb148f682", "name": "C\\u1ee7 s\\u1ea1c USB 2 c\\u1ed5ng", "score": 0.83}, {"product_id": 144, "product_code": "2869b301-5fec-407f-b472-6e72ee034c9f", "name": "N\\u01b0\\u1edbc r\\u1eeda ch\\u00e9n Sunlight (750ml)", "score": 0.92}]	2	t	[{"product_id": 200, "product_code": "44e0b85c-6165-439b-84b4-6f85374c19e1", "name": "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "qty": 1, "unit_price": 70000.0}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "qty": 1, "unit_price": 18000.0}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "qty": 3, "unit_price": 152000.0}]	2026-03-10 12:33:14.640057
55	HCM_Q1	TXN-20260226-00055	2026-02-26 07:24:14.649728+00	20	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.93}, {"product_id": 33, "product_code": "f5833d36-7b7f-4702-937f-8d1286c31a38", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "score": 0.65}]	2	f	[{"product_id": 36, "product_code": "6ea649b0-f9e4-44cb-9fb9-768d1889cdf6", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "qty": 3, "unit_price": 425000.0}, {"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "qty": 2, "unit_price": 5000.0}, {"product_id": 153, "product_code": "0fae3be1-0f57-4a82-aba9-d13e180c1943", "name": "Dao c\\u1ea1o r\\u00e2u Gillette (C\\u00e2y)", "qty": 1, "unit_price": 12000.0}]	2026-02-26 07:28:14.649728
56	HCM_Q7	TXN-20260325-00056	2026-03-25 15:39:14.657874+00	50	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 12, "product_code": "32c195be-0444-4c26-8b09-761cb0b32136", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi thanh d\\u1ecbu", "score": 0.85}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "score": 0.89}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.9}]	3	f	[{"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "qty": 3, "unit_price": 8500.0}, {"product_id": 111, "product_code": "39db55d0-6784-4457-900f-d85d7b17e783", "name": "H\\u1ea1t n\\u00eam Knorr (400g)", "qty": 3, "unit_price": 30400.0}, {"product_id": 11, "product_code": "c657b334-1d73-44af-b7cc-74d5d5bd1efa", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi \\u0111\\u1eadm \\u0111\\u1eb7c", "qty": 3, "unit_price": 35000.0}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "qty": 1, "unit_price": 298000.0}]	2026-03-25 15:49:14.657874
57	HCM_Q7	TXN-20260321-00057	2026-03-21 00:46:14.666418+00	55	EDGE_HCM_Q7_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "score": 0.89}, {"product_id": 149, "product_code": "37ee0bd9-0b99-403e-96ab-f314af9c2e8e", "name": "B\\u0103ng v\\u1ec7 sinh Diana (G\\u00f3i 8)", "score": 0.8}]	2	f	[{"product_id": 149, "product_code": "37ee0bd9-0b99-403e-96ab-f314af9c2e8e", "name": "B\\u0103ng v\\u1ec7 sinh Diana (G\\u00f3i 8)", "qty": 3, "unit_price": 16200.0}, {"product_id": 90, "product_code": "61c35ff1-5a92-4568-9870-e345bc73a24c", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml", "qty": 3, "unit_price": 9000.0}, {"product_id": 91, "product_code": "845e5e02-35a6-498e-9420-f6d30ae72b04", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Coca Cola 320ml", "qty": 1, "unit_price": 52000.0}]	2026-03-21 00:50:14.666418
58	HN_CG	TXN-20260320-00058	2026-03-20 02:48:14.67696+00	\N	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "score": 0.89}, {"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "score": 0.72}]	2	t	[{"product_id": 182, "product_code": "04931d60-d635-4729-8b9e-1171306f235b", "name": "N\\u1ebfn c\\u00e2y (G\\u00f3i 5 c\\u00e2y)", "qty": 1, "unit_price": 10000.0}, {"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 1, "unit_price": 52000.0}, {"product_id": 94, "product_code": "d1b9db4c-7740-417c-9d54-b450251614c9", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml", "qty": 2, "unit_price": 10000.0}, {"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "qty": 2, "unit_price": 12000.0}, {"product_id": 151, "product_code": "4e6b1095-a3cb-4d03-b747-0b3080e9a160", "name": "X\\u00e0 b\\u00f4ng c\\u1ee5c X-Men", "qty": 2, "unit_price": 14250.0}]	2026-03-20 02:56:14.67696
59	HCM_Q1	TXN-20260311-00059	2026-03-11 19:38:14.687475+00	25	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "score": 0.96}, {"product_id": 18, "product_code": "fc0359c0-800a-40c9-8e49-660ab593f7e3", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "score": 0.74}, {"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "score": 0.6}]	3	t	[{"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "qty": 2, "unit_price": 18000.0}, {"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "qty": 1, "unit_price": 65000.0}, {"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "qty": 3, "unit_price": 5000.0}]	2026-03-11 19:46:14.687475
60	HCM_Q1	TXN-20260319-00060	2026-03-19 07:20:14.696642+00	26	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "score": 0.82}, {"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "score": 0.7}, {"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "score": 0.9}]	3	f	[{"product_id": 27, "product_code": "b048d361-49e5-4b05-8560-1b82458ef15b", "name": "B\\u00fan c\\u00e1 cay H\\u1eb1ng Nga g\\u00f3i 70g", "qty": 3, "unit_price": 10000.0}, {"product_id": 190, "product_code": "91a2bcb3-d18b-47dc-ab24-5af040967bf2", "name": "Th\\u01b0\\u1edbc k\\u1ebb 20cm", "qty": 2, "unit_price": 5000.0}, {"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 1, "unit_price": 355000.0}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "qty": 1, "unit_price": 95200.0}, {"product_id": 94, "product_code": "d1b9db4c-7740-417c-9d54-b450251614c9", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml", "qty": 2, "unit_price": 10000.0}]	2026-03-19 07:27:14.696642
61	HCM_Q7	TXN-20260315-00061	2026-03-15 02:00:14.70518+00	30	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "score": 0.88}, {"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "score": 0.92}]	2	f	[{"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 1, "unit_price": 345000.0}]	2026-03-15 02:08:14.70518
62	HCM_Q1	TXN-20260226-00062	2026-02-26 01:48:14.714027+00	7	EDGE_HCM_Q1_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 128, "product_code": "a010e906-1854-42a0-944b-8bcd42f82e55", "name": "Snack Khoai t\\u00e2y O'Star", "score": 0.81}, {"product_id": 126, "product_code": "d487390c-5ffd-47eb-b891-e9feeaeb0830", "name": "Bia Tiger N\\u00e2u (Lon 330ml)", "score": 0.91}, {"product_id": 130, "product_code": "260fa104-9d28-45a7-bb5e-06b373367221", "name": "B\\u00e1nh quy Cosy (G\\u00f3i 200g)", "score": 0.81}, {"product_id": 67, "product_code": "a67c2aa4-d081-41f2-a440-30d00cd60c5b", "name": "L\\u1ed1c 2 h\\u0169 s\\u01b0\\u0303a chua n\\u00ea\\u0301p c\\u00e2\\u0309m Sa\\u0300i Go\\u0300n Milk 120g", "score": 0.61}]	4	t	[{"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "qty": 2, "unit_price": 10000.0}]	2026-02-26 01:49:14.714027
63	HCM_Q7	TXN-20260311-00063	2026-03-11 19:21:14.723443+00	3	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 100, "product_code": "46b1b7b5-3a08-4c49-96c5-44e9cf02c72d", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh quy socola Orion Miz 54g", "score": 0.82}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "score": 0.79}, {"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "score": 0.81}, {"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "score": 0.8}]	4	t	[{"product_id": 143, "product_code": "a3a7acbd-4cf2-4f56-9930-63c15fc00ecc", "name": "B\\u00e0n ch\\u1ea3i \\u0111\\u00e1nh r\\u0103ng Colgate", "qty": 2, "unit_price": 14250.0}, {"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "qty": 2, "unit_price": 68000.0}]	2026-03-11 19:29:14.723443
64	HCM_Q7	TXN-20260328-00064	2026-03-28 16:58:14.73356+00	25	EDGE_HCM_Q7_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 88, "product_code": "e26b7e68-b6d3-48b3-afc4-352c85e6962a", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb 390ml", "score": 0.73}, {"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "score": 0.74}, {"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.73}, {"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "score": 0.85}]	4	f	[{"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "qty": 1, "unit_price": 4750.0}, {"product_id": 91, "product_code": "845e5e02-35a6-498e-9420-f6d30ae72b04", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Coca Cola 320ml", "qty": 1, "unit_price": 52000.0}, {"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "qty": 2, "unit_price": 30000.0}, {"product_id": 73, "product_code": "c57b5193-7c6a-4e72-be5f-bf08951cd0ec", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "qty": 2, "unit_price": 375250.0}, {"product_id": 83, "product_code": "a0500366-8dd9-44bc-ad93-6e2f9241f1bf", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng d\\u1ee9a 12.5% chai 360ml", "qty": 3, "unit_price": 38250.0}]	2026-03-28 17:02:14.73356
65	HCM_Q1	TXN-20260311-00065	2026-03-11 16:03:14.743752+00	11	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "score": 0.86}, {"product_id": 108, "product_code": "ba0eeecc-e4ce-4bd7-b4f0-91117d028872", "name": "Th\\u00f9ng M\\u00ec 3 Mi\\u1ec1n (30 g\\u00f3i)", "score": 0.82}, {"product_id": 69, "product_code": "c6db64ee-92ea-4113-8297-a2e94c4f6be6", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa dinh d\\u01b0\\u1ee1ng Gotz 55g", "score": 0.97}, {"product_id": 6, "product_code": "4261ad1a-adce-4554-9710-a9edbdc16f52", "name": "N\\u01b0\\u1edbc ch\\u1ea5m Nam Ng\\u01b0 \\u0110\\u1ec7 Nh\\u1ecb", "score": 0.74}]	4	f	[{"product_id": 138, "product_code": "8e13d676-f7e9-477f-940b-813f80469993", "name": "S\\u1eefa t\\u1eafm Lifebuoy (Chai 850g)", "qty": 3, "unit_price": 142500.0}]	2026-03-11 16:10:14.743752
66	HN_CG	TXN-20260308-00066	2026-03-08 04:25:14.755177+00	33	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "score": 0.71}, {"product_id": 74, "product_code": "bfc156f1-4268-4720-ba38-b2f6882dc6bd", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 250ml", "score": 0.82}, {"product_id": 68, "product_code": "5d22b162-c9c6-4540-ab8a-ff709f7148e3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa h\\u01b0\\u01a1ng vani Hoff 55g", "score": 0.91}, {"product_id": 13, "product_code": "2bcfabb7-eedf-4da1-ad8c-f464bb3e5ee6", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Tam Th\\u00e1i T\\u1eed Nh\\u1ea5t Ca s\\u00e1nh \\u0111\\u1eadm", "score": 0.84}]	4	f	[{"product_id": 43, "product_code": "d4bfaf6c-3b76-40b5-b6d1-ff43f5cd2555", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng v\\u1ecb t\\u1ef1 nhi\\u00ean TH true MILK Hilo 180ml", "qty": 2, "unit_price": 399500.0}, {"product_id": 158, "product_code": "8526f078-cb9e-4c78-ae7a-ab1526ddda7d", "name": "N\\u01b0\\u1edbc r\\u1eeda tay kh\\u00f4 (Chai 100ml)", "qty": 3, "unit_price": 30000.0}, {"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "qty": 1, "unit_price": 349000.0}]	2026-03-08 04:27:14.755177
67	HN_CG	TXN-20260312-00067	2026-03-12 00:47:14.765715+00	23	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 81, "product_code": "1485f5ea-a1a9-4383-98c4-338a415c5e3d", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb \\u0111\\u00e0o 12% chai 360ml", "score": 0.7}, {"product_id": 52, "product_code": "ea03fd89-98bb-42ca-900a-59f1006717b8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "score": 0.8}, {"product_id": 107, "product_code": "950bc1a0-a654-4c1f-937a-91b5753c75c0", "name": "M\\u00ec H\\u1ea3o H\\u1ea3o T\\u00f4m Chua Cay", "score": 0.86}, {"product_id": 103, "product_code": "215bb35c-37c7-451d-8a5e-19d774e2ec28", "name": "B\\u00e1nh quy socola chip nh\\u00e2n socola Parle Platina Hide & Seek g\\u00f3i 112.5g", "score": 0.81}]	4	t	[{"product_id": 167, "product_code": "1922c25c-8820-4cc8-9b62-4ffe1c5b9704", "name": "C\\u00e2y lau nh\\u00e0 360 \\u0111\\u1ed9 (B\\u1ed9)", "qty": 2, "unit_price": 180000.0}]	2026-03-12 00:48:14.765715
68	HN_CG	TXN-20260219-00068	2026-02-19 15:59:14.774853+00	41	EDGE_HN_CG_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "score": 0.72}, {"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "score": 0.92}, {"product_id": 112, "product_code": "26a9aea3-5f05-45b5-81af-801b4e2e9d24", "name": "B\\u1ed9t ng\\u1ecdt Ajinomoto (454g)", "score": 0.62}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "score": 0.68}]	4	t	[{"product_id": 158, "product_code": "8526f078-cb9e-4c78-ae7a-ab1526ddda7d", "name": "N\\u01b0\\u1edbc r\\u1eeda tay kh\\u00f4 (Chai 100ml)", "qty": 1, "unit_price": 30000.0}, {"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "qty": 2, "unit_price": 30000.0}, {"product_id": 112, "product_code": "26a9aea3-5f05-45b5-81af-801b4e2e9d24", "name": "B\\u1ed9t ng\\u1ecdt Ajinomoto (454g)", "qty": 2, "unit_price": 32000.0}, {"product_id": 145, "product_code": "3f023ad8-02a4-4e95-8ec6-553c622e7d9d", "name": "N\\u01b0\\u1edbc lau s\\u00e0n Gift (1 L\\u00edt)", "qty": 1, "unit_price": 22000.0}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 1, "unit_price": 6800.0}]	2026-02-19 16:06:14.774853
69	HN_CG	TXN-20260316-00069	2026-03-16 08:05:14.783062+00	8	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "score": 0.66}, {"product_id": 10, "product_code": "63a338bb-de9f-45cb-b283-d0abab06015d", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Nh\\u1ecb Ca Tam Th\\u00e1i T\\u1eed chai", "score": 0.65}, {"product_id": 52, "product_code": "ea03fd89-98bb-42ca-900a-59f1006717b8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "score": 0.7}]	3	f	[{"product_id": 50, "product_code": "16150fd4-8086-42ac-a03a-6bcfd77425f2", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch BFAST b\\u1ed5 sung canxi 180ml", "qty": 2, "unit_price": 27000.0}, {"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 3, "unit_price": 37050.0}]	2026-03-16 08:10:14.783062
70	HCM_Q1	TXN-20260221-00070	2026-02-21 07:41:14.792585+00	\N	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 94, "product_code": "d1b9db4c-7740-417c-9d54-b450251614c9", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml", "score": 0.94}, {"product_id": 172, "product_code": "17f75c8c-ac61-4e32-8355-90e37f46cc3c", "name": "M\\u00e0ng b\\u1ecdc th\\u1ef1c ph\\u1ea9m (Cu\\u1ed9n)", "score": 0.75}, {"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "score": 0.92}]	3	f	[{"product_id": 81, "product_code": "1485f5ea-a1a9-4383-98c4-338a415c5e3d", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb \\u0111\\u00e0o 12% chai 360ml", "qty": 1, "unit_price": 42750.0}]	2026-02-21 07:44:14.792585
71	HCM_Q1	TXN-20260306-00071	2026-03-06 17:42:14.80284+00	50	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "score": 0.77}, {"product_id": 71, "product_code": "bbd97816-ba62-4a9a-8384-7d7bff031ab1", "name": "Th\\u00f9ng 24 lon Bia Heineken Silver 250ml", "score": 0.7}]	2	t	[{"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "qty": 1, "unit_price": 142800.0}, {"product_id": 150, "product_code": "8f4dc2fd-7d0d-449f-88a4-47cad03d38d2", "name": "T\\u00e3 qu\\u1ea7n Bobby (B\\u1ecbch M40)", "qty": 2, "unit_price": 210000.0}, {"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "qty": 1, "unit_price": 5000.0}]	2026-03-06 17:52:14.80284
72	HCM_Q1	TXN-20260322-00072	2026-03-22 06:08:14.810381+00	31	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "female"}	[{"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "score": 0.61}, {"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "score": 0.88}]	2	f	[{"product_id": 72, "product_code": "ecb6b5c5-539c-4c4a-89a3-ad676f69c353", "name": "Th\\u00f9ng 24 lon Bia S\\u00e0i G\\u00f2n Lager 330ml", "qty": 3, "unit_price": 206400.0}, {"product_id": 201, "product_code": "e2b8c4e1-00d7-476e-9541-5da23db32d9e", "name": "V\\u1edb ch\\u00e2n nam/n\\u1eef (\\u0110\\u00f4i)", "qty": 2, "unit_price": 12000.0}]	2026-03-22 06:09:14.810381
73	HN_CG	TXN-20260316-00073	2026-03-16 03:12:14.819564+00	\N	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 66, "product_code": "59989980-7fbb-4c6a-bf32-5d2cb1fa21c5", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Happy Star Vinamilk 100g", "score": 0.96}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.89}, {"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "score": 0.71}]	3	f	[{"product_id": 137, "product_code": "f0cac878-618a-41d5-9319-8b85e8c0fc27", "name": "D\\u1ea7u g\\u1ed9i Clear Men (Chai 630g)", "qty": 1, "unit_price": 135000.0}]	2026-03-16 03:15:14.819564
74	HCM_Q7	TXN-20260320-00074	2026-03-20 19:15:14.828745+00	60	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 141, "product_code": "0b4a4b09-46ec-4a6b-bc41-df4393645a3e", "name": "N\\u01b0\\u1edbc x\\u1ea3 v\\u1ea3i Comfort (T\\u00fai 1.6L)", "score": 0.86}, {"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "score": 0.89}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.84}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "score": 0.67}]	4	t	[{"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "qty": 3, "unit_price": 5000.0}, {"product_id": 109, "product_code": "013d09af-48c5-4c50-9709-5b6183c5e8cc", "name": "D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An", "qty": 1, "unit_price": 48000.0}, {"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "qty": 2, "unit_price": 11500.0}]	2026-03-20 19:23:14.828745
75	HCM_Q7	TXN-20260220-00075	2026-02-20 20:03:14.83778+00	16	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 152, "product_code": "a544d61d-edb8-4b54-ad19-8f4745d8307a", "name": "S\\u1eefa r\\u1eeda m\\u1eb7t Acnes (100g)", "score": 0.68}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.76}, {"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "score": 0.67}, {"product_id": 73, "product_code": "c57b5193-7c6a-4e72-be5f-bf08951cd0ec", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "score": 0.93}]	4	t	[{"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "qty": 2, "unit_price": 15000.0}, {"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "qty": 2, "unit_price": 30000.0}, {"product_id": 167, "product_code": "1922c25c-8820-4cc8-9b62-4ffe1c5b9704", "name": "C\\u00e2y lau nh\\u00e0 360 \\u0111\\u1ed9 (B\\u1ed9)", "qty": 2, "unit_price": 180000.0}, {"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "qty": 3, "unit_price": 25000.0}, {"product_id": 34, "product_code": "15458477-33d0-4386-bf74-bc53f8887361", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 1, "unit_price": 337500.0}]	2026-02-20 20:13:14.83778
76	HN_CG	TXN-20260328-00076	2026-03-28 04:52:14.84652+00	\N	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "score": 0.61}, {"product_id": 146, "product_code": "fd9f259d-1ea9-4994-ae7d-d00f930fcde4", "name": "N\\u01b0\\u1edbc t\\u1ea9y b\\u1ed3n c\\u1ea7u Vim (900ml)", "score": 0.8}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.89}]	3	t	[{"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "qty": 2, "unit_price": 298000.0}, {"product_id": 68, "product_code": "5d22b162-c9c6-4540-ab8a-ff709f7148e3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa h\\u01b0\\u01a1ng vani Hoff 55g", "qty": 3, "unit_price": 65000.0}, {"product_id": 180, "product_code": "8f382477-a9b4-44d6-bf2a-59fae61d9166", "name": "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "qty": 2, "unit_price": 19000.0}, {"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 1, "unit_price": 355000.0}]	2026-03-28 05:00:14.84652
77	HCM_Q7	TXN-20260312-00077	2026-03-12 17:48:14.85704+00	28	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "score": 0.97}, {"product_id": 75, "product_code": "adaf187e-c86b-4ead-a4fc-fa93d98d1735", "name": "Th\\u00f9ng 24 lon Bia Blanc 1664 330ml", "score": 0.69}]	2	t	[{"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "qty": 1, "unit_price": 65000.0}, {"product_id": 56, "product_code": "c11379c8-f11b-4bc0-bc6b-32483cb53628", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p 170ml", "qty": 2, "unit_price": 35150.0}]	2026-03-12 17:56:14.85704
78	HCM_Q1	TXN-20260317-00078	2026-03-17 19:11:14.86732+00	56	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "female"}	[{"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.62}, {"product_id": 143, "product_code": "a3a7acbd-4cf2-4f56-9930-63c15fc00ecc", "name": "B\\u00e0n ch\\u1ea3i \\u0111\\u00e1nh r\\u0103ng Colgate", "score": 0.73}]	2	f	[{"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "qty": 3, "unit_price": 40000.0}, {"product_id": 102, "product_code": "81606b2f-15e4-4ffc-a73b-fe9afc07043e", "name": "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g", "qty": 2, "unit_price": 21250.0}, {"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "qty": 3, "unit_price": 33250.0}]	2026-03-17 19:15:14.86732
79	HN_CG	TXN-20260323-00079	2026-03-23 00:35:14.876467+00	33	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 120, "product_code": "95bd5a46-0188-4553-927a-64cb57498ebc", "name": "L\\u1ed1c 4 s\\u1eefa chua Vinamilk", "score": 0.72}, {"product_id": 34, "product_code": "15458477-33d0-4386-bf74-bc53f8887361", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "score": 0.8}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "score": 0.65}]	3	f	[{"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "qty": 3, "unit_price": 65000.0}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 1, "unit_price": 9600.0}, {"product_id": 102, "product_code": "81606b2f-15e4-4ffc-a73b-fe9afc07043e", "name": "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g", "qty": 2, "unit_price": 21250.0}, {"product_id": 172, "product_code": "17f75c8c-ac61-4e32-8355-90e37f46cc3c", "name": "M\\u00e0ng b\\u1ecdc th\\u1ef1c ph\\u1ea9m (Cu\\u1ed9n)", "qty": 1, "unit_price": 19000.0}, {"product_id": 95, "product_code": "0f57e196-eacf-4d9f-89a6-5fdd236a80c9", "name": "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "qty": 3, "unit_price": 22950.0}]	2026-03-23 00:37:14.876467
80	HCM_Q7	TXN-20260315-00080	2026-03-15 01:18:14.887002+00	\N	EDGE_HCM_Q7_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "score": 0.92}, {"product_id": 39, "product_code": "0e3740f8-9d6f-4f7b-b1bb-3b719c18c93b", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "score": 0.85}, {"product_id": 143, "product_code": "a3a7acbd-4cf2-4f56-9930-63c15fc00ecc", "name": "B\\u00e0n ch\\u1ea3i \\u0111\\u00e1nh r\\u0103ng Colgate", "score": 0.9}]	3	f	[{"product_id": 68, "product_code": "5d22b162-c9c6-4540-ab8a-ff709f7148e3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa h\\u01b0\\u01a1ng vani Hoff 55g", "qty": 2, "unit_price": 65000.0}, {"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 1, "unit_price": 25000.0}, {"product_id": 195, "product_code": "0c817e5a-0d94-4f29-be97-bc218296a244", "name": "Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "qty": 2, "unit_price": 35000.0}]	2026-03-15 01:19:14.887002
81	HCM_Q7	TXN-20260308-00081	2026-03-08 19:01:14.897253+00	30	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.64}, {"product_id": 90, "product_code": "61c35ff1-5a92-4568-9870-e345bc73a24c", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml", "score": 0.93}]	2	f	[{"product_id": 30, "product_code": "f91639d0-6dfc-4083-a260-a2ad3c65eb41", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf g\\u00e0 \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 65g", "qty": 2, "unit_price": 43000.0}, {"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "qty": 2, "unit_price": 28500.0}, {"product_id": 11, "product_code": "c657b334-1d73-44af-b7cc-74d5d5bd1efa", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi \\u0111\\u1eadm \\u0111\\u1eb7c", "qty": 2, "unit_price": 35000.0}, {"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "qty": 1, "unit_price": 5000.0}]	2026-03-08 19:04:14.897253
82	HN_CG	TXN-20260316-00082	2026-03-16 01:50:14.907475+00	1	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 101, "product_code": "26b41c6b-4f50-45ec-b945-2a2e9eb74025", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh c\\u00e1 v\\u1ecb t\\u00f4m n\\u01b0\\u1edbng m\\u00f4i \\u0111\\u1ecf Orion Marine Boy 35g", "score": 0.82}, {"product_id": 96, "product_code": "a903b525-93ec-4602-bf74-099d44d3ea67", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola h\\u01b0\\u01a1ng vani Gery Crunch Roll g\\u00f3i 23g", "score": 0.96}]	2	f	[{"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "qty": 1, "unit_price": 30000.0}, {"product_id": 147, "product_code": "3518ef51-5bc7-4266-bbc2-6ce2d3acbc53", "name": "Gi\\u1ea5y v\\u1ec7 sinh E'mos (L\\u1ed1c 10)", "qty": 2, "unit_price": 48000.0}, {"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "qty": 1, "unit_price": 33500.0}, {"product_id": 107, "product_code": "950bc1a0-a654-4c1f-937a-91b5753c75c0", "name": "M\\u00ec H\\u1ea3o H\\u1ea3o T\\u00f4m Chua Cay", "qty": 2, "unit_price": 3600.0}, {"product_id": 20, "product_code": "d9f8c780-f6e0-408f-9147-1072585bee2d", "name": "M\\u00ec Kokomi 90 t\\u00f4m chua cay g\\u00f3i 90g", "qty": 3, "unit_price": 3600.0}]	2026-03-16 01:56:14.907475
83	HN_CG	TXN-20260220-00083	2026-02-20 03:14:14.918028+00	18	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 73, "product_code": "c57b5193-7c6a-4e72-be5f-bf08951cd0ec", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "score": 0.88}, {"product_id": 83, "product_code": "a0500366-8dd9-44bc-ad93-6e2f9241f1bf", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng d\\u1ee9a 12.5% chai 360ml", "score": 0.81}, {"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "score": 0.83}, {"product_id": 15, "product_code": "cebc7811-c35c-4a9d-8b37-854d28b07b22", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g", "score": 0.64}]	4	f	[{"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "qty": 3, "unit_price": 68000.0}, {"product_id": 2, "product_code": "76e07498-8366-4687-a82e-2a47ecd1e994", "name": "D\\u1ea7u th\\u1ef1c v\\u1eadt tinh luy\\u1ec7n C\\u00e1i L\\u00e2n", "qty": 3, "unit_price": 39100.0}, {"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "qty": 3, "unit_price": 142800.0}, {"product_id": 12, "product_code": "32c195be-0444-4c26-8b09-761cb0b32136", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi thanh d\\u1ecbu", "qty": 1, "unit_price": 22000.0}, {"product_id": 168, "product_code": "131a23d6-1d20-4d98-b9dd-2d0eb19e0b54", "name": "B\\u00f3ng \\u0111\\u00e8n LED \\u0110i\\u1ec7n Quang 20W", "qty": 1, "unit_price": 45000.0}]	2026-02-20 03:19:14.918028
84	HCM_Q1	TXN-20260306-00084	2026-03-06 07:56:14.931767+00	\N	EDGE_HCM_Q1_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 111, "product_code": "39db55d0-6784-4457-900f-d85d7b17e783", "name": "H\\u1ea1t n\\u00eam Knorr (400g)", "score": 0.94}, {"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "score": 0.83}, {"product_id": 80, "product_code": "77e0bf6d-eb78-4ab7-8a73-d61458d018c6", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb vi\\u1ec7t qu\\u1ea5t 12% chai 360ml", "score": 0.74}]	3	t	[{"product_id": 100, "product_code": "46b1b7b5-3a08-4c49-96c5-44e9cf02c72d", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh quy socola Orion Miz 54g", "qty": 3, "unit_price": 246500.0}, {"product_id": 200, "product_code": "44e0b85c-6165-439b-84b4-6f85374c19e1", "name": "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "qty": 1, "unit_price": 70000.0}]	2026-03-06 07:58:14.931767
85	HCM_Q7	TXN-20260219-00085	2026-02-19 04:29:14.954065+00	28	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 58, "product_code": "54ee9149-caee-4c90-9f0d-8a89945ffa5f", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.66}, {"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "score": 0.79}, {"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "score": 0.84}, {"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "score": 0.8}]	4	f	[{"product_id": 158, "product_code": "8526f078-cb9e-4c78-ae7a-ab1526ddda7d", "name": "N\\u01b0\\u1edbc r\\u1eeda tay kh\\u00f4 (Chai 100ml)", "qty": 1, "unit_price": 30000.0}, {"product_id": 48, "product_code": "daa15e61-ad90-41f8-aecf-9db0eefdf004", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch v\\u1ecb socola Ovaltine b\\u1ed5 sung canxi 180ml", "qty": 3, "unit_price": 27200.0}, {"product_id": 112, "product_code": "26a9aea3-5f05-45b5-81af-801b4e2e9d24", "name": "B\\u1ed9t ng\\u1ecdt Ajinomoto (454g)", "qty": 2, "unit_price": 32000.0}]	2026-02-19 04:34:14.954065
86	HCM_Q7	TXN-20260312-00086	2026-03-12 23:34:14.970242+00	\N	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 109, "product_code": "013d09af-48c5-4c50-9709-5b6183c5e8cc", "name": "D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An", "score": 0.85}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "score": 0.82}, {"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.7}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "score": 0.7}]	4	f	[{"product_id": 64, "product_code": "0f123724-4435-43b5-a850-de579646313d", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua nha \\u0111am Nutimilk 100g", "qty": 3, "unit_price": 27900.0}, {"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "qty": 1, "unit_price": 7000.0}, {"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "qty": 1, "unit_price": 42000.0}]	2026-03-12 23:36:14.970242
87	HCM_Q1	TXN-20260301-00087	2026-03-01 20:06:14.982209+00	46	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "score": 0.63}, {"product_id": 48, "product_code": "daa15e61-ad90-41f8-aecf-9db0eefdf004", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch v\\u1ecb socola Ovaltine b\\u1ed5 sung canxi 180ml", "score": 0.97}]	2	f	[{"product_id": 81, "product_code": "1485f5ea-a1a9-4383-98c4-338a415c5e3d", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb \\u0111\\u00e0o 12% chai 360ml", "qty": 3, "unit_price": 42750.0}, {"product_id": 151, "product_code": "4e6b1095-a3cb-4d03-b747-0b3080e9a160", "name": "X\\u00e0 b\\u00f4ng c\\u1ee5c X-Men", "qty": 2, "unit_price": 14250.0}, {"product_id": 186, "product_code": "da5a3390-cf73-4a9f-bffc-f6e02a0905b2", "name": "B\\u00fat bi Thi\\u00ean Long (C\\u00e2y)", "qty": 2, "unit_price": 3200.0}]	2026-03-01 20:11:14.982209
88	HCM_Q1	TXN-20260220-00088	2026-02-20 18:04:14.996615+00	31	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "female"}	[{"product_id": 173, "product_code": "78a22c2f-8513-49ba-95df-227bbb48543e", "name": "Gi\\u1ea5y b\\u1ea1c n\\u01b0\\u1edbng (Cu\\u1ed9n)", "score": 0.65}, {"product_id": 102, "product_code": "81606b2f-15e4-4ffc-a73b-fe9afc07043e", "name": "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g", "score": 0.61}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.64}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "score": 0.61}]	4	f	[{"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "qty": 2, "unit_price": 40000.0}, {"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "qty": 3, "unit_price": 39000.0}, {"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "qty": 3, "unit_price": 68000.0}, {"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "qty": 2, "unit_price": 3800.0}]	2026-02-20 18:08:14.996615
89	HCM_Q1	TXN-20260322-00089	2026-03-22 02:05:15.008764+00	\N	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 121, "product_code": "827e4a51-3225-4f53-a04f-e03b0e5b9f8d", "name": "S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "score": 0.82}, {"product_id": 6, "product_code": "4261ad1a-adce-4554-9710-a9edbdc16f52", "name": "N\\u01b0\\u1edbc ch\\u1ea5m Nam Ng\\u01b0 \\u0110\\u1ec7 Nh\\u1ecb", "score": 0.68}, {"product_id": 116, "product_code": "de0f18f5-f3b9-44bb-9d2d-ca990368168e", "name": "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "score": 0.82}]	3	f	[{"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "qty": 1, "unit_price": 34000.0}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "qty": 1, "unit_price": 250000.0}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 1, "unit_price": 9600.0}, {"product_id": 198, "product_code": "2c790f44-7ee9-4c1d-9170-0f67eaf7e736", "name": "M\\u0169 b\\u1ea3o hi\\u1ec3m n\\u1eeda \\u0111\\u1ea7u", "qty": 1, "unit_price": 68000.0}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "qty": 3, "unit_price": 32000.0}]	2026-03-22 02:12:15.008764
90	HCM_Q7	TXN-20260216-00090	2026-02-16 02:17:15.023329+00	26	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 142, "product_code": "11c60194-88d2-4816-997a-5553a8cb6196", "name": "Kem \\u0111\\u00e1nh r\\u0103ng P/S (180g)", "score": 0.94}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "score": 0.76}, {"product_id": 69, "product_code": "c6db64ee-92ea-4113-8297-a2e94c4f6be6", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa dinh d\\u01b0\\u1ee1ng Gotz 55g", "score": 0.78}]	3	t	[{"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "qty": 3, "unit_price": 22500.0}, {"product_id": 152, "product_code": "a544d61d-edb8-4b54-ad19-8f4745d8307a", "name": "S\\u1eefa r\\u1eeda m\\u1eb7t Acnes (100g)", "qty": 1, "unit_price": 52250.0}, {"product_id": 186, "product_code": "da5a3390-cf73-4a9f-bffc-f6e02a0905b2", "name": "B\\u00fat bi Thi\\u00ean Long (C\\u00e2y)", "qty": 3, "unit_price": 3200.0}, {"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 1, "unit_price": 25000.0}]	2026-02-16 02:25:15.023329
91	HCM_Q7	TXN-20260221-00091	2026-02-21 20:12:15.037506+00	29	EDGE_HCM_Q7_01	{"age_group": "45_54", "gender": "unisex"}	[{"product_id": 76, "product_code": "aa017cb5-b496-42a5-9417-beec7b243112", "name": "Th\\u00f9ng 12 lon bia Hoegaarden Peach v\\u1ecb \\u0111\\u00e0o 500ml", "score": 0.87}, {"product_id": 186, "product_code": "da5a3390-cf73-4a9f-bffc-f6e02a0905b2", "name": "B\\u00fat bi Thi\\u00ean Long (C\\u00e2y)", "score": 0.96}]	2	f	[{"product_id": 130, "product_code": "260fa104-9d28-45a7-bb5e-06b373367221", "name": "B\\u00e1nh quy Cosy (G\\u00f3i 200g)", "qty": 3, "unit_price": 13500.0}, {"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "qty": 3, "unit_price": 10000.0}]	2026-02-21 20:18:15.037506
92	HN_CG	TXN-20260221-00092	2026-02-21 02:28:15.050751+00	9	EDGE_HN_CG_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 143, "product_code": "a3a7acbd-4cf2-4f56-9930-63c15fc00ecc", "name": "B\\u00e0n ch\\u1ea3i \\u0111\\u00e1nh r\\u0103ng Colgate", "score": 0.98}, {"product_id": 13, "product_code": "2bcfabb7-eedf-4da1-ad8c-f464bb3e5ee6", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Tam Th\\u00e1i T\\u1eed Nh\\u1ea5t Ca s\\u00e1nh \\u0111\\u1eadm", "score": 0.74}]	2	t	[{"product_id": 52, "product_code": "ea03fd89-98bb-42ca-900a-59f1006717b8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "qty": 2, "unit_price": 298000.0}, {"product_id": 41, "product_code": "8c0bd0e0-9c72-4d67-9c29-61b269b31df8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 2, "unit_price": 355000.0}]	2026-02-21 02:33:15.050751
105	HCM_Q1	TXN-20260307-00105	2026-03-07 14:15:15.221507+00	46	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 67, "product_code": "a67c2aa4-d081-41f2-a440-30d00cd60c5b", "name": "L\\u1ed1c 2 h\\u0169 s\\u01b0\\u0303a chua n\\u00ea\\u0301p c\\u00e2\\u0309m Sa\\u0300i Go\\u0300n Milk 120g", "score": 0.62}, {"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "score": 0.69}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.83}]	3	t	[{"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "qty": 1, "unit_price": 349000.0}]	2026-03-07 14:19:15.221507
93	HN_CG	TXN-20260317-00093	2026-03-17 13:55:15.063296+00	\N	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "score": 0.93}, {"product_id": 12, "product_code": "32c195be-0444-4c26-8b09-761cb0b32136", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi thanh d\\u1ecbu", "score": 0.7}, {"product_id": 198, "product_code": "2c790f44-7ee9-4c1d-9170-0f67eaf7e736", "name": "M\\u0169 b\\u1ea3o hi\\u1ec3m n\\u1eeda \\u0111\\u1ea7u", "score": 0.66}]	3	f	[{"product_id": 111, "product_code": "39db55d0-6784-4457-900f-d85d7b17e783", "name": "H\\u1ea1t n\\u00eam Knorr (400g)", "qty": 1, "unit_price": 30400.0}, {"product_id": 30, "product_code": "f91639d0-6dfc-4083-a260-a2ad3c65eb41", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf g\\u00e0 \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 65g", "qty": 2, "unit_price": 43000.0}, {"product_id": 159, "product_code": "faa88516-1182-495d-981d-3a5f206d2770", "name": "S\\u00e1p kh\\u1eed m\\u00f9i ph\\u00f2ng (H\\u1ed9p)", "qty": 2, "unit_price": 40000.0}]	2026-03-17 14:04:15.063296
94	HN_CG	TXN-20260325-00094	2026-03-25 11:57:15.07448+00	\N	EDGE_HN_CG_01	{"age_group": "25_34", "gender": "female"}	[{"product_id": 41, "product_code": "8c0bd0e0-9c72-4d67-9c29-61b269b31df8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "score": 0.87}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "score": 0.89}, {"product_id": 75, "product_code": "adaf187e-c86b-4ead-a4fc-fa93d98d1735", "name": "Th\\u00f9ng 24 lon Bia Blanc 1664 330ml", "score": 0.79}]	3	f	[{"product_id": 130, "product_code": "260fa104-9d28-45a7-bb5e-06b373367221", "name": "B\\u00e1nh quy Cosy (G\\u00f3i 200g)", "qty": 1, "unit_price": 13500.0}]	2026-03-25 11:59:15.07448
95	HCM_Q7	TXN-20260313-00095	2026-03-13 01:25:15.085718+00	1	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 93, "product_code": "204e5daa-e27a-42e2-ad34-d29fcb5d84a5", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 320ml", "score": 0.69}, {"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "score": 0.89}, {"product_id": 171, "product_code": "34b1c04a-0e91-4eaf-ae2d-f379c0324d29", "name": "Pin AAA Panasonic (V\\u1ec9 2 vi\\u00ean)", "score": 0.8}]	3	t	[{"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 1, "unit_price": 52000.0}, {"product_id": 88, "product_code": "e26b7e68-b6d3-48b3-afc4-352c85e6962a", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb 390ml", "qty": 2, "unit_price": 118000.0}]	2026-03-13 01:29:15.085718
96	HCM_Q7	TXN-20260226-00096	2026-02-26 15:25:15.099166+00	\N	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "female"}	[{"product_id": 195, "product_code": "0c817e5a-0d94-4f29-be97-bc218296a244", "name": "Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "score": 0.95}, {"product_id": 10, "product_code": "63a338bb-de9f-45cb-b283-d0abab06015d", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Nh\\u1ecb Ca Tam Th\\u00e1i T\\u1eed chai", "score": 0.66}, {"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "score": 0.82}]	3	t	[{"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "qty": 2, "unit_price": 425000.0}, {"product_id": 198, "product_code": "2c790f44-7ee9-4c1d-9170-0f67eaf7e736", "name": "M\\u0169 b\\u1ea3o hi\\u1ec3m n\\u1eeda \\u0111\\u1ea7u", "qty": 2, "unit_price": 68000.0}, {"product_id": 3, "product_code": "fb8b76f0-baea-440d-acf3-f80e738a7958", "name": "D\\u1ea7u \\u0103n th\\u01b0\\u1ee3ng h\\u1ea1ng Neptune Light", "qty": 2, "unit_price": 62100.0}, {"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "qty": 1, "unit_price": 5000.0}]	2026-02-26 15:34:15.099166
97	HCM_Q7	TXN-20260218-00097	2026-02-18 10:40:15.112782+00	\N	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "score": 0.63}, {"product_id": 199, "product_code": "78df9983-9047-45ca-8867-aa9f19c6e3d6", "name": "\\u00c1o m\\u01b0a ti\\u1ec7n l\\u1ee3i (C\\u00e1i)", "score": 0.8}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "score": 0.75}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.87}]	4	f	[{"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 3, "unit_price": 25000.0}, {"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "qty": 3, "unit_price": 425000.0}, {"product_id": 180, "product_code": "8f382477-a9b4-44d6-bf2a-59fae61d9166", "name": "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "qty": 3, "unit_price": 19000.0}, {"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "qty": 3, "unit_price": 39000.0}, {"product_id": 115, "product_code": "11086cc9-d30a-4145-acaf-8e2084c851f0", "name": "T\\u01b0\\u01a1ng \\u1edbt Chinsu (250g)", "qty": 2, "unit_price": 12000.0}]	2026-02-18 10:43:15.112782
98	HN_CG	TXN-20260304-00098	2026-03-04 01:27:15.126701+00	57	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "unisex"}	[{"product_id": 13, "product_code": "2bcfabb7-eedf-4da1-ad8c-f464bb3e5ee6", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Tam Th\\u00e1i T\\u1eed Nh\\u1ea5t Ca s\\u00e1nh \\u0111\\u1eadm", "score": 0.85}, {"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "score": 0.65}]	2	f	[{"product_id": 152, "product_code": "a544d61d-edb8-4b54-ad19-8f4745d8307a", "name": "S\\u1eefa r\\u1eeda m\\u1eb7t Acnes (100g)", "qty": 3, "unit_price": 52250.0}, {"product_id": 67, "product_code": "a67c2aa4-d081-41f2-a440-30d00cd60c5b", "name": "L\\u1ed1c 2 h\\u0169 s\\u01b0\\u0303a chua n\\u00ea\\u0301p c\\u00e2\\u0309m Sa\\u0300i Go\\u0300n Milk 120g", "qty": 1, "unit_price": 27000.0}, {"product_id": 62, "product_code": "8e6ed997-217f-4dc4-ba92-611c2a6bbd91", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n \\u00edt \\u0111\\u01b0\\u1eddng Nutimilk 100g", "qty": 2, "unit_price": 26000.0}, {"product_id": 199, "product_code": "78df9983-9047-45ca-8867-aa9f19c6e3d6", "name": "\\u00c1o m\\u01b0a ti\\u1ec7n l\\u1ee3i (C\\u00e1i)", "qty": 2, "unit_price": 10000.0}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 3, "unit_price": 9600.0}]	2026-03-04 01:32:15.126701
139	HCM_Q7	TXN-20260304-00139	2026-03-04 20:46:15.579431+00	21	EDGE_HCM_Q7_01	{"age_group": "45_54", "gender": "unisex"}	[{"product_id": 188, "product_code": "4a5f7c93-02f6-48e0-bcb4-a1c7ae3aec53", "name": "B\\u00fat ch\\u00ec g\\u1ed7 2B", "score": 0.73}, {"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.68}]	2	f	[{"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "qty": 2, "unit_price": 7000.0}]	2026-03-04 20:47:15.579431
99	HN_CG	TXN-20260316-00099	2026-03-16 14:13:15.139985+00	19	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 109, "product_code": "013d09af-48c5-4c50-9709-5b6183c5e8cc", "name": "D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An", "score": 0.62}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "score": 0.94}, {"product_id": 21, "product_code": "9ad51e21-230b-486c-abce-5487f7b09ed3", "name": "M\\u00ec H\\u1ea3o 100 t\\u00f4m chua cay g\\u00f3i 65g", "score": 0.78}, {"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "score": 0.77}]	4	t	[{"product_id": 173, "product_code": "78a22c2f-8513-49ba-95df-227bbb48543e", "name": "Gi\\u1ea5y b\\u1ea1c n\\u01b0\\u1edbng (Cu\\u1ed9n)", "qty": 3, "unit_price": 25000.0}, {"product_id": 36, "product_code": "6ea649b0-f9e4-44cb-9fb9-768d1889cdf6", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "qty": 3, "unit_price": 425000.0}, {"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "qty": 1, "unit_price": 15000.0}, {"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "qty": 2, "unit_price": 5000.0}, {"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "qty": 2, "unit_price": 7000.0}]	2026-03-16 14:19:15.139985
100	HCM_Q7	TXN-20260227-00100	2026-02-27 13:06:15.153026+00	29	EDGE_HCM_Q7_01	{"age_group": "45_54", "gender": "unisex"}	[{"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.78}, {"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "score": 0.88}, {"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "score": 0.96}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "score": 0.74}]	4	f	[{"product_id": 188, "product_code": "4a5f7c93-02f6-48e0-bcb4-a1c7ae3aec53", "name": "B\\u00fat ch\\u00ec g\\u1ed7 2B", "qty": 3, "unit_price": 3000.0}, {"product_id": 107, "product_code": "950bc1a0-a654-4c1f-937a-91b5753c75c0", "name": "M\\u00ec H\\u1ea3o H\\u1ea3o T\\u00f4m Chua Cay", "qty": 2, "unit_price": 3600.0}, {"product_id": 42, "product_code": "13cbc909-c57c-4c13-8304-1abb2e7d16e6", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "qty": 1, "unit_price": 386750.0}, {"product_id": 37, "product_code": "6f831c1e-17cc-4ea1-848a-33cbc4c7ec9a", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 3, "unit_price": 375000.0}]	2026-02-27 13:08:15.153026
101	HCM_Q1	TXN-20260330-00101	2026-03-30 13:24:15.164644+00	20	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 73, "product_code": "c57b5193-7c6a-4e72-be5f-bf08951cd0ec", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "score": 0.91}, {"product_id": 56, "product_code": "c11379c8-f11b-4bc0-bc6b-32483cb53628", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p 170ml", "score": 0.79}, {"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "score": 0.65}]	3	f	[{"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 3, "unit_price": 9600.0}, {"product_id": 76, "product_code": "aa017cb5-b496-42a5-9417-beec7b243112", "name": "Th\\u00f9ng 12 lon bia Hoegaarden Peach v\\u1ecb \\u0111\\u00e0o 500ml", "qty": 2, "unit_price": 445000.0}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "qty": 1, "unit_price": 18000.0}]	2026-03-30 13:30:15.164644
102	HN_CG	TXN-20260323-00102	2026-03-23 00:50:15.178212+00	\N	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.85}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "score": 0.76}, {"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "score": 0.69}, {"product_id": 160, "product_code": "d560d1cf-83fa-47da-9467-26fa419a73ba", "name": "Thu\\u1ed1c x\\u1ecbt mu\\u1ed7i Raid (600ml)", "score": 0.75}]	4	t	[{"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 2, "unit_price": 52000.0}, {"product_id": 185, "product_code": "cf4e420e-2ede-4a08-8209-0eaa5a110cf5", "name": "D\\u00e2y r\\u00fat nh\\u1ef1a (T\\u00fai 100 s\\u1ee3i)", "qty": 2, "unit_price": 12750.0}, {"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "qty": 3, "unit_price": 8000.0}, {"product_id": 34, "product_code": "15458477-33d0-4386-bf74-bc53f8887361", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 2, "unit_price": 337500.0}]	2026-03-23 00:59:15.178212
103	HN_CG	TXN-20260327-00103	2026-03-27 23:04:15.194693+00	8	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "score": 0.68}, {"product_id": 5, "product_code": "9258ca2f-5e05-4eac-be09-b5a69a4b9cd0", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0 nh\\u00e3n v\\u00e0ng 14 \\u0111\\u1ed9 \\u0111\\u1ea1m", "score": 0.92}, {"product_id": 71, "product_code": "bbd97816-ba62-4a9a-8384-7d7bff031ab1", "name": "Th\\u00f9ng 24 lon Bia Heineken Silver 250ml", "score": 0.92}, {"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "score": 0.82}]	4	f	[{"product_id": 22, "product_code": "4f92b81a-203d-4ec7-b261-f1ffbe9b5ec4", "name": "M\\u00ec x\\u00e0o kh\\u00f4 Indomie Mi Goreng v\\u1ecb \\u0111\\u1eb7c bi\\u1ec7t g\\u00f3i 85g", "qty": 1, "unit_price": 5900.0}, {"product_id": 50, "product_code": "16150fd4-8086-42ac-a03a-6bcfd77425f2", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch BFAST b\\u1ed5 sung canxi 180ml", "qty": 2, "unit_price": 27000.0}, {"product_id": 159, "product_code": "faa88516-1182-495d-981d-3a5f206d2770", "name": "S\\u00e1p kh\\u1eed m\\u00f9i ph\\u00f2ng (H\\u1ed9p)", "qty": 3, "unit_price": 40000.0}, {"product_id": 139, "product_code": "efbd986b-4531-4883-afb4-194c9b59a109", "name": "B\\u1ed9t gi\\u1eb7t OMO (T\\u00fai 3kg)", "qty": 1, "unit_price": 125000.0}, {"product_id": 148, "product_code": "d6f2920e-e16a-4096-8159-a938f4b8ce59", "name": "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "qty": 1, "unit_price": 16200.0}]	2026-03-27 23:06:15.194693
106	HCM_Q1	TXN-20260317-00106	2026-03-17 17:19:15.230909+00	30	EDGE_HCM_Q1_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "score": 0.75}, {"product_id": 33, "product_code": "f5833d36-7b7f-4702-937f-8d1286c31a38", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "score": 0.63}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.84}, {"product_id": 146, "product_code": "fd9f259d-1ea9-4994-ae7d-d00f930fcde4", "name": "N\\u01b0\\u1edbc t\\u1ea9y b\\u1ed3n c\\u1ea7u Vim (900ml)", "score": 0.68}]	4	f	[{"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "qty": 3, "unit_price": 12350.0}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "qty": 3, "unit_price": 95200.0}, {"product_id": 124, "product_code": "4603c6b9-3f0e-4455-9c80-afad12742d51", "name": "N\\u01b0\\u1edbc su\\u1ed1i Aquafina (500ml)", "qty": 3, "unit_price": 4750.0}, {"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 1, "unit_price": 37050.0}, {"product_id": 163, "product_code": "5acdac1a-898e-4a9f-8acd-f8590ce29d7b", "name": "C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)", "qty": 1, "unit_price": 12000.0}]	2026-03-17 17:22:15.230909
107	HN_CG	TXN-20260312-00107	2026-03-12 21:19:15.24064+00	\N	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "score": 0.82}, {"product_id": 90, "product_code": "61c35ff1-5a92-4568-9870-e345bc73a24c", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml", "score": 0.79}, {"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "score": 0.62}, {"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "score": 0.88}]	4	t	[{"product_id": 116, "product_code": "de0f18f5-f3b9-44bb-9d2d-ca990368168e", "name": "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "qty": 1, "unit_price": 30000.0}, {"product_id": 11, "product_code": "c657b334-1d73-44af-b7cc-74d5d5bd1efa", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi \\u0111\\u1eadm \\u0111\\u1eb7c", "qty": 1, "unit_price": 35000.0}, {"product_id": 1, "product_code": "9583297f-78a6-4dfc-84a5-82f214b9e86e", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh tinh luy\\u1ec7n Janbee", "qty": 2, "unit_price": 69500.0}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "qty": 2, "unit_price": 32000.0}, {"product_id": 159, "product_code": "faa88516-1182-495d-981d-3a5f206d2770", "name": "S\\u00e1p kh\\u1eed m\\u00f9i ph\\u00f2ng (H\\u1ed9p)", "qty": 3, "unit_price": 40000.0}]	2026-03-12 21:29:15.24064
108	HN_CG	TXN-20260310-00108	2026-03-10 20:17:15.252994+00	\N	EDGE_HN_CG_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 116, "product_code": "de0f18f5-f3b9-44bb-9d2d-ca990368168e", "name": "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "score": 0.97}, {"product_id": 70, "product_code": "83bab65c-5e02-45a8-936d-58eaa4e206a2", "name": "Th\\u00f9ng 24 lon Bia Tiger lon 250ml", "score": 0.73}, {"product_id": 63, "product_code": "ffab1e43-67a3-4455-b9f5-ece65ebd4ebb", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n nha \\u0111am Lothamilk 100g", "score": 0.77}, {"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "score": 0.83}]	4	f	[{"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 3, "unit_price": 25000.0}, {"product_id": 130, "product_code": "260fa104-9d28-45a7-bb5e-06b373367221", "name": "B\\u00e1nh quy Cosy (G\\u00f3i 200g)", "qty": 2, "unit_price": 13500.0}]	2026-03-10 20:18:15.252994
109	HCM_Q7	TXN-20260217-00109	2026-02-17 21:34:15.265003+00	35	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "score": 0.97}, {"product_id": 173, "product_code": "78a22c2f-8513-49ba-95df-227bbb48543e", "name": "Gi\\u1ea5y b\\u1ea1c n\\u01b0\\u1edbng (Cu\\u1ed9n)", "score": 0.74}, {"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.83}, {"product_id": 91, "product_code": "845e5e02-35a6-498e-9420-f6d30ae72b04", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Coca Cola 320ml", "score": 0.75}]	4	t	[{"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "qty": 3, "unit_price": 42500.0}]	2026-02-17 21:35:15.265003
110	HCM_Q1	TXN-20260319-00110	2026-03-19 14:39:15.274566+00	49	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "score": 0.97}, {"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "score": 0.61}]	2	f	[{"product_id": 175, "product_code": "c55a887f-03c5-45e6-9934-5f8a9a007306", "name": "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "qty": 3, "unit_price": 10000.0}, {"product_id": 182, "product_code": "04931d60-d635-4729-8b9e-1171306f235b", "name": "N\\u1ebfn c\\u00e2y (G\\u00f3i 5 c\\u00e2y)", "qty": 3, "unit_price": 10000.0}, {"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "qty": 2, "unit_price": 17850.0}]	2026-03-19 14:47:15.274566
111	HCM_Q7	TXN-20260216-00111	2026-02-16 17:59:15.284703+00	\N	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "score": 0.65}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "score": 0.95}]	2	t	[{"product_id": 129, "product_code": "fb1ea21f-cda1-4678-a372-358a68f83a9c", "name": "K\\u1eb9o c\\u1ee9ng Dynamite", "qty": 3, "unit_price": 8000.0}, {"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "qty": 3, "unit_price": 28500.0}, {"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 3, "unit_price": 355000.0}, {"product_id": 142, "product_code": "11c60194-88d2-4816-997a-5553a8cb6196", "name": "Kem \\u0111\\u00e1nh r\\u0103ng P/S (180g)", "qty": 3, "unit_price": 28000.0}, {"product_id": 50, "product_code": "16150fd4-8086-42ac-a03a-6bcfd77425f2", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch BFAST b\\u1ed5 sung canxi 180ml", "qty": 1, "unit_price": 27000.0}]	2026-02-16 18:03:15.284703
112	HCM_Q1	TXN-20260304-00112	2026-03-04 04:17:15.296027+00	42	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "female"}	[{"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "score": 0.89}, {"product_id": 93, "product_code": "204e5daa-e27a-42e2-ad34-d29fcb5d84a5", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 320ml", "score": 0.94}, {"product_id": 133, "product_code": "7a904b8a-d0d0-4b76-95cf-4b2020758a9e", "name": "N\\u01b0\\u1edbc t\\u0103ng l\\u1ef1c Redbull (Lon)", "score": 0.69}]	3	f	[{"product_id": 83, "product_code": "a0500366-8dd9-44bc-ad93-6e2f9241f1bf", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng d\\u1ee9a 12.5% chai 360ml", "qty": 1, "unit_price": 38250.0}]	2026-03-04 04:22:15.296027
113	HCM_Q1	TXN-20260316-00113	2026-03-16 19:10:15.305598+00	37	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 43, "product_code": "d4bfaf6c-3b76-40b5-b6d1-ff43f5cd2555", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng v\\u1ecb t\\u1ef1 nhi\\u00ean TH true MILK Hilo 180ml", "score": 0.72}, {"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.84}]	2	f	[{"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "qty": 1, "unit_price": 5000.0}]	2026-03-16 19:12:15.305598
114	HN_CG	TXN-20260316-00114	2026-03-16 06:44:15.313405+00	\N	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 19, "product_code": "aca2f004-f76e-481b-abe7-d495d4a2d9d1", "name": "Th\\u00f9ng 24 ly m\\u00ec Handy H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 67g", "score": 0.83}, {"product_id": 199, "product_code": "78df9983-9047-45ca-8867-aa9f19c6e3d6", "name": "\\u00c1o m\\u01b0a ti\\u1ec7n l\\u1ee3i (C\\u00e1i)", "score": 0.77}]	2	f	[{"product_id": 28, "product_code": "91aed179-28dd-4cb2-96db-44c239795d5f", "name": "Ph\\u1edf b\\u00f2 Vifon g\\u00f3i 90g (c\\u00f3 g\\u00f3i th\\u1ecbt th\\u1eadt)", "qty": 1, "unit_price": 17000.0}, {"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 2, "unit_price": 52000.0}]	2026-03-16 06:46:15.313405
115	HCM_Q7	TXN-20260304-00115	2026-03-04 15:23:15.320933+00	4	EDGE_HCM_Q7_01	{"age_group": "25_34", "gender": "female"}	[{"product_id": 103, "product_code": "215bb35c-37c7-451d-8a5e-19d774e2ec28", "name": "B\\u00e1nh quy socola chip nh\\u00e2n socola Parle Platina Hide & Seek g\\u00f3i 112.5g", "score": 0.89}, {"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.69}, {"product_id": 159, "product_code": "faa88516-1182-495d-981d-3a5f206d2770", "name": "S\\u00e1p kh\\u1eed m\\u00f9i ph\\u00f2ng (H\\u1ed9p)", "score": 0.83}]	3	t	[{"product_id": 15, "product_code": "cebc7811-c35c-4a9d-8b37-854d28b07b22", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g", "qty": 3, "unit_price": 110200.0}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 1, "unit_price": 9600.0}, {"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 3, "unit_price": 25000.0}, {"product_id": 161, "product_code": "d0ce3076-c06f-42af-ba23-221c0ee27198", "name": "Nhang mu\\u1ed7i (H\\u1ed9p 10 khoanh)", "qty": 1, "unit_price": 8000.0}]	2026-03-04 15:33:15.320933
116	HN_CG	TXN-20260226-00116	2026-02-26 06:58:15.329627+00	44	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 153, "product_code": "0fae3be1-0f57-4a82-aba9-d13e180c1943", "name": "Dao c\\u1ea1o r\\u00e2u Gillette (C\\u00e2y)", "score": 0.63}, {"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "score": 0.9}]	2	t	[{"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "qty": 1, "unit_price": 18000.0}]	2026-02-26 07:02:15.329627
117	HN_CG	TXN-20260323-00117	2026-03-23 07:56:15.338895+00	9	EDGE_HN_CG_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "score": 0.94}, {"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "score": 0.89}, {"product_id": 80, "product_code": "77e0bf6d-eb78-4ab7-8a73-d61458d018c6", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb vi\\u1ec7t qu\\u1ea5t 12% chai 360ml", "score": 0.66}, {"product_id": 150, "product_code": "8f4dc2fd-7d0d-449f-88a4-47cad03d38d2", "name": "T\\u00e3 qu\\u1ea7n Bobby (B\\u1ecbch M40)", "score": 0.72}]	4	f	[{"product_id": 16, "product_code": "9ce59ad8-ccbb-49de-9acf-155792a5655f", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o sa t\\u1ebf h\\u00e0nh t\\u00edm 75g", "qty": 2, "unit_price": 119000.0}]	2026-03-23 08:02:15.338895
118	HN_CG	TXN-20260219-00118	2026-02-19 10:44:15.348461+00	33	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "score": 0.92}, {"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "score": 0.82}, {"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.73}]	3	f	[{"product_id": 14, "product_code": "7d31d029-8f17-4074-ad5e-96f50b6b9465", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en", "qty": 1, "unit_price": 41000.0}, {"product_id": 109, "product_code": "013d09af-48c5-4c50-9709-5b6183c5e8cc", "name": "D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An", "qty": 2, "unit_price": 48000.0}, {"product_id": 89, "product_code": "4362ec25-fdc1-4b2a-9588-6642962e5302", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Pepsi Cola 390ml", "qty": 1, "unit_price": 118000.0}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "qty": 3, "unit_price": 298000.0}, {"product_id": 52, "product_code": "ea03fd89-98bb-42ca-900a-59f1006717b8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "qty": 2, "unit_price": 298000.0}]	2026-02-19 10:49:15.348461
119	HCM_Q1	TXN-20260301-00119	2026-03-01 22:25:15.358281+00	1	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 190, "product_code": "91a2bcb3-d18b-47dc-ab24-5af040967bf2", "name": "Th\\u01b0\\u1edbc k\\u1ebb 20cm", "score": 0.75}, {"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "score": 0.91}, {"product_id": 53, "product_code": "d5b1b057-5bcf-4629-a973-7f8e9c0bca3c", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "score": 0.6}]	3	f	[{"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "qty": 1, "unit_price": 40000.0}, {"product_id": 59, "product_code": "b9c6ad3b-cba2-4de1-96f6-b27fe38a368f", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "qty": 2, "unit_price": 24650.0}]	2026-03-01 22:26:15.358281
120	HCM_Q7	TXN-20260319-00120	2026-03-19 08:25:15.367844+00	38	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 63, "product_code": "ffab1e43-67a3-4455-b9f5-ece65ebd4ebb", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n nha \\u0111am Lothamilk 100g", "score": 0.67}, {"product_id": 46, "product_code": "8636600f-9b6f-4cb4-a120-cf70c55c20e6", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "score": 0.7}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "score": 0.64}, {"product_id": 6, "product_code": "4261ad1a-adce-4554-9710-a9edbdc16f52", "name": "N\\u01b0\\u1edbc ch\\u1ea5m Nam Ng\\u01b0 \\u0110\\u1ec7 Nh\\u1ecb", "score": 0.92}]	4	t	[{"product_id": 12, "product_code": "32c195be-0444-4c26-8b09-761cb0b32136", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi thanh d\\u1ecbu", "qty": 1, "unit_price": 22000.0}, {"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 2, "unit_price": 37050.0}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "qty": 3, "unit_price": 298000.0}]	2026-03-19 08:28:15.367844
121	HCM_Q7	TXN-20260220-00121	2026-02-20 03:37:15.383791+00	24	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "unisex"}	[{"product_id": 204, "product_code": "e03863a3-5056-43ed-af9e-77bdb148f682", "name": "C\\u1ee7 s\\u1ea1c USB 2 c\\u1ed5ng", "score": 0.67}, {"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "score": 0.74}]	2	t	[{"product_id": 135, "product_code": "c7f42ff3-6047-4f08-866c-1b32209e3f90", "name": "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "qty": 3, "unit_price": 18000.0}, {"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "qty": 1, "unit_price": 19000.0}]	2026-02-20 03:43:15.383791
122	HCM_Q1	TXN-20260316-00122	2026-03-16 15:56:15.398062+00	\N	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 54, "product_code": "c5544e90-b58e-4a17-89af-5f131087703b", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "score": 0.9}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "score": 0.9}, {"product_id": 21, "product_code": "9ad51e21-230b-486c-abce-5487f7b09ed3", "name": "M\\u00ec H\\u1ea3o 100 t\\u00f4m chua cay g\\u00f3i 65g", "score": 0.83}]	3	f	[{"product_id": 203, "product_code": "cd3322e6-fa79-4ff1-9ec1-017716f5f8af", "name": "C\\u00e1p s\\u1ea1c Android/iPhone", "qty": 2, "unit_price": 40000.0}, {"product_id": 39, "product_code": "0e3740f8-9d6f-4f7b-b1bb-3b719c18c93b", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "qty": 1, "unit_price": 330000.0}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "qty": 3, "unit_price": 45000.0}]	2026-03-16 15:59:15.398062
123	HCM_Q7	TXN-20260218-00123	2026-02-18 22:48:15.409612+00	31	EDGE_HCM_Q7_01	{"age_group": "25_34", "gender": "female"}	[{"product_id": 102, "product_code": "81606b2f-15e4-4ffc-a73b-fe9afc07043e", "name": "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g", "score": 0.72}, {"product_id": 56, "product_code": "c11379c8-f11b-4bc0-bc6b-32483cb53628", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p 170ml", "score": 0.94}]	2	f	[{"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 1, "unit_price": 52000.0}, {"product_id": 69, "product_code": "c6db64ee-92ea-4113-8297-a2e94c4f6be6", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa dinh d\\u01b0\\u1ee1ng Gotz 55g", "qty": 1, "unit_price": 34500.0}, {"product_id": 149, "product_code": "37ee0bd9-0b99-403e-96ab-f314af9c2e8e", "name": "B\\u0103ng v\\u1ec7 sinh Diana (G\\u00f3i 8)", "qty": 1, "unit_price": 16200.0}, {"product_id": 103, "product_code": "215bb35c-37c7-451d-8a5e-19d774e2ec28", "name": "B\\u00e1nh quy socola chip nh\\u00e2n socola Parle Platina Hide & Seek g\\u00f3i 112.5g", "qty": 1, "unit_price": 26000.0}]	2026-02-18 22:58:15.409612
124	HCM_Q1	TXN-20260302-00124	2026-03-02 00:56:15.420859+00	23	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "score": 0.72}, {"product_id": 95, "product_code": "0f57e196-eacf-4d9f-89a6-5fdd236a80c9", "name": "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "score": 0.75}, {"product_id": 128, "product_code": "a010e906-1854-42a0-944b-8bcd42f82e55", "name": "Snack Khoai t\\u00e2y O'Star", "score": 0.67}]	3	f	[{"product_id": 150, "product_code": "8f4dc2fd-7d0d-449f-88a4-47cad03d38d2", "name": "T\\u00e3 qu\\u1ea7n Bobby (B\\u1ecbch M40)", "qty": 2, "unit_price": 210000.0}, {"product_id": 11, "product_code": "c657b334-1d73-44af-b7cc-74d5d5bd1efa", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi \\u0111\\u1eadm \\u0111\\u1eb7c", "qty": 2, "unit_price": 35000.0}]	2026-03-02 01:00:15.420859
125	HN_CG	TXN-20260327-00125	2026-03-27 06:34:15.430833+00	60	EDGE_HN_CG_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.91}, {"product_id": 65, "product_code": "0433b59d-902c-4298-8e26-55d4ccbaf182", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n kh\\u00f4ng \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "score": 0.86}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.7}, {"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "score": 0.87}]	4	t	[{"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "qty": 3, "unit_price": 11500.0}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 1, "unit_price": 170000.0}]	2026-03-27 06:37:15.430833
140	HCM_Q7	TXN-20260327-00140	2026-03-27 11:32:15.589598+00	1	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 33, "product_code": "f5833d36-7b7f-4702-937f-8d1286c31a38", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "score": 0.67}, {"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "score": 0.81}]	2	f	[{"product_id": 126, "product_code": "d487390c-5ffd-47eb-b891-e9feeaeb0830", "name": "Bia Tiger N\\u00e2u (Lon 330ml)", "qty": 3, "unit_price": 16000.0}]	2026-03-27 11:36:15.589598
126	HCM_Q7	TXN-20260322-00126	2026-03-22 05:21:15.442065+00	\N	EDGE_HCM_Q7_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "score": 0.87}, {"product_id": 142, "product_code": "11c60194-88d2-4816-997a-5553a8cb6196", "name": "Kem \\u0111\\u00e1nh r\\u0103ng P/S (180g)", "score": 0.78}, {"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "score": 0.9}, {"product_id": 120, "product_code": "95bd5a46-0188-4553-927a-64cb57498ebc", "name": "L\\u1ed1c 4 s\\u1eefa chua Vinamilk", "score": 0.72}]	4	t	[{"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "qty": 1, "unit_price": 8500.0}, {"product_id": 168, "product_code": "131a23d6-1d20-4d98-b9dd-2d0eb19e0b54", "name": "B\\u00f3ng \\u0111\\u00e8n LED \\u0110i\\u1ec7n Quang 20W", "qty": 3, "unit_price": 45000.0}, {"product_id": 4, "product_code": "2552366a-29a2-46a3-943a-3d8fb45b3fad", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "qty": 3, "unit_price": 59000.0}, {"product_id": 121, "product_code": "827e4a51-3225-4f53-a04f-e03b0e5b9f8d", "name": "S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "qty": 1, "unit_price": 26000.0}, {"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "qty": 2, "unit_price": 22500.0}]	2026-03-22 05:25:15.442065
127	HCM_Q7	TXN-20260217-00127	2026-02-17 06:17:15.453051+00	9	EDGE_HCM_Q7_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "score": 0.8}, {"product_id": 200, "product_code": "44e0b85c-6165-439b-84b4-6f85374c19e1", "name": "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "score": 0.72}, {"product_id": 177, "product_code": "991f1b12-1dc2-498a-83bb-75bf860ad56b", "name": "K\\u1eb9p qu\\u1ea7n \\u00e1o (V\\u1ec9 20)", "score": 0.61}]	3	f	[{"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "qty": 1, "unit_price": 5000.0}, {"product_id": 3, "product_code": "fb8b76f0-baea-440d-acf3-f80e738a7958", "name": "D\\u1ea7u \\u0103n th\\u01b0\\u1ee3ng h\\u1ea1ng Neptune Light", "qty": 2, "unit_price": 62100.0}, {"product_id": 128, "product_code": "a010e906-1854-42a0-944b-8bcd42f82e55", "name": "Snack Khoai t\\u00e2y O'Star", "qty": 2, "unit_price": 9500.0}]	2026-02-17 06:18:15.453051
128	HN_CG	TXN-20260225-00128	2026-02-25 05:17:15.464955+00	\N	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 164, "product_code": "5576682c-00ee-4aab-8888-3526e2bf7626", "name": "Bao tay cao su (\\u0110\\u00f4i)", "score": 0.67}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.86}, {"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "score": 0.67}]	3	t	[{"product_id": 101, "product_code": "26b41c6b-4f50-45ec-b945-2a2e9eb74025", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh c\\u00e1 v\\u1ecb t\\u00f4m n\\u01b0\\u1edbng m\\u00f4i \\u0111\\u1ecf Orion Marine Boy 35g", "qty": 2, "unit_price": 260000.0}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "qty": 1, "unit_price": 95200.0}]	2026-02-25 05:27:15.464955
129	HCM_Q7	TXN-20260331-00129	2026-03-31 12:15:15.475678+00	43	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "unisex"}	[{"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "score": 0.96}, {"product_id": 18, "product_code": "fc0359c0-800a-40c9-8e49-660ab593f7e3", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "score": 0.93}, {"product_id": 100, "product_code": "46b1b7b5-3a08-4c49-96c5-44e9cf02c72d", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh quy socola Orion Miz 54g", "score": 0.65}]	3	f	[{"product_id": 18, "product_code": "fc0359c0-800a-40c9-8e49-660ab593f7e3", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "qty": 2, "unit_price": 105300.0}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "qty": 2, "unit_price": 18000.0}, {"product_id": 15, "product_code": "cebc7811-c35c-4a9d-8b37-854d28b07b22", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g", "qty": 1, "unit_price": 110200.0}, {"product_id": 95, "product_code": "0f57e196-eacf-4d9f-89a6-5fdd236a80c9", "name": "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "qty": 1, "unit_price": 22950.0}, {"product_id": 133, "product_code": "7a904b8a-d0d0-4b76-95cf-4b2020758a9e", "name": "N\\u01b0\\u1edbc t\\u0103ng l\\u1ef1c Redbull (Lon)", "qty": 1, "unit_price": 12000.0}]	2026-03-31 12:19:15.475678
130	HCM_Q1	TXN-20260303-00130	2026-03-03 14:41:15.48747+00	33	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 126, "product_code": "d487390c-5ffd-47eb-b891-e9feeaeb0830", "name": "Bia Tiger N\\u00e2u (Lon 330ml)", "score": 0.61}, {"product_id": 118, "product_code": "071cea0f-3714-449f-b21f-86ddce66fd4d", "name": "C\\u00e1 h\\u1ed9p 3 C\\u00f4 G\\u00e1i", "score": 0.63}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "score": 0.85}, {"product_id": 148, "product_code": "d6f2920e-e16a-4096-8159-a938f4b8ce59", "name": "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "score": 0.95}]	4	t	[{"product_id": 71, "product_code": "bbd97816-ba62-4a9a-8384-7d7bff031ab1", "name": "Th\\u00f9ng 24 lon Bia Heineken Silver 250ml", "qty": 2, "unit_price": 355000.0}, {"product_id": 52, "product_code": "ea03fd89-98bb-42ca-900a-59f1006717b8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "qty": 3, "unit_price": 298000.0}, {"product_id": 2, "product_code": "76e07498-8366-4687-a82e-2a47ecd1e994", "name": "D\\u1ea7u th\\u1ef1c v\\u1eadt tinh luy\\u1ec7n C\\u00e1i L\\u00e2n", "qty": 1, "unit_price": 39100.0}, {"product_id": 37, "product_code": "6f831c1e-17cc-4ea1-848a-33cbc4c7ec9a", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 3, "unit_price": 375000.0}]	2026-03-03 14:47:15.48747
131	HCM_Q1	TXN-20260319-00131	2026-03-19 19:01:15.500713+00	58	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 71, "product_code": "bbd97816-ba62-4a9a-8384-7d7bff031ab1", "name": "Th\\u00f9ng 24 lon Bia Heineken Silver 250ml", "score": 0.8}, {"product_id": 161, "product_code": "d0ce3076-c06f-42af-ba23-221c0ee27198", "name": "Nhang mu\\u1ed7i (H\\u1ed9p 10 khoanh)", "score": 0.85}]	2	f	[{"product_id": 188, "product_code": "4a5f7c93-02f6-48e0-bcb4-a1c7ae3aec53", "name": "B\\u00fat ch\\u00ec g\\u1ed7 2B", "qty": 1, "unit_price": 3000.0}, {"product_id": 111, "product_code": "39db55d0-6784-4457-900f-d85d7b17e783", "name": "H\\u1ea1t n\\u00eam Knorr (400g)", "qty": 2, "unit_price": 30400.0}, {"product_id": 118, "product_code": "071cea0f-3714-449f-b21f-86ddce66fd4d", "name": "C\\u00e1 h\\u1ed9p 3 C\\u00f4 G\\u00e1i", "qty": 3, "unit_price": 20000.0}, {"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "qty": 1, "unit_price": 35500.0}, {"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "qty": 1, "unit_price": 68000.0}]	2026-03-19 19:03:15.500713
132	HCM_Q1	TXN-20260321-00132	2026-03-21 09:24:15.511977+00	7	EDGE_HCM_Q1_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 192, "product_code": "b812638a-f73d-4a60-9695-eac88da8a809", "name": "B\\u1ea5m kim s\\u1ed1 10 (C\\u00e1i)", "score": 0.88}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "score": 0.93}, {"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "score": 0.75}, {"product_id": 88, "product_code": "e26b7e68-b6d3-48b3-afc4-352c85e6962a", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb 390ml", "score": 0.6}]	4	f	[{"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "qty": 3, "unit_price": 30000.0}, {"product_id": 200, "product_code": "44e0b85c-6165-439b-84b4-6f85374c19e1", "name": "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "qty": 1, "unit_price": 70000.0}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "qty": 2, "unit_price": 45000.0}, {"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "qty": 1, "unit_price": 12350.0}, {"product_id": 116, "product_code": "de0f18f5-f3b9-44bb-9d2d-ca990368168e", "name": "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "qty": 1, "unit_price": 30000.0}]	2026-03-21 09:26:15.511977
133	HCM_Q7	TXN-20260323-00133	2026-03-23 01:40:15.521515+00	43	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "unisex"}	[{"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "score": 0.67}, {"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "score": 0.65}]	2	t	[{"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "qty": 2, "unit_price": 15000.0}, {"product_id": 113, "product_code": "e7753b8d-850e-4de8-935e-b4cb3e98063a", "name": "\\u0110\\u01b0\\u1eddng tinh luy\\u1ec7n Bi\\u00ean H\\u00f2a (1kg)", "qty": 1, "unit_price": 17600.0}]	2026-03-23 01:47:15.521515
134	HCM_Q7	TXN-20260216-00134	2026-02-16 00:16:15.531787+00	12	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "female"}	[{"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "score": 0.85}, {"product_id": 165, "product_code": "e7082b36-2f83-4c1f-a986-57c985941c24", "name": "T\\u00fai \\u0111\\u1ef1ng r\\u00e1c (Cu\\u1ed9n 3 m\\u00e0u)", "score": 0.64}, {"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "score": 0.86}, {"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "score": 0.77}]	4	t	[{"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "qty": 2, "unit_price": 15000.0}, {"product_id": 9, "product_code": "e4c1b87f-da03-460d-970f-cccf1b363bc7", "name": "N\\u01b0\\u1edbc m\\u1eafm Chinsu c\\u00e1 c\\u01a1m bi\\u1ec3n \\u0111\\u00f4ng 25 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 3, "unit_price": 48450.0}]	2026-02-16 00:26:15.531787
135	HCM_Q1	TXN-20260305-00135	2026-03-05 17:36:15.541947+00	\N	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.9}, {"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.92}]	2	f	[{"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "qty": 2, "unit_price": 250000.0}, {"product_id": 5, "product_code": "9258ca2f-5e05-4eac-be09-b5a69a4b9cd0", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0 nh\\u00e3n v\\u00e0ng 14 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 1, "unit_price": 41500.0}]	2026-03-05 17:39:15.541947
136	HCM_Q7	TXN-20260325-00136	2026-03-25 06:09:15.550524+00	60	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 118, "product_code": "071cea0f-3714-449f-b21f-86ddce66fd4d", "name": "C\\u00e1 h\\u1ed9p 3 C\\u00f4 G\\u00e1i", "score": 0.63}, {"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.91}]	2	t	[{"product_id": 102, "product_code": "81606b2f-15e4-4ffc-a73b-fe9afc07043e", "name": "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g", "qty": 1, "unit_price": 21250.0}, {"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "qty": 1, "unit_price": 42000.0}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 2, "unit_price": 170000.0}, {"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "qty": 3, "unit_price": 20800.0}, {"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "qty": 2, "unit_price": 37000.0}]	2026-03-25 06:19:15.550524
137	HCM_Q7	TXN-20260224-00137	2026-02-24 23:23:15.560229+00	\N	EDGE_HCM_Q7_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.86}, {"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "score": 0.97}, {"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "score": 0.86}, {"product_id": 100, "product_code": "46b1b7b5-3a08-4c49-96c5-44e9cf02c72d", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh quy socola Orion Miz 54g", "score": 0.73}]	4	f	[{"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "qty": 2, "unit_price": 15000.0}]	2026-02-24 23:29:15.560229
138	HN_CG	TXN-20260329-00138	2026-03-29 21:44:15.569782+00	46	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "score": 0.63}, {"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "score": 0.65}, {"product_id": 63, "product_code": "ffab1e43-67a3-4455-b9f5-ece65ebd4ebb", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n nha \\u0111am Lothamilk 100g", "score": 0.79}, {"product_id": 159, "product_code": "faa88516-1182-495d-981d-3a5f206d2770", "name": "S\\u00e1p kh\\u1eed m\\u00f9i ph\\u00f2ng (H\\u1ed9p)", "score": 0.68}]	4	t	[{"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "qty": 1, "unit_price": 20800.0}]	2026-03-29 21:51:15.569782
141	HCM_Q7	TXN-20260312-00141	2026-03-12 23:04:15.60126+00	16	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 102, "product_code": "81606b2f-15e4-4ffc-a73b-fe9afc07043e", "name": "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g", "score": 0.78}, {"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "score": 0.76}, {"product_id": 43, "product_code": "d4bfaf6c-3b76-40b5-b6d1-ff43f5cd2555", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng v\\u1ecb t\\u1ef1 nhi\\u00ean TH true MILK Hilo 180ml", "score": 0.83}]	3	t	[{"product_id": 46, "product_code": "8636600f-9b6f-4cb4-a120-cf70c55c20e6", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "qty": 3, "unit_price": 31500.0}, {"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "qty": 1, "unit_price": 8000.0}, {"product_id": 64, "product_code": "0f123724-4435-43b5-a850-de579646313d", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua nha \\u0111am Nutimilk 100g", "qty": 2, "unit_price": 27900.0}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 2, "unit_price": 9600.0}]	2026-03-12 23:11:15.60126
142	HCM_Q1	TXN-20260312-00142	2026-03-12 03:14:15.610577+00	10	EDGE_HCM_Q1_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 121, "product_code": "827e4a51-3225-4f53-a04f-e03b0e5b9f8d", "name": "S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "score": 0.6}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "score": 0.93}, {"product_id": 40, "product_code": "662bdd0b-b218-4630-b448-3d2702743375", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t TH true MILK 180ml", "score": 0.88}, {"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "score": 0.74}]	4	t	[{"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 2, "unit_price": 6800.0}, {"product_id": 45, "product_code": "70aecc30-273a-4640-ae9e-bf45c96ba51b", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng lof Kun 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 3, "unit_price": 376000.0}, {"product_id": 66, "product_code": "59989980-7fbb-4c6a-bf32-5d2cb1fa21c5", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Happy Star Vinamilk 100g", "qty": 3, "unit_price": 25500.0}, {"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "qty": 2, "unit_price": 65000.0}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "qty": 1, "unit_price": 32000.0}]	2026-03-12 03:21:15.610577
143	HCM_Q7	TXN-20260329-00143	2026-03-29 14:09:15.620842+00	38	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 66, "product_code": "59989980-7fbb-4c6a-bf32-5d2cb1fa21c5", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Happy Star Vinamilk 100g", "score": 0.87}, {"product_id": 198, "product_code": "2c790f44-7ee9-4c1d-9170-0f67eaf7e736", "name": "M\\u0169 b\\u1ea3o hi\\u1ec3m n\\u1eeda \\u0111\\u1ea7u", "score": 0.79}, {"product_id": 193, "product_code": "057d7a10-7e86-4899-a4d3-2bbb14ab8e8d", "name": "B\\u00eca h\\u1ed3 s\\u01a1 Clearbag (C\\u00e1i)", "score": 0.79}]	3	t	[{"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "qty": 3, "unit_price": 12350.0}]	2026-03-29 14:15:15.620842
144	HCM_Q1	TXN-20260329-00144	2026-03-29 18:55:15.634038+00	53	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "score": 0.82}, {"product_id": 66, "product_code": "59989980-7fbb-4c6a-bf32-5d2cb1fa21c5", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Happy Star Vinamilk 100g", "score": 0.85}, {"product_id": 64, "product_code": "0f123724-4435-43b5-a850-de579646313d", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua nha \\u0111am Nutimilk 100g", "score": 0.66}, {"product_id": 155, "product_code": "4dd70e94-850f-406f-a440-c4a161d99325", "name": "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "score": 0.64}]	4	f	[{"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "qty": 3, "unit_price": 12000.0}, {"product_id": 181, "product_code": "e483f862-1cbe-45fd-bdb1-169e28072fc2", "name": "B\\u1eadt l\\u1eeda gas", "qty": 1, "unit_price": 3000.0}, {"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "qty": 2, "unit_price": 4750.0}]	2026-03-29 18:57:15.634038
145	HCM_Q1	TXN-20260215-00145	2026-02-15 08:01:15.642691+00	\N	EDGE_HCM_Q1_01	{"age_group": "25_34", "gender": "female"}	[{"product_id": 79, "product_code": "dcf4b890-c91e-4ef3-bf6e-b4433d191182", "name": "Bia Corona Extra chai 250ml", "score": 0.93}, {"product_id": 188, "product_code": "4a5f7c93-02f6-48e0-bcb4-a1c7ae3aec53", "name": "B\\u00fat ch\\u00ec g\\u1ed7 2B", "score": 0.88}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "score": 0.63}, {"product_id": 193, "product_code": "057d7a10-7e86-4899-a4d3-2bbb14ab8e8d", "name": "B\\u00eca h\\u1ed3 s\\u01a1 Clearbag (C\\u00e1i)", "score": 0.84}]	4	f	[{"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "qty": 3, "unit_price": 42000.0}, {"product_id": 65, "product_code": "0433b59d-902c-4298-8e26-55d4ccbaf182", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n kh\\u00f4ng \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "qty": 3, "unit_price": 26000.0}]	2026-02-15 08:07:15.642691
146	HCM_Q1	TXN-20260304-00146	2026-03-04 12:25:15.652541+00	5	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 129, "product_code": "fb1ea21f-cda1-4678-a372-358a68f83a9c", "name": "K\\u1eb9o c\\u1ee9ng Dynamite", "score": 0.77}, {"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "score": 0.91}]	2	t	[{"product_id": 135, "product_code": "c7f42ff3-6047-4f08-866c-1b32209e3f90", "name": "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "qty": 2, "unit_price": 18000.0}, {"product_id": 107, "product_code": "950bc1a0-a654-4c1f-937a-91b5753c75c0", "name": "M\\u00ec H\\u1ea3o H\\u1ea3o T\\u00f4m Chua Cay", "qty": 1, "unit_price": 3600.0}, {"product_id": 168, "product_code": "131a23d6-1d20-4d98-b9dd-2d0eb19e0b54", "name": "B\\u00f3ng \\u0111\\u00e8n LED \\u0110i\\u1ec7n Quang 20W", "qty": 3, "unit_price": 45000.0}, {"product_id": 74, "product_code": "bfc156f1-4268-4720-ba38-b2f6882dc6bd", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 250ml", "qty": 1, "unit_price": 276000.0}]	2026-03-04 12:28:15.652541
147	HCM_Q1	TXN-20260219-00147	2026-02-19 12:33:15.662096+00	\N	EDGE_HCM_Q1_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "score": 0.78}, {"product_id": 150, "product_code": "8f4dc2fd-7d0d-449f-88a4-47cad03d38d2", "name": "T\\u00e3 qu\\u1ea7n Bobby (B\\u1ecbch M40)", "score": 0.86}, {"product_id": 61, "product_code": "cfcd4967-30f5-4502-acbe-6b72adfab32b", "name": "L\\u1ed1c 4 h\\u0169 s\\u1eefa chua \\u0103n co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Lothamilk 100g", "score": 0.64}]	3	t	[{"product_id": 113, "product_code": "e7753b8d-850e-4de8-935e-b4cb3e98063a", "name": "\\u0110\\u01b0\\u1eddng tinh luy\\u1ec7n Bi\\u00ean H\\u00f2a (1kg)", "qty": 2, "unit_price": 17600.0}, {"product_id": 161, "product_code": "d0ce3076-c06f-42af-ba23-221c0ee27198", "name": "Nhang mu\\u1ed7i (H\\u1ed9p 10 khoanh)", "qty": 1, "unit_price": 8000.0}, {"product_id": 160, "product_code": "d560d1cf-83fa-47da-9467-26fa419a73ba", "name": "Thu\\u1ed1c x\\u1ecbt mu\\u1ed7i Raid (600ml)", "qty": 2, "unit_price": 61750.0}, {"product_id": 28, "product_code": "91aed179-28dd-4cb2-96db-44c239795d5f", "name": "Ph\\u1edf b\\u00f2 Vifon g\\u00f3i 90g (c\\u00f3 g\\u00f3i th\\u1ecbt th\\u1eadt)", "qty": 1, "unit_price": 17000.0}]	2026-02-19 12:34:15.662096
148	HCM_Q7	TXN-20260310-00148	2026-03-10 05:49:15.671292+00	\N	EDGE_HCM_Q7_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "score": 0.93}, {"product_id": 15, "product_code": "cebc7811-c35c-4a9d-8b37-854d28b07b22", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g", "score": 0.91}, {"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "score": 0.6}]	3	f	[{"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "qty": 2, "unit_price": 8500.0}, {"product_id": 87, "product_code": "b336ff02-4595-449e-ada1-c89697da7fc2", "name": "Th\\u00f9ng 12 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 1.5 l\\u00edt", "qty": 2, "unit_price": 180000.0}, {"product_id": 155, "product_code": "4dd70e94-850f-406f-a440-c4a161d99325", "name": "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "qty": 1, "unit_price": 35000.0}, {"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "qty": 2, "unit_price": 42000.0}]	2026-03-10 05:56:15.671292
149	HCM_Q7	TXN-20260330-00149	2026-03-30 20:40:15.679855+00	43	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "unisex"}	[{"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.83}, {"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "score": 0.75}, {"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "score": 0.83}, {"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "score": 0.63}]	4	f	[{"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "qty": 2, "unit_price": 22500.0}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "qty": 1, "unit_price": 152000.0}, {"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "qty": 3, "unit_price": 10000.0}, {"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "qty": 2, "unit_price": 34000.0}]	2026-03-30 20:47:15.679855
150	HCM_Q1	TXN-20260228-00150	2026-02-28 15:18:15.69007+00	\N	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "score": 0.69}, {"product_id": 139, "product_code": "efbd986b-4531-4883-afb4-194c9b59a109", "name": "B\\u1ed9t gi\\u1eb7t OMO (T\\u00fai 3kg)", "score": 0.66}, {"product_id": 62, "product_code": "8e6ed997-217f-4dc4-ba92-611c2a6bbd91", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n \\u00edt \\u0111\\u01b0\\u1eddng Nutimilk 100g", "score": 0.96}]	3	f	[{"product_id": 201, "product_code": "e2b8c4e1-00d7-476e-9541-5da23db32d9e", "name": "V\\u1edb ch\\u00e2n nam/n\\u1eef (\\u0110\\u00f4i)", "qty": 3, "unit_price": 12000.0}, {"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "qty": 3, "unit_price": 5000.0}, {"product_id": 130, "product_code": "260fa104-9d28-45a7-bb5e-06b373367221", "name": "B\\u00e1nh quy Cosy (G\\u00f3i 200g)", "qty": 2, "unit_price": 13500.0}, {"product_id": 9, "product_code": "e4c1b87f-da03-460d-970f-cccf1b363bc7", "name": "N\\u01b0\\u1edbc m\\u1eafm Chinsu c\\u00e1 c\\u01a1m bi\\u1ec3n \\u0111\\u00f4ng 25 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 1, "unit_price": 48450.0}, {"product_id": 33, "product_code": "f5833d36-7b7f-4702-937f-8d1286c31a38", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "qty": 2, "unit_price": 270000.0}]	2026-02-28 15:20:15.69007
151	HCM_Q7	TXN-20260224-00151	2026-02-24 20:44:15.700052+00	43	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "unisex"}	[{"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "score": 0.73}, {"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "score": 0.95}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "score": 0.88}, {"product_id": 165, "product_code": "e7082b36-2f83-4c1f-a986-57c985941c24", "name": "T\\u00fai \\u0111\\u1ef1ng r\\u00e1c (Cu\\u1ed9n 3 m\\u00e0u)", "score": 0.88}]	4	f	[{"product_id": 172, "product_code": "17f75c8c-ac61-4e32-8355-90e37f46cc3c", "name": "M\\u00e0ng b\\u1ecdc th\\u1ef1c ph\\u1ea9m (Cu\\u1ed9n)", "qty": 2, "unit_price": 19000.0}, {"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 1, "unit_price": 345000.0}, {"product_id": 171, "product_code": "34b1c04a-0e91-4eaf-ae2d-f379c0324d29", "name": "Pin AAA Panasonic (V\\u1ec9 2 vi\\u00ean)", "qty": 3, "unit_price": 15000.0}, {"product_id": 35, "product_code": "313a33b8-b547-45a7-ae0a-92edf3d8ed09", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng kh\\u00f4ng \\u0111\\u01b0\\u1eddng Vinamilk S\\u1eefa t\\u01b0\\u01a1i 100% 1 l\\u00edt", "qty": 2, "unit_price": 385000.0}]	2026-02-24 20:53:15.700052
152	HCM_Q1	TXN-20260323-00152	2026-03-23 07:12:15.708655+00	48	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 100, "product_code": "46b1b7b5-3a08-4c49-96c5-44e9cf02c72d", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh quy socola Orion Miz 54g", "score": 0.72}, {"product_id": 109, "product_code": "013d09af-48c5-4c50-9709-5b6183c5e8cc", "name": "D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An", "score": 0.74}]	2	f	[{"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "qty": 3, "unit_price": 34000.0}, {"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "qty": 3, "unit_price": 3800.0}, {"product_id": 30, "product_code": "f91639d0-6dfc-4083-a260-a2ad3c65eb41", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf g\\u00e0 \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 65g", "qty": 1, "unit_price": 43000.0}, {"product_id": 147, "product_code": "3518ef51-5bc7-4266-bbc2-6ce2d3acbc53", "name": "Gi\\u1ea5y v\\u1ec7 sinh E'mos (L\\u1ed1c 10)", "qty": 2, "unit_price": 48000.0}, {"product_id": 95, "product_code": "0f57e196-eacf-4d9f-89a6-5fdd236a80c9", "name": "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "qty": 1, "unit_price": 22950.0}]	2026-03-23 07:15:15.708655
153	HCM_Q7	TXN-20260302-00153	2026-03-02 12:51:15.717924+00	19	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 9, "product_code": "e4c1b87f-da03-460d-970f-cccf1b363bc7", "name": "N\\u01b0\\u1edbc m\\u1eafm Chinsu c\\u00e1 c\\u01a1m bi\\u1ec3n \\u0111\\u00f4ng 25 \\u0111\\u1ed9 \\u0111\\u1ea1m", "score": 0.79}, {"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "score": 0.86}, {"product_id": 82, "product_code": "7301020d-0402-4b78-969e-9e061a2a830f", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb d\\u00e2u 12% chai 360ml", "score": 0.7}, {"product_id": 80, "product_code": "77e0bf6d-eb78-4ab7-8a73-d61458d018c6", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb vi\\u1ec7t qu\\u1ea5t 12% chai 360ml", "score": 0.92}]	4	f	[{"product_id": 128, "product_code": "a010e906-1854-42a0-944b-8bcd42f82e55", "name": "Snack Khoai t\\u00e2y O'Star", "qty": 2, "unit_price": 9500.0}, {"product_id": 175, "product_code": "c55a887f-03c5-45e6-9934-5f8a9a007306", "name": "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "qty": 1, "unit_price": 10000.0}]	2026-03-02 13:01:15.717924
154	HCM_Q7	TXN-20260316-00154	2026-03-16 18:46:15.726446+00	\N	EDGE_HCM_Q7_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "score": 0.81}, {"product_id": 41, "product_code": "8c0bd0e0-9c72-4d67-9c29-61b269b31df8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "score": 0.73}, {"product_id": 6, "product_code": "4261ad1a-adce-4554-9710-a9edbdc16f52", "name": "N\\u01b0\\u1edbc ch\\u1ea5m Nam Ng\\u01b0 \\u0110\\u1ec7 Nh\\u1ecb", "score": 0.86}]	3	f	[{"product_id": 40, "product_code": "662bdd0b-b218-4630-b448-3d2702743375", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t TH true MILK 180ml", "qty": 1, "unit_price": 425000.0}, {"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "qty": 1, "unit_price": 5000.0}, {"product_id": 54, "product_code": "c5544e90-b58e-4a17-89af-5f131087703b", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "qty": 2, "unit_price": 34500.0}]	2026-03-16 18:52:15.726446
155	HN_CG	TXN-20260222-00155	2026-02-22 15:41:15.735091+00	36	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "score": 0.78}, {"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "score": 0.94}]	2	t	[{"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "qty": 3, "unit_price": 11500.0}, {"product_id": 34, "product_code": "15458477-33d0-4386-bf74-bc53f8887361", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 2, "unit_price": 337500.0}, {"product_id": 83, "product_code": "a0500366-8dd9-44bc-ad93-6e2f9241f1bf", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng d\\u1ee9a 12.5% chai 360ml", "qty": 2, "unit_price": 38250.0}, {"product_id": 193, "product_code": "057d7a10-7e86-4899-a4d3-2bbb14ab8e8d", "name": "B\\u00eca h\\u1ed3 s\\u01a1 Clearbag (C\\u00e1i)", "qty": 3, "unit_price": 3000.0}]	2026-02-22 15:45:15.735091
156	HN_CG	TXN-20260216-00156	2026-02-16 11:37:15.743281+00	55	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 46, "product_code": "8636600f-9b6f-4cb4-a120-cf70c55c20e6", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "score": 0.97}, {"product_id": 14, "product_code": "7d31d029-8f17-4074-ad5e-96f50b6b9465", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en", "score": 0.85}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.83}]	3	t	[{"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "qty": 1, "unit_price": 5000.0}, {"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "qty": 1, "unit_price": 42000.0}]	2026-02-16 11:40:15.743281
157	HCM_Q7	TXN-20260217-00157	2026-02-17 14:41:15.751853+00	12	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "female"}	[{"product_id": 95, "product_code": "0f57e196-eacf-4d9f-89a6-5fdd236a80c9", "name": "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "score": 0.64}, {"product_id": 3, "product_code": "fb8b76f0-baea-440d-acf3-f80e738a7958", "name": "D\\u1ea7u \\u0103n th\\u01b0\\u1ee3ng h\\u1ea1ng Neptune Light", "score": 0.65}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.84}]	3	f	[{"product_id": 199, "product_code": "78df9983-9047-45ca-8867-aa9f19c6e3d6", "name": "\\u00c1o m\\u01b0a ti\\u1ec7n l\\u1ee3i (C\\u00e1i)", "qty": 2, "unit_price": 10000.0}, {"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "qty": 3, "unit_price": 40000.0}, {"product_id": 204, "product_code": "e03863a3-5056-43ed-af9e-77bdb148f682", "name": "C\\u1ee7 s\\u1ea1c USB 2 c\\u1ed5ng", "qty": 2, "unit_price": 45000.0}, {"product_id": 172, "product_code": "17f75c8c-ac61-4e32-8355-90e37f46cc3c", "name": "M\\u00e0ng b\\u1ecdc th\\u1ef1c ph\\u1ea9m (Cu\\u1ed9n)", "qty": 2, "unit_price": 19000.0}]	2026-02-17 14:50:15.751853
158	HCM_Q7	TXN-20260304-00158	2026-03-04 08:01:15.760677+00	7	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "male"}	[{"product_id": 48, "product_code": "daa15e61-ad90-41f8-aecf-9db0eefdf004", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch v\\u1ecb socola Ovaltine b\\u1ed5 sung canxi 180ml", "score": 0.75}, {"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "score": 0.91}, {"product_id": 180, "product_code": "8f382477-a9b4-44d6-bf2a-59fae61d9166", "name": "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "score": 0.9}, {"product_id": 6, "product_code": "4261ad1a-adce-4554-9710-a9edbdc16f52", "name": "N\\u01b0\\u1edbc ch\\u1ea5m Nam Ng\\u01b0 \\u0110\\u1ec7 Nh\\u1ecb", "score": 0.8}]	4	f	[{"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "qty": 1, "unit_price": 33500.0}, {"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "qty": 1, "unit_price": 35500.0}, {"product_id": 124, "product_code": "4603c6b9-3f0e-4455-9c80-afad12742d51", "name": "N\\u01b0\\u1edbc su\\u1ed1i Aquafina (500ml)", "qty": 2, "unit_price": 4750.0}, {"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "qty": 1, "unit_price": 35000.0}, {"product_id": 180, "product_code": "8f382477-a9b4-44d6-bf2a-59fae61d9166", "name": "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "qty": 3, "unit_price": 19000.0}]	2026-03-04 08:03:15.760677
159	HCM_Q1	TXN-20260223-00159	2026-02-23 10:49:15.768848+00	29	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "unisex"}	[{"product_id": 22, "product_code": "4f92b81a-203d-4ec7-b261-f1ffbe9b5ec4", "name": "M\\u00ec x\\u00e0o kh\\u00f4 Indomie Mi Goreng v\\u1ecb \\u0111\\u1eb7c bi\\u1ec7t g\\u00f3i 85g", "score": 0.79}, {"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.74}]	2	t	[{"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 1, "unit_price": 345000.0}, {"product_id": 11, "product_code": "c657b334-1d73-44af-b7cc-74d5d5bd1efa", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi \\u0111\\u1eadm \\u0111\\u1eb7c", "qty": 1, "unit_price": 35000.0}, {"product_id": 33, "product_code": "f5833d36-7b7f-4702-937f-8d1286c31a38", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "qty": 3, "unit_price": 270000.0}]	2026-02-23 10:58:15.768848
160	HCM_Q1	TXN-20260322-00160	2026-03-22 23:04:15.777513+00	34	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "unisex"}	[{"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "score": 0.68}, {"product_id": 138, "product_code": "8e13d676-f7e9-477f-940b-813f80469993", "name": "S\\u1eefa t\\u1eafm Lifebuoy (Chai 850g)", "score": 0.64}, {"product_id": 131, "product_code": "596df514-3b1f-463c-92f3-fdfb93e41684", "name": "Ng\\u0169 c\\u1ed1c dinh d\\u01b0\\u1ee1ng (G\\u00f3i 500g)", "score": 0.91}]	3	f	[{"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "qty": 3, "unit_price": 68000.0}, {"product_id": 137, "product_code": "f0cac878-618a-41d5-9319-8b85e8c0fc27", "name": "D\\u1ea7u g\\u1ed9i Clear Men (Chai 630g)", "qty": 2, "unit_price": 135000.0}, {"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "qty": 3, "unit_price": 5000.0}]	2026-03-22 23:08:15.777513
161	HCM_Q1	TXN-20260304-00161	2026-03-04 14:55:15.785622+00	14	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 66, "product_code": "59989980-7fbb-4c6a-bf32-5d2cb1fa21c5", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Happy Star Vinamilk 100g", "score": 0.76}, {"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "score": 0.86}]	2	t	[{"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "qty": 2, "unit_price": 17850.0}, {"product_id": 72, "product_code": "ecb6b5c5-539c-4c4a-89a3-ad676f69c353", "name": "Th\\u00f9ng 24 lon Bia S\\u00e0i G\\u00f2n Lager 330ml", "qty": 2, "unit_price": 206400.0}, {"product_id": 33, "product_code": "f5833d36-7b7f-4702-937f-8d1286c31a38", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "qty": 2, "unit_price": 270000.0}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 3, "unit_price": 6800.0}, {"product_id": 160, "product_code": "d560d1cf-83fa-47da-9467-26fa419a73ba", "name": "Thu\\u1ed1c x\\u1ecbt mu\\u1ed7i Raid (600ml)", "qty": 1, "unit_price": 61750.0}]	2026-03-04 15:04:15.785622
162	HN_CG	TXN-20260304-00162	2026-03-04 05:34:15.793815+00	37	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 141, "product_code": "0b4a4b09-46ec-4a6b-bc41-df4393645a3e", "name": "N\\u01b0\\u1edbc x\\u1ea3 v\\u1ea3i Comfort (T\\u00fai 1.6L)", "score": 0.84}, {"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "score": 0.74}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "score": 0.73}, {"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.7}]	4	f	[{"product_id": 155, "product_code": "4dd70e94-850f-406f-a440-c4a161d99325", "name": "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "qty": 3, "unit_price": 35000.0}, {"product_id": 42, "product_code": "13cbc909-c57c-4c13-8304-1abb2e7d16e6", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "qty": 1, "unit_price": 386750.0}, {"product_id": 108, "product_code": "ba0eeecc-e4ce-4bd7-b4f0-91117d028872", "name": "Th\\u00f9ng M\\u00ec 3 Mi\\u1ec1n (30 g\\u00f3i)", "qty": 1, "unit_price": 85000.0}, {"product_id": 40, "product_code": "662bdd0b-b218-4630-b448-3d2702743375", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t TH true MILK 180ml", "qty": 2, "unit_price": 425000.0}, {"product_id": 81, "product_code": "1485f5ea-a1a9-4383-98c4-338a415c5e3d", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb \\u0111\\u00e0o 12% chai 360ml", "qty": 1, "unit_price": 42750.0}]	2026-03-04 05:38:15.793815
163	HCM_Q1	TXN-20260225-00163	2026-02-25 17:33:15.80235+00	\N	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.87}, {"product_id": 136, "product_code": "53ec6e96-b534-42e0-a986-9d6d2d36e86d", "name": "D\\u1ea7u g\\u1ed9i Sunsilk (Chai 650g)", "score": 0.93}, {"product_id": 90, "product_code": "61c35ff1-5a92-4568-9870-e345bc73a24c", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml", "score": 0.81}]	3	f	[{"product_id": 45, "product_code": "70aecc30-273a-4640-ae9e-bf45c96ba51b", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng lof Kun 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 2, "unit_price": 376000.0}]	2026-02-25 17:43:15.80235
164	HCM_Q7	TXN-20260214-00164	2026-02-14 12:47:15.811136+00	9	EDGE_HCM_Q7_01	{"age_group": "25_34", "gender": "male"}	[{"product_id": 14, "product_code": "7d31d029-8f17-4074-ad5e-96f50b6b9465", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en", "score": 0.97}, {"product_id": 186, "product_code": "da5a3390-cf73-4a9f-bffc-f6e02a0905b2", "name": "B\\u00fat bi Thi\\u00ean Long (C\\u00e2y)", "score": 0.87}, {"product_id": 164, "product_code": "5576682c-00ee-4aab-8888-3526e2bf7626", "name": "Bao tay cao su (\\u0110\\u00f4i)", "score": 0.69}]	3	f	[{"product_id": 3, "product_code": "fb8b76f0-baea-440d-acf3-f80e738a7958", "name": "D\\u1ea7u \\u0103n th\\u01b0\\u1ee3ng h\\u1ea1ng Neptune Light", "qty": 1, "unit_price": 62100.0}, {"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "qty": 1, "unit_price": 33250.0}, {"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "qty": 2, "unit_price": 22500.0}]	2026-02-14 12:57:15.811136
165	HCM_Q7	TXN-20260312-00165	2026-03-12 03:41:15.818135+00	28	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 43, "product_code": "d4bfaf6c-3b76-40b5-b6d1-ff43f5cd2555", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng v\\u1ecb t\\u1ef1 nhi\\u00ean TH true MILK Hilo 180ml", "score": 0.62}, {"product_id": 148, "product_code": "d6f2920e-e16a-4096-8159-a938f4b8ce59", "name": "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "score": 0.88}]	2	f	[{"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "qty": 2, "unit_price": 5000.0}, {"product_id": 59, "product_code": "b9c6ad3b-cba2-4de1-96f6-b27fe38a368f", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "qty": 1, "unit_price": 24650.0}, {"product_id": 79, "product_code": "dcf4b890-c91e-4ef3-bf6e-b4433d191182", "name": "Bia Corona Extra chai 250ml", "qty": 3, "unit_price": 31000.0}, {"product_id": 163, "product_code": "5acdac1a-898e-4a9f-8acd-f8590ce29d7b", "name": "C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)", "qty": 1, "unit_price": 12000.0}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "qty": 1, "unit_price": 250000.0}]	2026-03-12 03:50:15.818135
166	HN_CG	TXN-20260318-00166	2026-03-18 18:30:15.827304+00	33	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "score": 0.62}, {"product_id": 136, "product_code": "53ec6e96-b534-42e0-a986-9d6d2d36e86d", "name": "D\\u1ea7u g\\u1ed9i Sunsilk (Chai 650g)", "score": 0.77}, {"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "score": 0.66}, {"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "score": 0.95}]	4	t	[{"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "qty": 3, "unit_price": 12000.0}, {"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 2, "unit_price": 345000.0}, {"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "qty": 3, "unit_price": 39000.0}, {"product_id": 4, "product_code": "2552366a-29a2-46a3-943a-3d8fb45b3fad", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "qty": 3, "unit_price": 59000.0}, {"product_id": 158, "product_code": "8526f078-cb9e-4c78-ae7a-ab1526ddda7d", "name": "N\\u01b0\\u1edbc r\\u1eeda tay kh\\u00f4 (Chai 100ml)", "qty": 3, "unit_price": 30000.0}]	2026-03-18 18:39:15.827304
167	HN_CG	TXN-20260324-00167	2026-03-24 06:36:15.836466+00	\N	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 76, "product_code": "aa017cb5-b496-42a5-9417-beec7b243112", "name": "Th\\u00f9ng 12 lon bia Hoegaarden Peach v\\u1ecb \\u0111\\u00e0o 500ml", "score": 0.6}, {"product_id": 68, "product_code": "5d22b162-c9c6-4540-ab8a-ff709f7148e3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa h\\u01b0\\u01a1ng vani Hoff 55g", "score": 0.84}, {"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "score": 0.75}]	3	t	[{"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "qty": 3, "unit_price": 28500.0}, {"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "qty": 1, "unit_price": 65000.0}, {"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 3, "unit_price": 355000.0}, {"product_id": 96, "product_code": "a903b525-93ec-4602-bf74-099d44d3ea67", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola h\\u01b0\\u01a1ng vani Gery Crunch Roll g\\u00f3i 23g", "qty": 1, "unit_price": 5000.0}]	2026-03-24 06:41:15.836466
168	HN_CG	TXN-20260308-00168	2026-03-08 18:25:15.844024+00	23	EDGE_HN_CG_01	{"age_group": "45_54", "gender": "female"}	[{"product_id": 111, "product_code": "39db55d0-6784-4457-900f-d85d7b17e783", "name": "H\\u1ea1t n\\u00eam Knorr (400g)", "score": 0.68}, {"product_id": 126, "product_code": "d487390c-5ffd-47eb-b891-e9feeaeb0830", "name": "Bia Tiger N\\u00e2u (Lon 330ml)", "score": 0.8}]	2	t	[{"product_id": 2, "product_code": "76e07498-8366-4687-a82e-2a47ecd1e994", "name": "D\\u1ea7u th\\u1ef1c v\\u1eadt tinh luy\\u1ec7n C\\u00e1i L\\u00e2n", "qty": 2, "unit_price": 39100.0}]	2026-03-08 18:28:15.844024
169	HN_CG	TXN-20260319-00169	2026-03-19 23:44:15.852405+00	26	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 42, "product_code": "13cbc909-c57c-4c13-8304-1abb2e7d16e6", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "score": 0.88}, {"product_id": 36, "product_code": "6ea649b0-f9e4-44cb-9fb9-768d1889cdf6", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "score": 0.6}, {"product_id": 91, "product_code": "845e5e02-35a6-498e-9420-f6d30ae72b04", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Coca Cola 320ml", "score": 0.94}]	3	f	[{"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "qty": 2, "unit_price": 349000.0}, {"product_id": 94, "product_code": "d1b9db4c-7740-417c-9d54-b450251614c9", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml", "qty": 1, "unit_price": 10000.0}, {"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "qty": 2, "unit_price": 42000.0}]	2026-03-19 23:48:15.852405
170	HCM_Q7	TXN-20260228-00170	2026-02-28 20:15:15.859426+00	\N	EDGE_HCM_Q7_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "score": 0.65}, {"product_id": 175, "product_code": "c55a887f-03c5-45e6-9934-5f8a9a007306", "name": "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "score": 0.89}, {"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "score": 0.9}]	3	f	[{"product_id": 171, "product_code": "34b1c04a-0e91-4eaf-ae2d-f379c0324d29", "name": "Pin AAA Panasonic (V\\u1ec9 2 vi\\u00ean)", "qty": 1, "unit_price": 15000.0}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "qty": 2, "unit_price": 298000.0}]	2026-02-28 20:22:15.859426
171	HCM_Q1	TXN-20260310-00171	2026-03-10 03:52:15.867702+00	50	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 73, "product_code": "c57b5193-7c6a-4e72-be5f-bf08951cd0ec", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "score": 0.89}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "score": 0.69}, {"product_id": 22, "product_code": "4f92b81a-203d-4ec7-b261-f1ffbe9b5ec4", "name": "M\\u00ec x\\u00e0o kh\\u00f4 Indomie Mi Goreng v\\u1ecb \\u0111\\u1eb7c bi\\u1ec7t g\\u00f3i 85g", "score": 0.66}]	3	t	[{"product_id": 14, "product_code": "7d31d029-8f17-4074-ad5e-96f50b6b9465", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en", "qty": 3, "unit_price": 41000.0}, {"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "qty": 1, "unit_price": 4750.0}]	2026-03-10 04:01:15.867702
172	HCM_Q7	TXN-20260324-00172	2026-03-24 18:50:15.87525+00	28	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "score": 0.65}, {"product_id": 163, "product_code": "5acdac1a-898e-4a9f-8acd-f8590ce29d7b", "name": "C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)", "score": 0.75}, {"product_id": 39, "product_code": "0e3740f8-9d6f-4f7b-b1bb-3b719c18c93b", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "score": 0.7}, {"product_id": 59, "product_code": "b9c6ad3b-cba2-4de1-96f6-b27fe38a368f", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "score": 0.67}]	4	t	[{"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 3, "unit_price": 52000.0}, {"product_id": 181, "product_code": "e483f862-1cbe-45fd-bdb1-169e28072fc2", "name": "B\\u1eadt l\\u1eeda gas", "qty": 3, "unit_price": 3000.0}]	2026-03-24 18:53:15.87525
173	HCM_Q1	TXN-20260304-00173	2026-03-04 02:30:15.883431+00	20	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "score": 0.71}, {"product_id": 69, "product_code": "c6db64ee-92ea-4113-8297-a2e94c4f6be6", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa dinh d\\u01b0\\u1ee1ng Gotz 55g", "score": 0.73}, {"product_id": 94, "product_code": "d1b9db4c-7740-417c-9d54-b450251614c9", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml", "score": 0.76}]	3	f	[{"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "qty": 3, "unit_price": 10000.0}, {"product_id": 87, "product_code": "b336ff02-4595-449e-ada1-c89697da7fc2", "name": "Th\\u00f9ng 12 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 1.5 l\\u00edt", "qty": 2, "unit_price": 180000.0}]	2026-03-04 02:36:15.883431
174	HN_CG	TXN-20260320-00174	2026-03-20 08:58:15.891451+00	31	EDGE_HN_CG_01	{"age_group": "25_34", "gender": "female"}	[{"product_id": 4, "product_code": "2552366a-29a2-46a3-943a-3d8fb45b3fad", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "score": 0.93}, {"product_id": 175, "product_code": "c55a887f-03c5-45e6-9934-5f8a9a007306", "name": "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "score": 0.73}, {"product_id": 142, "product_code": "11c60194-88d2-4816-997a-5553a8cb6196", "name": "Kem \\u0111\\u00e1nh r\\u0103ng P/S (180g)", "score": 0.88}, {"product_id": 198, "product_code": "2c790f44-7ee9-4c1d-9170-0f67eaf7e736", "name": "M\\u0169 b\\u1ea3o hi\\u1ec3m n\\u1eeda \\u0111\\u1ea7u", "score": 0.74}]	4	t	[{"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "qty": 2, "unit_price": 8000.0}, {"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "qty": 2, "unit_price": 11500.0}, {"product_id": 111, "product_code": "39db55d0-6784-4457-900f-d85d7b17e783", "name": "H\\u1ea1t n\\u00eam Knorr (400g)", "qty": 2, "unit_price": 30400.0}]	2026-03-20 09:08:15.891451
175	HCM_Q7	TXN-20260221-00175	2026-02-21 14:28:15.900694+00	\N	EDGE_HCM_Q7_01	{"age_group": "35_44", "gender": "female"}	[{"product_id": 181, "product_code": "e483f862-1cbe-45fd-bdb1-169e28072fc2", "name": "B\\u1eadt l\\u1eeda gas", "score": 0.95}, {"product_id": 115, "product_code": "11086cc9-d30a-4145-acaf-8e2084c851f0", "name": "T\\u01b0\\u01a1ng \\u1edbt Chinsu (250g)", "score": 0.63}]	2	f	[{"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "qty": 3, "unit_price": 12000.0}, {"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "qty": 3, "unit_price": 3800.0}]	2026-02-21 14:37:15.900694
176	HCM_Q1	TXN-20260308-00176	2026-03-08 02:56:15.909241+00	46	EDGE_HCM_Q1_01	{"age_group": "45_54", "gender": "male"}	[{"product_id": 135, "product_code": "c7f42ff3-6047-4f08-866c-1b32209e3f90", "name": "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "score": 0.61}, {"product_id": 129, "product_code": "fb1ea21f-cda1-4678-a372-358a68f83a9c", "name": "K\\u1eb9o c\\u1ee9ng Dynamite", "score": 0.83}, {"product_id": 203, "product_code": "cd3322e6-fa79-4ff1-9ec1-017716f5f8af", "name": "C\\u00e1p s\\u1ea1c Android/iPhone", "score": 0.86}]	3	t	[{"product_id": 195, "product_code": "0c817e5a-0d94-4f29-be97-bc218296a244", "name": "Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "qty": 3, "unit_price": 35000.0}, {"product_id": 144, "product_code": "2869b301-5fec-407f-b472-6e72ee034c9f", "name": "N\\u01b0\\u1edbc r\\u1eeda ch\\u00e9n Sunlight (750ml)", "qty": 1, "unit_price": 21250.0}, {"product_id": 89, "product_code": "4362ec25-fdc1-4b2a-9588-6642962e5302", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Pepsi Cola 390ml", "qty": 2, "unit_price": 118000.0}]	2026-03-08 02:59:15.909241
177	HN_CG	TXN-20260321-00177	2026-03-21 02:42:15.919049+00	26	EDGE_HN_CG_01	{"age_group": "18_24", "gender": "unisex"}	[{"product_id": 53, "product_code": "d5b1b057-5bcf-4629-a973-7f8e9c0bca3c", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "score": 0.66}, {"product_id": 48, "product_code": "daa15e61-ad90-41f8-aecf-9db0eefdf004", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch v\\u1ecb socola Ovaltine b\\u1ed5 sung canxi 180ml", "score": 0.68}, {"product_id": 1, "product_code": "9583297f-78a6-4dfc-84a5-82f214b9e86e", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh tinh luy\\u1ec7n Janbee", "score": 0.86}]	3	t	[{"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "qty": 3, "unit_price": 33250.0}, {"product_id": 137, "product_code": "f0cac878-618a-41d5-9319-8b85e8c0fc27", "name": "D\\u1ea7u g\\u1ed9i Clear Men (Chai 630g)", "qty": 2, "unit_price": 135000.0}, {"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "qty": 3, "unit_price": 22500.0}, {"product_id": 20, "product_code": "d9f8c780-f6e0-408f-9147-1072585bee2d", "name": "M\\u00ec Kokomi 90 t\\u00f4m chua cay g\\u00f3i 90g", "qty": 2, "unit_price": 3600.0}]	2026-03-21 02:51:15.919049
178	HCM_Q7	TXN-20260316-00178	2026-03-16 08:35:15.927181+00	18	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "male"}	[{"product_id": 165, "product_code": "e7082b36-2f83-4c1f-a986-57c985941c24", "name": "T\\u00fai \\u0111\\u1ef1ng r\\u00e1c (Cu\\u1ed9n 3 m\\u00e0u)", "score": 0.98}, {"product_id": 64, "product_code": "0f123724-4435-43b5-a850-de579646313d", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua nha \\u0111am Nutimilk 100g", "score": 0.68}]	2	f	[{"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 3, "unit_price": 170000.0}, {"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 1, "unit_price": 355000.0}, {"product_id": 58, "product_code": "54ee9149-caee-4c90-9f0d-8a89945ffa5f", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p chai 170ml", "qty": 2, "unit_price": 10000.0}, {"product_id": 12, "product_code": "32c195be-0444-4c26-8b09-761cb0b32136", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi thanh d\\u1ecbu", "qty": 1, "unit_price": 22000.0}, {"product_id": 137, "product_code": "f0cac878-618a-41d5-9319-8b85e8c0fc27", "name": "D\\u1ea7u g\\u1ed9i Clear Men (Chai 630g)", "qty": 2, "unit_price": 135000.0}]	2026-03-16 08:37:15.927181
179	HCM_Q7	TXN-20260313-00179	2026-03-13 07:26:15.936419+00	\N	EDGE_HCM_Q7_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 66, "product_code": "59989980-7fbb-4c6a-bf32-5d2cb1fa21c5", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Happy Star Vinamilk 100g", "score": 0.8}, {"product_id": 5, "product_code": "9258ca2f-5e05-4eac-be09-b5a69a4b9cd0", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0 nh\\u00e3n v\\u00e0ng 14 \\u0111\\u1ed9 \\u0111\\u1ea1m", "score": 0.97}]	2	f	[{"product_id": 68, "product_code": "5d22b162-c9c6-4540-ab8a-ff709f7148e3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa h\\u01b0\\u01a1ng vani Hoff 55g", "qty": 3, "unit_price": 65000.0}, {"product_id": 185, "product_code": "cf4e420e-2ede-4a08-8209-0eaa5a110cf5", "name": "D\\u00e2y r\\u00fat nh\\u1ef1a (T\\u00fai 100 s\\u1ee3i)", "qty": 1, "unit_price": 12750.0}, {"product_id": 35, "product_code": "313a33b8-b547-45a7-ae0a-92edf3d8ed09", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng kh\\u00f4ng \\u0111\\u01b0\\u1eddng Vinamilk S\\u1eefa t\\u01b0\\u01a1i 100% 1 l\\u00edt", "qty": 2, "unit_price": 385000.0}, {"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "qty": 1, "unit_price": 12350.0}, {"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 3, "unit_price": 25000.0}]	2026-03-13 07:36:15.936419
180	HCM_Q1	TXN-20260304-00180	2026-03-04 06:25:15.947686+00	38	EDGE_HCM_Q1_01	{"age_group": "18_24", "gender": "female"}	[{"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "score": 0.79}, {"product_id": 146, "product_code": "fd9f259d-1ea9-4994-ae7d-d00f930fcde4", "name": "N\\u01b0\\u1edbc t\\u1ea9y b\\u1ed3n c\\u1ea7u Vim (900ml)", "score": 0.88}]	2	f	[{"product_id": 40, "product_code": "662bdd0b-b218-4630-b448-3d2702743375", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t TH true MILK 180ml", "qty": 2, "unit_price": 425000.0}, {"product_id": 115, "product_code": "11086cc9-d30a-4145-acaf-8e2084c851f0", "name": "T\\u01b0\\u01a1ng \\u1edbt Chinsu (250g)", "qty": 1, "unit_price": 12000.0}, {"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "qty": 2, "unit_price": 20800.0}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 1, "unit_price": 6800.0}]	2026-03-04 06:30:15.947686
\.


--
-- Data for Name: stores; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stores (id, name, address) FROM stdin;
HCM_Q1	Mart Quận 1	12 Nguyễn Huệ, Quận 1, HCM
HCM_Q7	Mart Quận 7	99 Nguyễn Thị Thập, Quận 7, HCM
HN_CG	Mart Cầu Giấy	45 Trần Thái Tông, Cầu Giấy, Hà Nội
\.


--
-- Data for Name: transaction_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transaction_items (id, transaction_id, product_id, qty, unit_price) FROM stdin;
1	1	182	3	10000
2	1	99	2	35500
3	1	187	1	6800
4	1	203	1	40000
5	1	131	2	44000
6	2	118	1	20000
7	3	168	1	45000
8	4	98	2	65000
9	4	18	2	105300
10	4	195	1	35000
11	5	67	1	27000
12	5	135	3	18000
13	5	148	3	16200
14	6	144	3	21250
15	6	164	2	15300
16	6	55	2	37000
17	7	122	3	52000
18	7	205	2	19000
19	7	10	3	8800
20	7	166	2	35000
21	8	8	1	37050
22	8	87	3	180000
23	8	97	3	5000
24	9	24	2	250000
25	9	114	3	5000
26	10	176	2	33250
27	11	70	1	258000
28	12	173	2	25000
29	12	13	1	26000
30	12	28	3	17000
31	12	99	3	35500
32	13	121	2	26000
33	13	60	2	20800
34	13	58	1	10000
35	13	37	3	375000
36	14	84	2	45000
37	15	178	3	40000
38	15	61	3	25500
39	15	45	2	376000
40	15	170	1	10000
41	15	172	3	19000
42	16	194	2	8500
43	16	163	2	12000
44	16	1	3	69500
45	16	38	3	425000
46	16	170	2	10000
47	17	29	3	52000
48	17	73	2	375250
49	17	8	3	37050
50	18	37	1	375000
51	19	183	3	15000
52	19	129	3	8000
53	20	23	3	250000
54	20	63	3	30000
55	20	121	3	26000
56	20	162	3	12000
57	20	190	2	5000
58	21	192	2	18000
59	21	78	3	9600
60	21	187	1	6800
61	21	201	3	12000
62	21	145	1	22000
63	22	152	2	52250
64	22	190	1	5000
65	23	54	2	34500
66	23	148	1	16200
67	24	98	3	65000
68	24	174	3	4750
69	24	81	2	42750
70	24	136	2	88000
71	25	18	3	105300
72	26	155	3	35000
73	27	71	2	355000
74	28	184	3	5000
75	28	67	2	27000
76	28	27	2	10000
77	28	9	1	48450
78	29	123	1	35000
79	29	112	2	32000
80	29	104	3	39000
81	29	187	2	6800
82	30	170	3	10000
83	30	49	2	34000
84	30	77	2	349000
85	30	179	1	12000
86	31	5	2	41500
87	31	10	1	8800
88	31	87	1	180000
89	31	15	3	110200
90	32	45	2	376000
91	33	84	1	45000
92	33	31	1	170000
93	33	176	3	33250
94	33	148	1	16200
95	34	97	1	5000
96	34	200	1	70000
97	34	41	3	355000
98	34	5	3	41500
99	34	125	3	18000
100	35	157	1	25000
101	35	23	3	250000
102	35	161	1	8000
103	35	201	1	12000
104	36	14	1	41000
105	37	51	1	298000
106	37	192	1	18000
107	37	174	1	4750
108	37	84	3	45000
109	38	162	1	12000
110	38	92	1	17850
111	39	23	1	250000
112	39	106	3	152000
113	40	121	3	26000
114	41	192	1	18000
115	41	150	2	210000
116	41	7	3	28000
117	41	117	2	18000
118	41	119	3	32000
119	42	99	1	35500
120	43	83	2	38250
121	43	91	2	52000
122	44	23	1	250000
123	44	21	2	2890
124	44	101	1	260000
125	44	46	3	31500
126	45	60	2	20800
127	46	38	1	425000
128	47	182	3	10000
129	47	9	1	48450
130	47	171	3	15000
131	47	82	2	45000
132	47	89	1	118000
133	48	87	3	180000
134	48	177	3	15000
135	48	29	1	52000
136	48	188	2	3000
137	49	50	3	27000
138	49	126	2	16000
139	49	82	2	45000
140	49	155	1	35000
141	50	151	2	14250
142	50	154	2	65000
143	51	78	3	9600
144	52	127	3	28500
145	52	18	2	105300
146	52	154	2	65000
147	53	108	3	85000
148	53	163	3	12000
149	53	92	1	17850
150	54	200	1	70000
151	54	125	1	18000
152	54	106	3	152000
153	55	36	3	425000
154	55	114	2	5000
155	55	153	1	12000
156	56	194	3	8500
157	56	111	3	30400
158	56	11	3	35000
159	56	51	1	298000
160	57	149	3	16200
161	57	90	3	9000
162	57	91	1	52000
163	58	182	1	10000
164	58	122	1	52000
165	58	94	2	10000
166	58	179	2	12000
167	58	151	2	14250
168	59	117	2	18000
169	59	154	1	65000
170	59	189	3	5000
171	60	27	3	10000
172	60	190	2	5000
173	60	44	1	355000
174	60	17	1	95200
175	60	94	2	10000
176	61	32	1	345000
177	62	170	2	10000
178	63	143	2	14250
179	63	169	2	68000
180	64	174	1	4750
181	64	91	1	52000
182	64	197	2	30000
183	64	73	2	375250
184	64	83	3	38250
185	65	138	3	142500
186	66	43	2	399500
187	66	158	3	30000
188	66	77	1	349000
189	67	167	2	180000
190	68	158	1	30000
191	68	197	2	30000
192	68	112	2	32000
193	68	145	1	22000
194	68	187	1	6800
195	69	50	2	27000
196	69	8	3	37050
197	70	81	1	42750
198	71	85	1	142800
199	71	150	2	210000
200	71	189	1	5000
201	72	72	3	206400
202	72	201	2	12000
203	73	137	1	135000
204	74	184	3	5000
205	74	109	1	48000
206	74	26	2	11500
207	75	183	2	15000
208	75	197	2	30000
209	75	167	2	180000
210	75	196	3	25000
211	75	34	1	337500
212	76	51	2	298000
213	76	68	3	65000
214	76	180	2	19000
215	76	44	1	355000
216	77	154	1	65000
217	77	56	2	35150
218	78	178	3	40000
219	78	102	2	21250
220	78	176	3	33250
221	79	98	3	65000
222	79	78	1	9600
223	79	102	2	21250
224	79	172	1	19000
225	79	95	3	22950
226	80	68	2	65000
227	80	157	1	25000
228	80	195	2	35000
229	81	30	2	43000
230	81	127	2	28500
231	81	11	2	35000
232	81	114	1	5000
233	82	197	1	30000
234	82	147	2	48000
235	82	47	1	33500
236	82	107	2	3600
237	82	20	3	3600
238	83	169	3	68000
239	83	2	3	39100
240	83	85	3	142800
241	83	12	1	22000
242	83	168	1	45000
243	84	100	3	246500
244	84	200	1	70000
245	85	158	1	30000
246	85	48	3	27200
247	85	112	2	32000
248	86	64	3	27900
249	86	134	1	7000
250	86	110	1	42000
251	87	81	3	42750
252	87	151	2	14250
253	87	186	2	3200
254	88	178	2	40000
255	88	104	3	39000
256	88	169	3	68000
257	88	191	2	3800
258	89	49	1	34000
259	89	23	1	250000
260	89	78	1	9600
261	89	198	1	68000
262	89	119	3	32000
263	90	132	3	22500
264	90	152	1	52250
265	90	186	3	3200
266	90	157	1	25000
267	91	130	3	13500
268	91	57	3	10000
269	92	52	2	298000
270	92	41	2	355000
271	93	111	1	30400
272	93	30	2	43000
273	93	159	2	40000
274	94	130	1	13500
275	95	122	1	52000
276	95	88	2	118000
277	96	38	2	425000
278	96	198	2	68000
279	96	3	2	62100
280	96	184	1	5000
281	97	157	3	25000
282	97	38	3	425000
283	97	180	3	19000
284	97	104	3	39000
285	97	115	2	12000
286	98	152	3	52250
287	98	67	1	27000
288	98	62	2	26000
289	98	199	2	10000
290	98	78	3	9600
291	99	173	3	25000
292	99	36	3	425000
293	99	183	1	15000
294	99	97	2	5000
295	99	134	2	7000
296	100	188	3	3000
297	100	107	2	3600
298	100	42	1	386750
299	100	37	3	375000
300	101	78	3	9600
301	101	76	2	445000
302	101	125	1	18000
303	102	122	2	52000
304	102	185	2	12750
305	102	156	3	8000
306	102	34	2	337500
307	103	22	1	5900
308	103	50	2	27000
309	103	159	3	40000
310	103	139	1	125000
311	103	148	1	16200
312	104	136	1	88000
313	105	77	1	349000
314	106	105	3	12350
315	106	17	3	95200
316	106	124	3	4750
317	106	8	1	37050
318	106	163	1	12000
319	107	116	1	30000
320	107	11	1	35000
321	107	1	2	69500
322	107	119	2	32000
323	107	159	3	40000
324	108	157	3	25000
325	108	130	2	13500
326	109	202	3	42500
327	110	175	3	10000
328	110	182	3	10000
329	110	92	2	17850
330	111	129	3	8000
331	111	127	3	28500
332	111	44	3	355000
333	111	142	3	28000
334	111	50	1	27000
335	112	83	1	38250
336	113	189	1	5000
337	114	28	1	17000
338	114	122	2	52000
339	115	15	3	110200
340	115	78	1	9600
341	115	157	3	25000
342	115	161	1	8000
343	116	117	1	18000
344	117	16	2	119000
345	118	14	1	41000
346	118	109	2	48000
347	118	89	1	118000
348	118	51	3	298000
349	118	52	2	298000
350	119	178	1	40000
351	119	59	2	24650
352	120	12	1	22000
353	120	8	2	37050
354	120	51	3	298000
355	121	135	3	18000
356	121	205	1	19000
357	122	203	2	40000
358	122	39	1	330000
359	122	84	3	45000
360	123	122	1	52000
361	123	69	1	34500
362	123	149	1	16200
363	123	103	1	26000
364	124	150	2	210000
365	124	11	2	35000
366	125	26	3	11500
367	125	31	1	170000
368	126	194	1	8500
369	126	168	3	45000
370	126	4	3	59000
371	126	121	1	26000
372	126	132	2	22500
373	127	189	1	5000
374	127	3	2	62100
375	127	128	2	9500
376	128	101	2	260000
377	128	17	1	95200
378	129	18	2	105300
379	129	117	2	18000
380	129	15	1	110200
381	129	95	1	22950
382	129	133	1	12000
383	130	71	2	355000
384	130	52	3	298000
385	130	2	1	39100
386	130	37	3	375000
387	131	188	1	3000
388	131	111	2	30400
389	131	118	3	20000
390	131	99	1	35500
391	131	169	1	68000
392	132	197	3	30000
393	132	200	1	70000
394	132	84	2	45000
395	132	105	1	12350
396	132	116	1	30000
397	133	183	2	15000
398	133	113	1	17600
399	134	183	2	15000
400	134	9	3	48450
401	135	24	2	250000
402	135	5	1	41500
403	136	102	1	21250
404	136	110	1	42000
405	136	31	2	170000
406	136	60	3	20800
407	136	55	2	37000
408	137	183	2	15000
409	138	60	1	20800
410	139	134	2	7000
411	140	126	3	16000
412	141	46	3	31500
413	141	156	1	8000
414	141	64	2	27900
415	141	78	2	9600
416	142	187	2	6800
417	142	45	3	376000
418	142	66	3	25500
419	142	98	2	65000
420	142	119	1	32000
421	143	105	3	12350
422	144	162	3	12000
423	144	181	1	3000
424	144	174	2	4750
425	145	110	3	42000
426	145	65	3	26000
427	146	135	2	18000
428	146	107	1	3600
429	146	168	3	45000
430	146	74	1	276000
431	147	113	2	17600
432	147	161	1	8000
433	147	160	2	61750
434	147	28	1	17000
435	148	194	2	8500
436	148	87	2	180000
437	148	155	1	35000
438	148	110	2	42000
439	149	132	2	22500
440	149	106	1	152000
441	149	170	3	10000
442	149	49	2	34000
443	150	201	3	12000
444	150	184	3	5000
445	150	130	2	13500
446	150	9	1	48450
447	150	33	2	270000
448	151	172	2	19000
449	151	32	1	345000
450	151	171	3	15000
451	151	35	2	385000
452	152	49	3	34000
453	152	191	3	3800
454	152	30	1	43000
455	152	147	2	48000
456	152	95	1	22950
457	153	128	2	9500
458	153	175	1	10000
459	154	40	1	425000
460	154	184	1	5000
461	154	54	2	34500
462	155	25	3	11500
463	155	34	2	337500
464	155	83	2	38250
465	155	193	3	3000
466	156	97	1	5000
467	156	110	1	42000
468	157	199	2	10000
469	157	178	3	40000
470	157	204	2	45000
471	157	172	2	19000
472	158	47	1	33500
473	158	99	1	35500
474	158	124	2	4750
475	158	166	1	35000
476	158	180	3	19000
477	159	32	1	345000
478	159	11	1	35000
479	159	33	3	270000
480	160	169	3	68000
481	160	137	2	135000
482	160	114	3	5000
483	161	92	2	17850
484	161	72	2	206400
485	161	33	2	270000
486	161	187	3	6800
487	161	160	1	61750
488	162	155	3	35000
489	162	42	1	386750
490	162	108	1	85000
491	162	40	2	425000
492	162	81	1	42750
493	163	45	2	376000
494	164	3	1	62100
495	164	176	1	33250
496	164	132	2	22500
497	165	184	2	5000
498	165	59	1	24650
499	165	79	3	31000
500	165	163	1	12000
501	165	23	1	250000
502	166	179	3	12000
503	166	32	2	345000
504	166	104	3	39000
505	166	4	3	59000
506	166	158	3	30000
507	167	127	3	28500
508	167	98	1	65000
509	167	44	3	355000
510	167	96	1	5000
511	168	2	2	39100
512	169	77	2	349000
513	169	94	1	10000
514	169	110	2	42000
515	170	171	1	15000
516	170	51	2	298000
517	171	14	3	41000
518	171	174	1	4750
519	172	122	3	52000
520	172	181	3	3000
521	173	57	3	10000
522	173	87	2	180000
523	174	156	2	8000
524	174	26	2	11500
525	174	111	2	30400
526	175	162	3	12000
527	175	191	3	3800
528	176	195	3	35000
529	176	144	1	21250
530	176	89	2	118000
531	177	176	3	33250
532	177	137	2	135000
533	177	132	3	22500
534	177	20	2	3600
535	178	31	3	170000
536	178	44	1	355000
537	178	58	2	10000
538	178	12	1	22000
539	178	137	2	135000
540	179	68	3	65000
541	179	185	1	12750
542	179	35	2	385000
543	179	105	1	12350
544	179	157	3	25000
545	180	40	2	425000
546	180	115	1	12000
547	180	60	2	20800
548	180	187	1	6800
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transactions (id, branch_id, transaction_id, "timestamp", customer_id, device_id, items_data, items_count, total_amount, recommended_items, accepted_recommendations, created_at) FROM stdin;
1	HN_CG	TXN-20260220-00001	2026-02-20 12:15:14.118651+00	6	EDGE_HN_CG_01	[{"product_id": 182, "product_code": "04931d60-d635-4729-8b9e-1171306f235b", "name": "N\\u1ebfn c\\u00e2y (G\\u00f3i 5 c\\u00e2y)", "qty": 3, "unit_price": 10000.0}, {"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "qty": 2, "unit_price": 35500.0}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 1, "unit_price": 6800.0}, {"product_id": 203, "product_code": "cd3322e6-fa79-4ff1-9ec1-017716f5f8af", "name": "C\\u00e1p s\\u1ea1c Android/iPhone", "qty": 1, "unit_price": 40000.0}, {"product_id": 131, "product_code": "596df514-3b1f-463c-92f3-fdfb93e41684", "name": "Ng\\u0169 c\\u1ed1c dinh d\\u01b0\\u1ee1ng (G\\u00f3i 500g)", "qty": 2, "unit_price": 44000.0}]	5	235800	[{"product_id": 39, "product_code": "0e3740f8-9d6f-4f7b-b1bb-3b719c18c93b", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "score": 0.89}, {"product_id": 42, "product_code": "13cbc909-c57c-4c13-8304-1abb2e7d16e6", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "score": 0.62}, {"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "score": 0.72}, {"product_id": 46, "product_code": "8636600f-9b6f-4cb4-a120-cf70c55c20e6", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "score": 0.88}]	f	2026-02-20 12:15:14.118651
2	HCM_Q1	TXN-20260228-00002	2026-02-28 02:05:14.132516+00	17	EDGE_HCM_Q1_01	[{"product_id": 118, "product_code": "071cea0f-3714-449f-b21f-86ddce66fd4d", "name": "C\\u00e1 h\\u1ed9p 3 C\\u00f4 G\\u00e1i", "qty": 1, "unit_price": 20000.0}]	1	20000	[{"product_id": 61, "product_code": "cfcd4967-30f5-4502-acbe-6b72adfab32b", "name": "L\\u1ed1c 4 h\\u0169 s\\u1eefa chua \\u0103n co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Lothamilk 100g", "score": 0.85}, {"product_id": 56, "product_code": "c11379c8-f11b-4bc0-bc6b-32483cb53628", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p 170ml", "score": 0.77}, {"product_id": 151, "product_code": "4e6b1095-a3cb-4d03-b747-0b3080e9a160", "name": "X\\u00e0 b\\u00f4ng c\\u1ee5c X-Men", "score": 0.77}]	f	2026-02-28 02:05:14.132516
3	HN_CG	TXN-20260309-00003	2026-03-09 16:30:14.15531+00	10	EDGE_HN_CG_01	[{"product_id": 168, "product_code": "131a23d6-1d20-4d98-b9dd-2d0eb19e0b54", "name": "B\\u00f3ng \\u0111\\u00e8n LED \\u0110i\\u1ec7n Quang 20W", "qty": 1, "unit_price": 45000.0}]	1	45000	[{"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "score": 0.64}, {"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.98}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "score": 0.66}, {"product_id": 13, "product_code": "2bcfabb7-eedf-4da1-ad8c-f464bb3e5ee6", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Tam Th\\u00e1i T\\u1eed Nh\\u1ea5t Ca s\\u00e1nh \\u0111\\u1eadm", "score": 0.71}]	f	2026-03-09 16:30:14.15531
4	HCM_Q1	TXN-20260304-00004	2026-03-04 00:35:14.165717+00	21	EDGE_HCM_Q1_01	[{"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "qty": 2, "unit_price": 65000.0}, {"product_id": 18, "product_code": "fc0359c0-800a-40c9-8e49-660ab593f7e3", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "qty": 2, "unit_price": 105300.0}, {"product_id": 195, "product_code": "0c817e5a-0d94-4f29-be97-bc218296a244", "name": "Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "qty": 1, "unit_price": 35000.0}]	3	375600	[{"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.8}, {"product_id": 135, "product_code": "c7f42ff3-6047-4f08-866c-1b32209e3f90", "name": "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "score": 0.86}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "score": 0.83}]	t	2026-03-04 00:35:14.165717
5	HN_CG	TXN-20260220-00005	2026-02-20 05:40:14.176984+00	55	EDGE_HN_CG_01	[{"product_id": 67, "product_code": "a67c2aa4-d081-41f2-a440-30d00cd60c5b", "name": "L\\u1ed1c 2 h\\u0169 s\\u01b0\\u0303a chua n\\u00ea\\u0301p c\\u00e2\\u0309m Sa\\u0300i Go\\u0300n Milk 120g", "qty": 1, "unit_price": 27000.0}, {"product_id": 135, "product_code": "c7f42ff3-6047-4f08-866c-1b32209e3f90", "name": "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "qty": 3, "unit_price": 18000.0}, {"product_id": 148, "product_code": "d6f2920e-e16a-4096-8159-a938f4b8ce59", "name": "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "qty": 3, "unit_price": 16200.0}]	3	129600	[{"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "score": 0.94}, {"product_id": 128, "product_code": "a010e906-1854-42a0-944b-8bcd42f82e55", "name": "Snack Khoai t\\u00e2y O'Star", "score": 0.69}, {"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "score": 0.71}, {"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "score": 0.67}]	f	2026-02-20 05:40:14.176984
6	HCM_Q1	TXN-20260330-00006	2026-03-30 21:27:14.188043+00	22	EDGE_HCM_Q1_01	[{"product_id": 144, "product_code": "2869b301-5fec-407f-b472-6e72ee034c9f", "name": "N\\u01b0\\u1edbc r\\u1eeda ch\\u00e9n Sunlight (750ml)", "qty": 3, "unit_price": 21250.0}, {"product_id": 164, "product_code": "5576682c-00ee-4aab-8888-3526e2bf7626", "name": "Bao tay cao su (\\u0110\\u00f4i)", "qty": 2, "unit_price": 15300.0}, {"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "qty": 2, "unit_price": 37000.0}]	3	168350	[{"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "score": 0.72}, {"product_id": 130, "product_code": "260fa104-9d28-45a7-bb5e-06b373367221", "name": "B\\u00e1nh quy Cosy (G\\u00f3i 200g)", "score": 0.6}, {"product_id": 141, "product_code": "0b4a4b09-46ec-4a6b-bc41-df4393645a3e", "name": "N\\u01b0\\u1edbc x\\u1ea3 v\\u1ea3i Comfort (T\\u00fai 1.6L)", "score": 0.86}]	f	2026-03-30 21:27:14.188043
7	HCM_Q1	TXN-20260323-00007	2026-03-23 02:30:14.20472+00	22	EDGE_HCM_Q1_01	[{"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 3, "unit_price": 52000.0}, {"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "qty": 2, "unit_price": 19000.0}, {"product_id": 10, "product_code": "63a338bb-de9f-45cb-b283-d0abab06015d", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Nh\\u1ecb Ca Tam Th\\u00e1i T\\u1eed chai", "qty": 3, "unit_price": 8800.0}, {"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "qty": 2, "unit_price": 35000.0}]	4	290400	[{"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "score": 0.71}, {"product_id": 15, "product_code": "cebc7811-c35c-4a9d-8b37-854d28b07b22", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g", "score": 0.88}, {"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "score": 0.72}]	f	2026-03-23 02:30:14.20472
8	HCM_Q7	TXN-20260218-00008	2026-02-18 23:46:14.217184+00	\N	EDGE_HCM_Q7_01	[{"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 1, "unit_price": 37050.0}, {"product_id": 87, "product_code": "b336ff02-4595-449e-ada1-c89697da7fc2", "name": "Th\\u00f9ng 12 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 1.5 l\\u00edt", "qty": 3, "unit_price": 180000.0}, {"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "qty": 3, "unit_price": 5000.0}]	3	592050	[{"product_id": 30, "product_code": "f91639d0-6dfc-4083-a260-a2ad3c65eb41", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf g\\u00e0 \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 65g", "score": 0.87}, {"product_id": 201, "product_code": "e2b8c4e1-00d7-476e-9541-5da23db32d9e", "name": "V\\u1edb ch\\u00e2n nam/n\\u1eef (\\u0110\\u00f4i)", "score": 0.72}, {"product_id": 193, "product_code": "057d7a10-7e86-4899-a4d3-2bbb14ab8e8d", "name": "B\\u00eca h\\u1ed3 s\\u01a1 Clearbag (C\\u00e1i)", "score": 0.61}, {"product_id": 79, "product_code": "dcf4b890-c91e-4ef3-bf6e-b4433d191182", "name": "Bia Corona Extra chai 250ml", "score": 0.76}]	t	2026-02-18 23:46:14.217184
9	HCM_Q1	TXN-20260227-00009	2026-02-27 16:48:14.227101+00	3	EDGE_HCM_Q1_01	[{"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "qty": 2, "unit_price": 250000.0}, {"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "qty": 3, "unit_price": 5000.0}]	2	515000	[{"product_id": 124, "product_code": "4603c6b9-3f0e-4455-9c80-afad12742d51", "name": "N\\u01b0\\u1edbc su\\u1ed1i Aquafina (500ml)", "score": 0.72}, {"product_id": 188, "product_code": "4a5f7c93-02f6-48e0-bcb4-a1c7ae3aec53", "name": "B\\u00fat ch\\u00ec g\\u1ed7 2B", "score": 0.72}, {"product_id": 135, "product_code": "c7f42ff3-6047-4f08-866c-1b32209e3f90", "name": "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "score": 0.89}]	t	2026-02-27 16:48:14.227101
10	HN_CG	TXN-20260221-00010	2026-02-21 15:18:14.23688+00	60	EDGE_HN_CG_01	[{"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "qty": 2, "unit_price": 33250.0}]	1	66500	[{"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "score": 0.85}, {"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "score": 0.72}]	f	2026-02-21 15:18:14.23688
11	HCM_Q7	TXN-20260322-00011	2026-03-22 12:22:14.24567+00	43	EDGE_HCM_Q7_01	[{"product_id": 70, "product_code": "83bab65c-5e02-45a8-936d-58eaa4e206a2", "name": "Th\\u00f9ng 24 lon Bia Tiger lon 250ml", "qty": 1, "unit_price": 258000.0}]	1	258000	[{"product_id": 144, "product_code": "2869b301-5fec-407f-b472-6e72ee034c9f", "name": "N\\u01b0\\u1edbc r\\u1eeda ch\\u00e9n Sunlight (750ml)", "score": 0.81}, {"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "score": 0.81}, {"product_id": 27, "product_code": "b048d361-49e5-4b05-8560-1b82458ef15b", "name": "B\\u00fan c\\u00e1 cay H\\u1eb1ng Nga g\\u00f3i 70g", "score": 0.7}, {"product_id": 53, "product_code": "d5b1b057-5bcf-4629-a973-7f8e9c0bca3c", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "score": 0.96}]	t	2026-03-22 12:22:14.24567
12	HCM_Q7	TXN-20260328-00012	2026-03-28 15:12:14.254948+00	2	EDGE_HCM_Q7_01	[{"product_id": 173, "product_code": "78a22c2f-8513-49ba-95df-227bbb48543e", "name": "Gi\\u1ea5y b\\u1ea1c n\\u01b0\\u1edbng (Cu\\u1ed9n)", "qty": 2, "unit_price": 25000.0}, {"product_id": 13, "product_code": "2bcfabb7-eedf-4da1-ad8c-f464bb3e5ee6", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Tam Th\\u00e1i T\\u1eed Nh\\u1ea5t Ca s\\u00e1nh \\u0111\\u1eadm", "qty": 1, "unit_price": 26000.0}, {"product_id": 28, "product_code": "91aed179-28dd-4cb2-96db-44c239795d5f", "name": "Ph\\u1edf b\\u00f2 Vifon g\\u00f3i 90g (c\\u00f3 g\\u00f3i th\\u1ecbt th\\u1eadt)", "qty": 3, "unit_price": 17000.0}, {"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "qty": 3, "unit_price": 35500.0}]	4	233500	[{"product_id": 177, "product_code": "991f1b12-1dc2-498a-83bb-75bf860ad56b", "name": "K\\u1eb9p qu\\u1ea7n \\u00e1o (V\\u1ec9 20)", "score": 0.74}, {"product_id": 180, "product_code": "8f382477-a9b4-44d6-bf2a-59fae61d9166", "name": "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "score": 0.73}, {"product_id": 115, "product_code": "11086cc9-d30a-4145-acaf-8e2084c851f0", "name": "T\\u01b0\\u01a1ng \\u1edbt Chinsu (250g)", "score": 0.68}, {"product_id": 158, "product_code": "8526f078-cb9e-4c78-ae7a-ab1526ddda7d", "name": "N\\u01b0\\u1edbc r\\u1eeda tay kh\\u00f4 (Chai 100ml)", "score": 0.89}]	f	2026-03-28 15:12:14.254948
13	HN_CG	TXN-20260220-00013	2026-02-20 08:41:14.262969+00	20	EDGE_HN_CG_01	[{"product_id": 121, "product_code": "827e4a51-3225-4f53-a04f-e03b0e5b9f8d", "name": "S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "qty": 2, "unit_price": 26000.0}, {"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "qty": 2, "unit_price": 20800.0}, {"product_id": 58, "product_code": "54ee9149-caee-4c90-9f0d-8a89945ffa5f", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p chai 170ml", "qty": 1, "unit_price": 10000.0}, {"product_id": 37, "product_code": "6f831c1e-17cc-4ea1-848a-33cbc4c7ec9a", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 3, "unit_price": 375000.0}]	4	1228600	[{"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "score": 0.79}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.62}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "score": 0.64}]	f	2026-02-20 08:41:14.262969
14	HN_CG	TXN-20260223-00014	2026-02-23 21:35:14.272251+00	26	EDGE_HN_CG_01	[{"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "qty": 2, "unit_price": 45000.0}]	1	90000	[{"product_id": 152, "product_code": "a544d61d-edb8-4b54-ad19-8f4745d8307a", "name": "S\\u1eefa r\\u1eeda m\\u1eb7t Acnes (100g)", "score": 0.84}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "score": 0.81}, {"product_id": 62, "product_code": "8e6ed997-217f-4dc4-ba92-611c2a6bbd91", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n \\u00edt \\u0111\\u01b0\\u1eddng Nutimilk 100g", "score": 0.97}]	f	2026-02-23 21:35:14.272251
15	HCM_Q7	TXN-20260326-00015	2026-03-26 17:40:14.283835+00	22	EDGE_HCM_Q7_01	[{"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "qty": 3, "unit_price": 40000.0}, {"product_id": 61, "product_code": "cfcd4967-30f5-4502-acbe-6b72adfab32b", "name": "L\\u1ed1c 4 h\\u0169 s\\u1eefa chua \\u0103n co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Lothamilk 100g", "qty": 3, "unit_price": 25500.0}, {"product_id": 45, "product_code": "70aecc30-273a-4640-ae9e-bf45c96ba51b", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng lof Kun 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 2, "unit_price": 376000.0}, {"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "qty": 1, "unit_price": 10000.0}, {"product_id": 172, "product_code": "17f75c8c-ac61-4e32-8355-90e37f46cc3c", "name": "M\\u00e0ng b\\u1ecdc th\\u1ef1c ph\\u1ea9m (Cu\\u1ed9n)", "qty": 3, "unit_price": 19000.0}]	5	1015500	[{"product_id": 143, "product_code": "a3a7acbd-4cf2-4f56-9930-63c15fc00ecc", "name": "B\\u00e0n ch\\u1ea3i \\u0111\\u00e1nh r\\u0103ng Colgate", "score": 0.67}, {"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.96}, {"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "score": 0.63}]	f	2026-03-26 17:40:14.283835
16	HCM_Q1	TXN-20260322-00016	2026-03-22 03:05:14.294506+00	\N	EDGE_HCM_Q1_01	[{"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "qty": 2, "unit_price": 8500.0}, {"product_id": 163, "product_code": "5acdac1a-898e-4a9f-8acd-f8590ce29d7b", "name": "C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)", "qty": 2, "unit_price": 12000.0}, {"product_id": 1, "product_code": "9583297f-78a6-4dfc-84a5-82f214b9e86e", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh tinh luy\\u1ec7n Janbee", "qty": 3, "unit_price": 69500.0}, {"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "qty": 3, "unit_price": 425000.0}, {"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "qty": 2, "unit_price": 10000.0}]	5	1544500	[{"product_id": 82, "product_code": "7301020d-0402-4b78-969e-9e061a2a830f", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb d\\u00e2u 12% chai 360ml", "score": 0.95}, {"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "score": 0.72}, {"product_id": 146, "product_code": "fd9f259d-1ea9-4994-ae7d-d00f930fcde4", "name": "N\\u01b0\\u1edbc t\\u1ea9y b\\u1ed3n c\\u1ea7u Vim (900ml)", "score": 0.96}, {"product_id": 204, "product_code": "e03863a3-5056-43ed-af9e-77bdb148f682", "name": "C\\u1ee7 s\\u1ea1c USB 2 c\\u1ed5ng", "score": 0.77}]	t	2026-03-22 03:05:14.294506
17	HCM_Q7	TXN-20260316-00017	2026-03-16 03:55:14.305518+00	36	EDGE_HCM_Q7_01	[{"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "qty": 3, "unit_price": 52000.0}, {"product_id": 73, "product_code": "c57b5193-7c6a-4e72-be5f-bf08951cd0ec", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "qty": 2, "unit_price": 375250.0}, {"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 3, "unit_price": 37050.0}]	3	1017650	[{"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "score": 0.81}, {"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "score": 0.85}, {"product_id": 112, "product_code": "26a9aea3-5f05-45b5-81af-801b4e2e9d24", "name": "B\\u1ed9t ng\\u1ecdt Ajinomoto (454g)", "score": 0.78}]	t	2026-03-16 03:55:14.305518
18	HN_CG	TXN-20260227-00018	2026-02-27 20:12:14.315636+00	5	EDGE_HN_CG_01	[{"product_id": 37, "product_code": "6f831c1e-17cc-4ea1-848a-33cbc4c7ec9a", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 1, "unit_price": 375000.0}]	1	375000	[{"product_id": 107, "product_code": "950bc1a0-a654-4c1f-937a-91b5753c75c0", "name": "M\\u00ec H\\u1ea3o H\\u1ea3o T\\u00f4m Chua Cay", "score": 0.83}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "score": 0.76}, {"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "score": 0.67}, {"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "score": 0.79}]	t	2026-02-27 20:12:14.315636
19	HN_CG	TXN-20260314-00019	2026-03-14 03:40:14.324943+00	55	EDGE_HN_CG_01	[{"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "qty": 3, "unit_price": 15000.0}, {"product_id": 129, "product_code": "fb1ea21f-cda1-4678-a372-358a68f83a9c", "name": "K\\u1eb9o c\\u1ee9ng Dynamite", "qty": 3, "unit_price": 8000.0}]	2	69000	[{"product_id": 146, "product_code": "fd9f259d-1ea9-4994-ae7d-d00f930fcde4", "name": "N\\u01b0\\u1edbc t\\u1ea9y b\\u1ed3n c\\u1ea7u Vim (900ml)", "score": 0.87}, {"product_id": 124, "product_code": "4603c6b9-3f0e-4455-9c80-afad12742d51", "name": "N\\u01b0\\u1edbc su\\u1ed1i Aquafina (500ml)", "score": 0.64}]	t	2026-03-14 03:40:14.324943
20	HCM_Q7	TXN-20260216-00020	2026-02-16 20:35:14.334038+00	34	EDGE_HCM_Q7_01	[{"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "qty": 3, "unit_price": 250000.0}, {"product_id": 63, "product_code": "ffab1e43-67a3-4455-b9f5-ece65ebd4ebb", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n nha \\u0111am Lothamilk 100g", "qty": 3, "unit_price": 30000.0}, {"product_id": 121, "product_code": "827e4a51-3225-4f53-a04f-e03b0e5b9f8d", "name": "S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "qty": 3, "unit_price": 26000.0}, {"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "qty": 3, "unit_price": 12000.0}, {"product_id": 190, "product_code": "91a2bcb3-d18b-47dc-ab24-5af040967bf2", "name": "Th\\u01b0\\u1edbc k\\u1ebb 20cm", "qty": 2, "unit_price": 5000.0}]	5	964000	[{"product_id": 137, "product_code": "f0cac878-618a-41d5-9319-8b85e8c0fc27", "name": "D\\u1ea7u g\\u1ed9i Clear Men (Chai 630g)", "score": 0.78}, {"product_id": 200, "product_code": "44e0b85c-6165-439b-84b4-6f85374c19e1", "name": "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "score": 0.79}, {"product_id": 3, "product_code": "fb8b76f0-baea-440d-acf3-f80e738a7958", "name": "D\\u1ea7u \\u0103n th\\u01b0\\u1ee3ng h\\u1ea1ng Neptune Light", "score": 0.78}]	f	2026-02-16 20:35:14.334038
21	HCM_Q7	TXN-20260315-00021	2026-03-15 15:59:14.342716+00	60	EDGE_HCM_Q7_01	[{"product_id": 192, "product_code": "b812638a-f73d-4a60-9695-eac88da8a809", "name": "B\\u1ea5m kim s\\u1ed1 10 (C\\u00e1i)", "qty": 2, "unit_price": 18000.0}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 3, "unit_price": 9600.0}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 1, "unit_price": 6800.0}, {"product_id": 201, "product_code": "e2b8c4e1-00d7-476e-9541-5da23db32d9e", "name": "V\\u1edb ch\\u00e2n nam/n\\u1eef (\\u0110\\u00f4i)", "qty": 3, "unit_price": 12000.0}, {"product_id": 145, "product_code": "3f023ad8-02a4-4e95-8ec6-553c622e7d9d", "name": "N\\u01b0\\u1edbc lau s\\u00e0n Gift (1 L\\u00edt)", "qty": 1, "unit_price": 22000.0}]	5	129600	[{"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "score": 0.71}, {"product_id": 160, "product_code": "d560d1cf-83fa-47da-9467-26fa419a73ba", "name": "Thu\\u1ed1c x\\u1ecbt mu\\u1ed7i Raid (600ml)", "score": 0.63}, {"product_id": 7, "product_code": "271cc8ca-e37c-4277-90dc-36f3b624ac9a", "name": "N\\u01b0\\u1edbc ch\\u1ea5m chua ng\\u1ecdt Nam Ng\\u01b0 \\u1edbt t\\u1ecfi L\\u00fd S\\u01a1n", "score": 0.79}]	f	2026-03-15 15:59:14.342716
22	HCM_Q7	TXN-20260321-00022	2026-03-21 20:11:14.3519+00	39	EDGE_HCM_Q7_01	[{"product_id": 152, "product_code": "a544d61d-edb8-4b54-ad19-8f4745d8307a", "name": "S\\u1eefa r\\u1eeda m\\u1eb7t Acnes (100g)", "qty": 2, "unit_price": 52250.0}, {"product_id": 190, "product_code": "91a2bcb3-d18b-47dc-ab24-5af040967bf2", "name": "Th\\u01b0\\u1edbc k\\u1ebb 20cm", "qty": 1, "unit_price": 5000.0}]	2	109500	[{"product_id": 61, "product_code": "cfcd4967-30f5-4502-acbe-6b72adfab32b", "name": "L\\u1ed1c 4 h\\u0169 s\\u1eefa chua \\u0103n co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Lothamilk 100g", "score": 0.8}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "score": 0.61}, {"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "score": 0.97}, {"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "score": 0.97}]	t	2026-03-21 20:11:14.3519
23	HCM_Q7	TXN-20260309-00023	2026-03-09 15:58:14.361431+00	47	EDGE_HCM_Q7_01	[{"product_id": 54, "product_code": "c5544e90-b58e-4a17-89af-5f131087703b", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "qty": 2, "unit_price": 34500.0}, {"product_id": 148, "product_code": "d6f2920e-e16a-4096-8159-a938f4b8ce59", "name": "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "qty": 1, "unit_price": 16200.0}]	2	85200	[{"product_id": 103, "product_code": "215bb35c-37c7-451d-8a5e-19d774e2ec28", "name": "B\\u00e1nh quy socola chip nh\\u00e2n socola Parle Platina Hide & Seek g\\u00f3i 112.5g", "score": 0.78}, {"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "score": 0.96}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.95}]	t	2026-03-09 15:58:14.361431
24	HCM_Q7	TXN-20260216-00024	2026-02-16 16:33:14.369984+00	52	EDGE_HCM_Q7_01	[{"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "qty": 3, "unit_price": 65000.0}, {"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "qty": 3, "unit_price": 4750.0}, {"product_id": 81, "product_code": "1485f5ea-a1a9-4383-98c4-338a415c5e3d", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb \\u0111\\u00e0o 12% chai 360ml", "qty": 2, "unit_price": 42750.0}, {"product_id": 136, "product_code": "53ec6e96-b534-42e0-a986-9d6d2d36e86d", "name": "D\\u1ea7u g\\u1ed9i Sunsilk (Chai 650g)", "qty": 2, "unit_price": 88000.0}]	4	470750	[{"product_id": 70, "product_code": "83bab65c-5e02-45a8-936d-58eaa4e206a2", "name": "Th\\u00f9ng 24 lon Bia Tiger lon 250ml", "score": 0.7}, {"product_id": 86, "product_code": "4544a866-890a-460f-93db-542521c75fa7", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt 7 Up v\\u1ecb chanh 390ml", "score": 0.82}, {"product_id": 69, "product_code": "c6db64ee-92ea-4113-8297-a2e94c4f6be6", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa dinh d\\u01b0\\u1ee1ng Gotz 55g", "score": 0.78}, {"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "score": 0.86}]	f	2026-02-16 16:33:14.369984
25	HCM_Q1	TXN-20260331-00025	2026-03-31 04:33:14.378846+00	44	EDGE_HCM_Q1_01	[{"product_id": 18, "product_code": "fc0359c0-800a-40c9-8e49-660ab593f7e3", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "qty": 3, "unit_price": 105300.0}]	1	315900	[{"product_id": 90, "product_code": "61c35ff1-5a92-4568-9870-e345bc73a24c", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml", "score": 0.71}, {"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.67}, {"product_id": 186, "product_code": "da5a3390-cf73-4a9f-bffc-f6e02a0905b2", "name": "B\\u00fat bi Thi\\u00ean Long (C\\u00e2y)", "score": 0.61}]	t	2026-03-31 04:33:14.378846
26	HN_CG	TXN-20260323-00026	2026-03-23 04:57:14.388386+00	8	EDGE_HN_CG_01	[{"product_id": 155, "product_code": "4dd70e94-850f-406f-a440-c4a161d99325", "name": "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "qty": 3, "unit_price": 35000.0}]	1	105000	[{"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "score": 0.67}, {"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "score": 0.71}]	f	2026-03-23 04:57:14.388386
27	HN_CG	TXN-20260328-00027	2026-03-28 05:15:14.396564+00	50	EDGE_HN_CG_01	[{"product_id": 71, "product_code": "bbd97816-ba62-4a9a-8384-7d7bff031ab1", "name": "Th\\u00f9ng 24 lon Bia Heineken Silver 250ml", "qty": 2, "unit_price": 355000.0}]	1	710000	[{"product_id": 68, "product_code": "5d22b162-c9c6-4540-ab8a-ff709f7148e3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa h\\u01b0\\u01a1ng vani Hoff 55g", "score": 0.63}, {"product_id": 46, "product_code": "8636600f-9b6f-4cb4-a120-cf70c55c20e6", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "score": 0.97}, {"product_id": 113, "product_code": "e7753b8d-850e-4de8-935e-b4cb3e98063a", "name": "\\u0110\\u01b0\\u1eddng tinh luy\\u1ec7n Bi\\u00ean H\\u00f2a (1kg)", "score": 0.68}]	f	2026-03-28 05:15:14.396564
28	HCM_Q7	TXN-20260327-00028	2026-03-27 15:03:14.404976+00	7	EDGE_HCM_Q7_01	[{"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "qty": 3, "unit_price": 5000.0}, {"product_id": 67, "product_code": "a67c2aa4-d081-41f2-a440-30d00cd60c5b", "name": "L\\u1ed1c 2 h\\u0169 s\\u01b0\\u0303a chua n\\u00ea\\u0301p c\\u00e2\\u0309m Sa\\u0300i Go\\u0300n Milk 120g", "qty": 2, "unit_price": 27000.0}, {"product_id": 27, "product_code": "b048d361-49e5-4b05-8560-1b82458ef15b", "name": "B\\u00fan c\\u00e1 cay H\\u1eb1ng Nga g\\u00f3i 70g", "qty": 2, "unit_price": 10000.0}, {"product_id": 9, "product_code": "e4c1b87f-da03-460d-970f-cccf1b363bc7", "name": "N\\u01b0\\u1edbc m\\u1eafm Chinsu c\\u00e1 c\\u01a1m bi\\u1ec3n \\u0111\\u00f4ng 25 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 1, "unit_price": 48450.0}]	4	137450	[{"product_id": 168, "product_code": "131a23d6-1d20-4d98-b9dd-2d0eb19e0b54", "name": "B\\u00f3ng \\u0111\\u00e8n LED \\u0110i\\u1ec7n Quang 20W", "score": 0.6}, {"product_id": 164, "product_code": "5576682c-00ee-4aab-8888-3526e2bf7626", "name": "Bao tay cao su (\\u0110\\u00f4i)", "score": 0.61}]	f	2026-03-27 15:03:14.404976
29	HN_CG	TXN-20260327-00029	2026-03-27 00:25:14.413933+00	50	EDGE_HN_CG_01	[{"product_id": 123, "product_code": "b5986a34-443f-4122-a13b-528f10e97ea5", "name": "Tr\\u00e0 Lipton T\\u00fai l\\u1ecdc (H\\u1ed9p 25 g\\u00f3i)", "qty": 1, "unit_price": 35000.0}, {"product_id": 112, "product_code": "26a9aea3-5f05-45b5-81af-801b4e2e9d24", "name": "B\\u1ed9t ng\\u1ecdt Ajinomoto (454g)", "qty": 2, "unit_price": 32000.0}, {"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "qty": 3, "unit_price": 39000.0}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 2, "unit_price": 6800.0}]	4	229600	[{"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "score": 0.75}, {"product_id": 86, "product_code": "4544a866-890a-460f-93db-542521c75fa7", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt 7 Up v\\u1ecb chanh 390ml", "score": 0.84}, {"product_id": 175, "product_code": "c55a887f-03c5-45e6-9934-5f8a9a007306", "name": "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "score": 0.96}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.63}]	t	2026-03-27 00:25:14.413933
30	HCM_Q7	TXN-20260307-00030	2026-03-07 13:59:14.424241+00	3	EDGE_HCM_Q7_01	[{"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "qty": 3, "unit_price": 10000.0}, {"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "qty": 2, "unit_price": 34000.0}, {"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "qty": 2, "unit_price": 349000.0}, {"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "qty": 1, "unit_price": 12000.0}]	4	808000	[{"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "score": 0.61}, {"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "score": 0.61}, {"product_id": 36, "product_code": "6ea649b0-f9e4-44cb-9fb9-768d1889cdf6", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "score": 0.98}]	f	2026-03-07 13:59:14.424241
72	HCM_Q1	TXN-20260322-00072	2026-03-22 06:09:14.810381+00	31	EDGE_HCM_Q1_01	[{"product_id": 72, "product_code": "ecb6b5c5-539c-4c4a-89a3-ad676f69c353", "name": "Th\\u00f9ng 24 lon Bia S\\u00e0i G\\u00f2n Lager 330ml", "qty": 3, "unit_price": 206400.0}, {"product_id": 201, "product_code": "e2b8c4e1-00d7-476e-9541-5da23db32d9e", "name": "V\\u1edb ch\\u00e2n nam/n\\u1eef (\\u0110\\u00f4i)", "qty": 2, "unit_price": 12000.0}]	2	643200	[{"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "score": 0.61}, {"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "score": 0.88}]	f	2026-03-22 06:09:14.810381
31	HCM_Q7	TXN-20260309-00031	2026-03-09 18:37:14.433793+00	54	EDGE_HCM_Q7_01	[{"product_id": 5, "product_code": "9258ca2f-5e05-4eac-be09-b5a69a4b9cd0", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0 nh\\u00e3n v\\u00e0ng 14 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 2, "unit_price": 41500.0}, {"product_id": 10, "product_code": "63a338bb-de9f-45cb-b283-d0abab06015d", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Nh\\u1ecb Ca Tam Th\\u00e1i T\\u1eed chai", "qty": 1, "unit_price": 8800.0}, {"product_id": 87, "product_code": "b336ff02-4595-449e-ada1-c89697da7fc2", "name": "Th\\u00f9ng 12 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 1.5 l\\u00edt", "qty": 1, "unit_price": 180000.0}, {"product_id": 15, "product_code": "cebc7811-c35c-4a9d-8b37-854d28b07b22", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g", "qty": 3, "unit_price": 110200.0}]	4	602400	[{"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "score": 0.88}, {"product_id": 138, "product_code": "8e13d676-f7e9-477f-940b-813f80469993", "name": "S\\u1eefa t\\u1eafm Lifebuoy (Chai 850g)", "score": 0.69}, {"product_id": 39, "product_code": "0e3740f8-9d6f-4f7b-b1bb-3b719c18c93b", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "score": 0.63}]	f	2026-03-09 18:37:14.433793
32	HCM_Q1	TXN-20260219-00032	2026-02-19 15:42:14.442963+00	9	EDGE_HCM_Q1_01	[{"product_id": 45, "product_code": "70aecc30-273a-4640-ae9e-bf45c96ba51b", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng lof Kun 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 2, "unit_price": 376000.0}]	1	752000	[{"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "score": 0.66}, {"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "score": 0.82}]	f	2026-02-19 15:42:14.442963
33	HCM_Q1	TXN-20260225-00033	2026-02-25 13:19:14.453237+00	52	EDGE_HCM_Q1_01	[{"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "qty": 1, "unit_price": 45000.0}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 1, "unit_price": 170000.0}, {"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "qty": 3, "unit_price": 33250.0}, {"product_id": 148, "product_code": "d6f2920e-e16a-4096-8159-a938f4b8ce59", "name": "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "qty": 1, "unit_price": 16200.0}]	4	330950	[{"product_id": 71, "product_code": "bbd97816-ba62-4a9a-8384-7d7bff031ab1", "name": "Th\\u00f9ng 24 lon Bia Heineken Silver 250ml", "score": 0.89}, {"product_id": 37, "product_code": "6f831c1e-17cc-4ea1-848a-33cbc4c7ec9a", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "score": 0.66}]	t	2026-02-25 13:19:14.453237
34	HCM_Q1	TXN-20260326-00034	2026-03-26 17:39:14.461893+00	41	EDGE_HCM_Q1_01	[{"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "qty": 1, "unit_price": 5000.0}, {"product_id": 200, "product_code": "44e0b85c-6165-439b-84b4-6f85374c19e1", "name": "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "qty": 1, "unit_price": 70000.0}, {"product_id": 41, "product_code": "8c0bd0e0-9c72-4d67-9c29-61b269b31df8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 3, "unit_price": 355000.0}, {"product_id": 5, "product_code": "9258ca2f-5e05-4eac-be09-b5a69a4b9cd0", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0 nh\\u00e3n v\\u00e0ng 14 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 3, "unit_price": 41500.0}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "qty": 3, "unit_price": 18000.0}]	5	1318500	[{"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "score": 0.78}, {"product_id": 203, "product_code": "cd3322e6-fa79-4ff1-9ec1-017716f5f8af", "name": "C\\u00e1p s\\u1ea1c Android/iPhone", "score": 0.65}, {"product_id": 198, "product_code": "2c790f44-7ee9-4c1d-9170-0f67eaf7e736", "name": "M\\u0169 b\\u1ea3o hi\\u1ec3m n\\u1eeda \\u0111\\u1ea7u", "score": 0.65}]	f	2026-03-26 17:39:14.461893
35	HN_CG	TXN-20260312-00035	2026-03-12 06:13:14.472206+00	46	EDGE_HN_CG_01	[{"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 1, "unit_price": 25000.0}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "qty": 3, "unit_price": 250000.0}, {"product_id": 161, "product_code": "d0ce3076-c06f-42af-ba23-221c0ee27198", "name": "Nhang mu\\u1ed7i (H\\u1ed9p 10 khoanh)", "qty": 1, "unit_price": 8000.0}, {"product_id": 201, "product_code": "e2b8c4e1-00d7-476e-9541-5da23db32d9e", "name": "V\\u1edb ch\\u00e2n nam/n\\u1eef (\\u0110\\u00f4i)", "qty": 1, "unit_price": 12000.0}]	4	795000	[{"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.97}, {"product_id": 159, "product_code": "faa88516-1182-495d-981d-3a5f206d2770", "name": "S\\u00e1p kh\\u1eed m\\u00f9i ph\\u00f2ng (H\\u1ed9p)", "score": 0.79}, {"product_id": 93, "product_code": "204e5daa-e27a-42e2-ad34-d29fcb5d84a5", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 320ml", "score": 0.78}, {"product_id": 195, "product_code": "0c817e5a-0d94-4f29-be97-bc218296a244", "name": "Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "score": 0.84}]	t	2026-03-12 06:13:14.472206
36	HN_CG	TXN-20260218-00036	2026-02-18 06:21:14.481737+00	11	EDGE_HN_CG_01	[{"product_id": 14, "product_code": "7d31d029-8f17-4074-ad5e-96f50b6b9465", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en", "qty": 1, "unit_price": 41000.0}]	1	41000	[{"product_id": 158, "product_code": "8526f078-cb9e-4c78-ae7a-ab1526ddda7d", "name": "N\\u01b0\\u1edbc r\\u1eeda tay kh\\u00f4 (Chai 100ml)", "score": 0.62}, {"product_id": 195, "product_code": "0c817e5a-0d94-4f29-be97-bc218296a244", "name": "Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "score": 0.88}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "score": 0.95}]	t	2026-02-18 06:21:14.481737
37	HCM_Q1	TXN-20260317-00037	2026-03-17 14:19:14.491143+00	21	EDGE_HCM_Q1_01	[{"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "qty": 1, "unit_price": 298000.0}, {"product_id": 192, "product_code": "b812638a-f73d-4a60-9695-eac88da8a809", "name": "B\\u1ea5m kim s\\u1ed1 10 (C\\u00e1i)", "qty": 1, "unit_price": 18000.0}, {"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "qty": 1, "unit_price": 4750.0}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "qty": 3, "unit_price": 45000.0}]	4	455750	[{"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "score": 0.63}, {"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.82}]	t	2026-03-17 14:19:14.491143
38	HCM_Q1	TXN-20260314-00038	2026-03-14 11:18:14.499686+00	30	EDGE_HCM_Q1_01	[{"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "qty": 1, "unit_price": 12000.0}, {"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "qty": 1, "unit_price": 17850.0}]	2	29850	[{"product_id": 72, "product_code": "ecb6b5c5-539c-4c4a-89a3-ad676f69c353", "name": "Th\\u00f9ng 24 lon Bia S\\u00e0i G\\u00f2n Lager 330ml", "score": 0.64}, {"product_id": 35, "product_code": "313a33b8-b547-45a7-ae0a-92edf3d8ed09", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng kh\\u00f4ng \\u0111\\u01b0\\u1eddng Vinamilk S\\u1eefa t\\u01b0\\u01a1i 100% 1 l\\u00edt", "score": 0.78}]	f	2026-03-14 11:18:14.499686
39	HCM_Q1	TXN-20260226-00039	2026-02-26 01:44:14.508959+00	36	EDGE_HCM_Q1_01	[{"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "qty": 1, "unit_price": 250000.0}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "qty": 3, "unit_price": 152000.0}]	2	706000	[{"product_id": 72, "product_code": "ecb6b5c5-539c-4c4a-89a3-ad676f69c353", "name": "Th\\u00f9ng 24 lon Bia S\\u00e0i G\\u00f2n Lager 330ml", "score": 0.76}, {"product_id": 4, "product_code": "2552366a-29a2-46a3-943a-3d8fb45b3fad", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "score": 0.93}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "score": 0.69}]	f	2026-02-26 01:44:14.508959
40	HCM_Q1	TXN-20260227-00040	2026-02-27 16:12:14.518193+00	\N	EDGE_HCM_Q1_01	[{"product_id": 121, "product_code": "827e4a51-3225-4f53-a04f-e03b0e5b9f8d", "name": "S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "qty": 3, "unit_price": 26000.0}]	1	78000	[{"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "score": 0.63}, {"product_id": 116, "product_code": "de0f18f5-f3b9-44bb-9d2d-ca990368168e", "name": "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "score": 0.89}, {"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "score": 0.86}, {"product_id": 62, "product_code": "8e6ed997-217f-4dc4-ba92-611c2a6bbd91", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n \\u00edt \\u0111\\u01b0\\u1eddng Nutimilk 100g", "score": 0.75}]	t	2026-02-27 16:12:14.518193
41	HCM_Q7	TXN-20260322-00041	2026-03-22 19:14:14.528944+00	30	EDGE_HCM_Q7_01	[{"product_id": 192, "product_code": "b812638a-f73d-4a60-9695-eac88da8a809", "name": "B\\u1ea5m kim s\\u1ed1 10 (C\\u00e1i)", "qty": 1, "unit_price": 18000.0}, {"product_id": 150, "product_code": "8f4dc2fd-7d0d-449f-88a4-47cad03d38d2", "name": "T\\u00e3 qu\\u1ea7n Bobby (B\\u1ecbch M40)", "qty": 2, "unit_price": 210000.0}, {"product_id": 7, "product_code": "271cc8ca-e37c-4277-90dc-36f3b624ac9a", "name": "N\\u01b0\\u1edbc ch\\u1ea5m chua ng\\u1ecdt Nam Ng\\u01b0 \\u1edbt t\\u1ecfi L\\u00fd S\\u01a1n", "qty": 3, "unit_price": 28000.0}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "qty": 2, "unit_price": 18000.0}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "qty": 3, "unit_price": 32000.0}]	5	654000	[{"product_id": 19, "product_code": "aca2f004-f76e-481b-abe7-d495d4a2d9d1", "name": "Th\\u00f9ng 24 ly m\\u00ec Handy H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 67g", "score": 0.8}, {"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "score": 0.71}, {"product_id": 177, "product_code": "991f1b12-1dc2-498a-83bb-75bf860ad56b", "name": "K\\u1eb9p qu\\u1ea7n \\u00e1o (V\\u1ec9 20)", "score": 0.89}, {"product_id": 86, "product_code": "4544a866-890a-460f-93db-542521c75fa7", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt 7 Up v\\u1ecb chanh 390ml", "score": 0.87}]	f	2026-03-22 19:14:14.528944
42	HCM_Q1	TXN-20260308-00042	2026-03-08 03:00:14.540657+00	\N	EDGE_HCM_Q1_01	[{"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "qty": 1, "unit_price": 35500.0}]	1	35500	[{"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "score": 0.87}, {"product_id": 144, "product_code": "2869b301-5fec-407f-b472-6e72ee034c9f", "name": "N\\u01b0\\u1edbc r\\u1eeda ch\\u00e9n Sunlight (750ml)", "score": 0.81}]	t	2026-03-08 03:00:14.540657
43	HN_CG	TXN-20260314-00043	2026-03-14 00:56:14.549397+00	49	EDGE_HN_CG_01	[{"product_id": 83, "product_code": "a0500366-8dd9-44bc-ad93-6e2f9241f1bf", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng d\\u1ee9a 12.5% chai 360ml", "qty": 2, "unit_price": 38250.0}, {"product_id": 91, "product_code": "845e5e02-35a6-498e-9420-f6d30ae72b04", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Coca Cola 320ml", "qty": 2, "unit_price": 52000.0}]	2	180500	[{"product_id": 89, "product_code": "4362ec25-fdc1-4b2a-9588-6642962e5302", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Pepsi Cola 390ml", "score": 0.79}, {"product_id": 116, "product_code": "de0f18f5-f3b9-44bb-9d2d-ca990368168e", "name": "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "score": 0.92}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "score": 0.78}]	t	2026-03-14 00:56:14.549397
57	HCM_Q7	TXN-20260321-00057	2026-03-21 00:50:14.666418+00	55	EDGE_HCM_Q7_01	[{"product_id": 149, "product_code": "37ee0bd9-0b99-403e-96ab-f314af9c2e8e", "name": "B\\u0103ng v\\u1ec7 sinh Diana (G\\u00f3i 8)", "qty": 3, "unit_price": 16200.0}, {"product_id": 90, "product_code": "61c35ff1-5a92-4568-9870-e345bc73a24c", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml", "qty": 3, "unit_price": 9000.0}, {"product_id": 91, "product_code": "845e5e02-35a6-498e-9420-f6d30ae72b04", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Coca Cola 320ml", "qty": 1, "unit_price": 52000.0}]	3	127600	[{"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "score": 0.89}, {"product_id": 149, "product_code": "37ee0bd9-0b99-403e-96ab-f314af9c2e8e", "name": "B\\u0103ng v\\u1ec7 sinh Diana (G\\u00f3i 8)", "score": 0.8}]	f	2026-03-21 00:50:14.666418
44	HN_CG	TXN-20260313-00044	2026-03-13 15:33:14.557926+00	57	EDGE_HN_CG_01	[{"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "qty": 1, "unit_price": 250000.0}, {"product_id": 21, "product_code": "9ad51e21-230b-486c-abce-5487f7b09ed3", "name": "M\\u00ec H\\u1ea3o 100 t\\u00f4m chua cay g\\u00f3i 65g", "qty": 2, "unit_price": 2890.0}, {"product_id": 101, "product_code": "26b41c6b-4f50-45ec-b945-2a2e9eb74025", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh c\\u00e1 v\\u1ecb t\\u00f4m n\\u01b0\\u1edbng m\\u00f4i \\u0111\\u1ecf Orion Marine Boy 35g", "qty": 1, "unit_price": 260000.0}, {"product_id": 46, "product_code": "8636600f-9b6f-4cb4-a120-cf70c55c20e6", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "qty": 3, "unit_price": 31500.0}]	4	610280	[{"product_id": 53, "product_code": "d5b1b057-5bcf-4629-a973-7f8e9c0bca3c", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "score": 0.96}, {"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "score": 0.61}]	t	2026-03-13 15:33:14.557926
45	HN_CG	TXN-20260225-00045	2026-02-25 21:18:14.567284+00	5	EDGE_HN_CG_01	[{"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "qty": 2, "unit_price": 20800.0}]	1	41600	[{"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "score": 0.83}, {"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "score": 0.86}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.92}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "score": 0.77}]	f	2026-02-25 21:18:14.567284
46	HCM_Q7	TXN-20260309-00046	2026-03-09 08:10:14.575394+00	\N	EDGE_HCM_Q7_01	[{"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "qty": 1, "unit_price": 425000.0}]	1	425000	[{"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "score": 0.71}, {"product_id": 138, "product_code": "8e13d676-f7e9-477f-940b-813f80469993", "name": "S\\u1eefa t\\u1eafm Lifebuoy (Chai 850g)", "score": 0.97}]	f	2026-03-09 08:10:14.575394
47	HCM_Q7	TXN-20260322-00047	2026-03-22 06:11:14.582922+00	14	EDGE_HCM_Q7_01	[{"product_id": 182, "product_code": "04931d60-d635-4729-8b9e-1171306f235b", "name": "N\\u1ebfn c\\u00e2y (G\\u00f3i 5 c\\u00e2y)", "qty": 3, "unit_price": 10000.0}, {"product_id": 9, "product_code": "e4c1b87f-da03-460d-970f-cccf1b363bc7", "name": "N\\u01b0\\u1edbc m\\u1eafm Chinsu c\\u00e1 c\\u01a1m bi\\u1ec3n \\u0111\\u00f4ng 25 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 1, "unit_price": 48450.0}, {"product_id": 171, "product_code": "34b1c04a-0e91-4eaf-ae2d-f379c0324d29", "name": "Pin AAA Panasonic (V\\u1ec9 2 vi\\u00ean)", "qty": 3, "unit_price": 15000.0}, {"product_id": 82, "product_code": "7301020d-0402-4b78-969e-9e061a2a830f", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb d\\u00e2u 12% chai 360ml", "qty": 2, "unit_price": 45000.0}, {"product_id": 89, "product_code": "4362ec25-fdc1-4b2a-9588-6642962e5302", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Pepsi Cola 390ml", "qty": 1, "unit_price": 118000.0}]	5	331450	[{"product_id": 128, "product_code": "a010e906-1854-42a0-944b-8bcd42f82e55", "name": "Snack Khoai t\\u00e2y O'Star", "score": 0.96}, {"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "score": 0.95}, {"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "score": 0.66}]	f	2026-03-22 06:11:14.582922
48	HN_CG	TXN-20260301-00048	2026-03-01 16:31:14.590249+00	47	EDGE_HN_CG_01	[{"product_id": 87, "product_code": "b336ff02-4595-449e-ada1-c89697da7fc2", "name": "Th\\u00f9ng 12 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 1.5 l\\u00edt", "qty": 3, "unit_price": 180000.0}, {"product_id": 177, "product_code": "991f1b12-1dc2-498a-83bb-75bf860ad56b", "name": "K\\u1eb9p qu\\u1ea7n \\u00e1o (V\\u1ec9 20)", "qty": 3, "unit_price": 15000.0}, {"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "qty": 1, "unit_price": 52000.0}, {"product_id": 188, "product_code": "4a5f7c93-02f6-48e0-bcb4-a1c7ae3aec53", "name": "B\\u00fat ch\\u00ec g\\u1ed7 2B", "qty": 2, "unit_price": 3000.0}]	4	643000	[{"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.72}, {"product_id": 115, "product_code": "11086cc9-d30a-4145-acaf-8e2084c851f0", "name": "T\\u01b0\\u01a1ng \\u1edbt Chinsu (250g)", "score": 0.83}, {"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "score": 0.67}, {"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "score": 0.8}]	t	2026-03-01 16:31:14.590249
49	HN_CG	TXN-20260221-00049	2026-02-21 01:36:14.600486+00	\N	EDGE_HN_CG_01	[{"product_id": 50, "product_code": "16150fd4-8086-42ac-a03a-6bcfd77425f2", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch BFAST b\\u1ed5 sung canxi 180ml", "qty": 3, "unit_price": 27000.0}, {"product_id": 126, "product_code": "d487390c-5ffd-47eb-b891-e9feeaeb0830", "name": "Bia Tiger N\\u00e2u (Lon 330ml)", "qty": 2, "unit_price": 16000.0}, {"product_id": 82, "product_code": "7301020d-0402-4b78-969e-9e061a2a830f", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb d\\u00e2u 12% chai 360ml", "qty": 2, "unit_price": 45000.0}, {"product_id": 155, "product_code": "4dd70e94-850f-406f-a440-c4a161d99325", "name": "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "qty": 1, "unit_price": 35000.0}]	4	238000	[{"product_id": 95, "product_code": "0f57e196-eacf-4d9f-89a6-5fdd236a80c9", "name": "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "score": 0.6}, {"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "score": 0.73}, {"product_id": 96, "product_code": "a903b525-93ec-4602-bf74-099d44d3ea67", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola h\\u01b0\\u01a1ng vani Gery Crunch Roll g\\u00f3i 23g", "score": 0.72}]	f	2026-02-21 01:36:14.600486
50	HCM_Q1	TXN-20260326-00050	2026-03-26 13:26:14.608082+00	27	EDGE_HCM_Q1_01	[{"product_id": 151, "product_code": "4e6b1095-a3cb-4d03-b747-0b3080e9a160", "name": "X\\u00e0 b\\u00f4ng c\\u1ee5c X-Men", "qty": 2, "unit_price": 14250.0}, {"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "qty": 2, "unit_price": 65000.0}]	2	158500	[{"product_id": 86, "product_code": "4544a866-890a-460f-93db-542521c75fa7", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt 7 Up v\\u1ecb chanh 390ml", "score": 0.74}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "score": 0.6}, {"product_id": 152, "product_code": "a544d61d-edb8-4b54-ad19-8f4745d8307a", "name": "S\\u1eefa r\\u1eeda m\\u1eb7t Acnes (100g)", "score": 0.84}, {"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "score": 0.7}]	f	2026-03-26 13:26:14.608082
51	HCM_Q1	TXN-20260222-00051	2026-02-22 08:08:14.617622+00	32	EDGE_HCM_Q1_01	[{"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 3, "unit_price": 9600.0}]	1	28800	[{"product_id": 7, "product_code": "271cc8ca-e37c-4277-90dc-36f3b624ac9a", "name": "N\\u01b0\\u1edbc ch\\u1ea5m chua ng\\u1ecdt Nam Ng\\u01b0 \\u1edbt t\\u1ecfi L\\u00fd S\\u01a1n", "score": 0.6}, {"product_id": 203, "product_code": "cd3322e6-fa79-4ff1-9ec1-017716f5f8af", "name": "C\\u00e1p s\\u1ea1c Android/iPhone", "score": 0.7}]	f	2026-02-22 08:08:14.617622
52	HN_CG	TXN-20260307-00052	2026-03-07 23:09:14.624829+00	49	EDGE_HN_CG_01	[{"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "qty": 3, "unit_price": 28500.0}, {"product_id": 18, "product_code": "fc0359c0-800a-40c9-8e49-660ab593f7e3", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "qty": 2, "unit_price": 105300.0}, {"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "qty": 2, "unit_price": 65000.0}]	3	426100	[{"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "score": 0.79}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.82}, {"product_id": 96, "product_code": "a903b525-93ec-4602-bf74-099d44d3ea67", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola h\\u01b0\\u01a1ng vani Gery Crunch Roll g\\u00f3i 23g", "score": 0.92}]	f	2026-03-07 23:09:14.624829
53	HCM_Q1	TXN-20260328-00053	2026-03-28 08:21:14.633055+00	18	EDGE_HCM_Q1_01	[{"product_id": 108, "product_code": "ba0eeecc-e4ce-4bd7-b4f0-91117d028872", "name": "Th\\u00f9ng M\\u00ec 3 Mi\\u1ec1n (30 g\\u00f3i)", "qty": 3, "unit_price": 85000.0}, {"product_id": 163, "product_code": "5acdac1a-898e-4a9f-8acd-f8590ce29d7b", "name": "C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)", "qty": 3, "unit_price": 12000.0}, {"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "qty": 1, "unit_price": 17850.0}]	3	308850	[{"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "score": 0.89}, {"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "score": 0.81}, {"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.93}, {"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "score": 0.91}]	f	2026-03-28 08:21:14.633055
54	HCM_Q1	TXN-20260310-00054	2026-03-10 12:33:14.640057+00	19	EDGE_HCM_Q1_01	[{"product_id": 200, "product_code": "44e0b85c-6165-439b-84b4-6f85374c19e1", "name": "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "qty": 1, "unit_price": 70000.0}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "qty": 1, "unit_price": 18000.0}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "qty": 3, "unit_price": 152000.0}]	3	544000	[{"product_id": 204, "product_code": "e03863a3-5056-43ed-af9e-77bdb148f682", "name": "C\\u1ee7 s\\u1ea1c USB 2 c\\u1ed5ng", "score": 0.83}, {"product_id": 144, "product_code": "2869b301-5fec-407f-b472-6e72ee034c9f", "name": "N\\u01b0\\u1edbc r\\u1eeda ch\\u00e9n Sunlight (750ml)", "score": 0.92}]	t	2026-03-10 12:33:14.640057
55	HCM_Q1	TXN-20260226-00055	2026-02-26 07:28:14.649728+00	20	EDGE_HCM_Q1_01	[{"product_id": 36, "product_code": "6ea649b0-f9e4-44cb-9fb9-768d1889cdf6", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "qty": 3, "unit_price": 425000.0}, {"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "qty": 2, "unit_price": 5000.0}, {"product_id": 153, "product_code": "0fae3be1-0f57-4a82-aba9-d13e180c1943", "name": "Dao c\\u1ea1o r\\u00e2u Gillette (C\\u00e2y)", "qty": 1, "unit_price": 12000.0}]	3	1297000	[{"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.93}, {"product_id": 33, "product_code": "f5833d36-7b7f-4702-937f-8d1286c31a38", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "score": 0.65}]	f	2026-02-26 07:28:14.649728
56	HCM_Q7	TXN-20260325-00056	2026-03-25 15:49:14.657874+00	50	EDGE_HCM_Q7_01	[{"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "qty": 3, "unit_price": 8500.0}, {"product_id": 111, "product_code": "39db55d0-6784-4457-900f-d85d7b17e783", "name": "H\\u1ea1t n\\u00eam Knorr (400g)", "qty": 3, "unit_price": 30400.0}, {"product_id": 11, "product_code": "c657b334-1d73-44af-b7cc-74d5d5bd1efa", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi \\u0111\\u1eadm \\u0111\\u1eb7c", "qty": 3, "unit_price": 35000.0}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "qty": 1, "unit_price": 298000.0}]	4	519700	[{"product_id": 12, "product_code": "32c195be-0444-4c26-8b09-761cb0b32136", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi thanh d\\u1ecbu", "score": 0.85}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "score": 0.89}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.9}]	f	2026-03-25 15:49:14.657874
58	HN_CG	TXN-20260320-00058	2026-03-20 02:56:14.67696+00	\N	EDGE_HN_CG_01	[{"product_id": 182, "product_code": "04931d60-d635-4729-8b9e-1171306f235b", "name": "N\\u1ebfn c\\u00e2y (G\\u00f3i 5 c\\u00e2y)", "qty": 1, "unit_price": 10000.0}, {"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 1, "unit_price": 52000.0}, {"product_id": 94, "product_code": "d1b9db4c-7740-417c-9d54-b450251614c9", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml", "qty": 2, "unit_price": 10000.0}, {"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "qty": 2, "unit_price": 12000.0}, {"product_id": 151, "product_code": "4e6b1095-a3cb-4d03-b747-0b3080e9a160", "name": "X\\u00e0 b\\u00f4ng c\\u1ee5c X-Men", "qty": 2, "unit_price": 14250.0}]	5	134500	[{"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "score": 0.89}, {"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "score": 0.72}]	t	2026-03-20 02:56:14.67696
59	HCM_Q1	TXN-20260311-00059	2026-03-11 19:46:14.687475+00	25	EDGE_HCM_Q1_01	[{"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "qty": 2, "unit_price": 18000.0}, {"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "qty": 1, "unit_price": 65000.0}, {"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "qty": 3, "unit_price": 5000.0}]	3	116000	[{"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "score": 0.96}, {"product_id": 18, "product_code": "fc0359c0-800a-40c9-8e49-660ab593f7e3", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "score": 0.74}, {"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "score": 0.6}]	t	2026-03-11 19:46:14.687475
60	HCM_Q1	TXN-20260319-00060	2026-03-19 07:27:14.696642+00	26	EDGE_HCM_Q1_01	[{"product_id": 27, "product_code": "b048d361-49e5-4b05-8560-1b82458ef15b", "name": "B\\u00fan c\\u00e1 cay H\\u1eb1ng Nga g\\u00f3i 70g", "qty": 3, "unit_price": 10000.0}, {"product_id": 190, "product_code": "91a2bcb3-d18b-47dc-ab24-5af040967bf2", "name": "Th\\u01b0\\u1edbc k\\u1ebb 20cm", "qty": 2, "unit_price": 5000.0}, {"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 1, "unit_price": 355000.0}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "qty": 1, "unit_price": 95200.0}, {"product_id": 94, "product_code": "d1b9db4c-7740-417c-9d54-b450251614c9", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml", "qty": 2, "unit_price": 10000.0}]	5	510200	[{"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "score": 0.82}, {"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "score": 0.7}, {"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "score": 0.9}]	f	2026-03-19 07:27:14.696642
61	HCM_Q7	TXN-20260315-00061	2026-03-15 02:08:14.70518+00	30	EDGE_HCM_Q7_01	[{"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 1, "unit_price": 345000.0}]	1	345000	[{"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "score": 0.88}, {"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "score": 0.92}]	f	2026-03-15 02:08:14.70518
62	HCM_Q1	TXN-20260226-00062	2026-02-26 01:49:14.714027+00	7	EDGE_HCM_Q1_01	[{"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "qty": 2, "unit_price": 10000.0}]	1	20000	[{"product_id": 128, "product_code": "a010e906-1854-42a0-944b-8bcd42f82e55", "name": "Snack Khoai t\\u00e2y O'Star", "score": 0.81}, {"product_id": 126, "product_code": "d487390c-5ffd-47eb-b891-e9feeaeb0830", "name": "Bia Tiger N\\u00e2u (Lon 330ml)", "score": 0.91}, {"product_id": 130, "product_code": "260fa104-9d28-45a7-bb5e-06b373367221", "name": "B\\u00e1nh quy Cosy (G\\u00f3i 200g)", "score": 0.81}, {"product_id": 67, "product_code": "a67c2aa4-d081-41f2-a440-30d00cd60c5b", "name": "L\\u1ed1c 2 h\\u0169 s\\u01b0\\u0303a chua n\\u00ea\\u0301p c\\u00e2\\u0309m Sa\\u0300i Go\\u0300n Milk 120g", "score": 0.61}]	t	2026-02-26 01:49:14.714027
63	HCM_Q7	TXN-20260311-00063	2026-03-11 19:29:14.723443+00	3	EDGE_HCM_Q7_01	[{"product_id": 143, "product_code": "a3a7acbd-4cf2-4f56-9930-63c15fc00ecc", "name": "B\\u00e0n ch\\u1ea3i \\u0111\\u00e1nh r\\u0103ng Colgate", "qty": 2, "unit_price": 14250.0}, {"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "qty": 2, "unit_price": 68000.0}]	2	164500	[{"product_id": 100, "product_code": "46b1b7b5-3a08-4c49-96c5-44e9cf02c72d", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh quy socola Orion Miz 54g", "score": 0.82}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "score": 0.79}, {"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "score": 0.81}, {"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "score": 0.8}]	t	2026-03-11 19:29:14.723443
64	HCM_Q7	TXN-20260328-00064	2026-03-28 17:02:14.73356+00	25	EDGE_HCM_Q7_01	[{"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "qty": 1, "unit_price": 4750.0}, {"product_id": 91, "product_code": "845e5e02-35a6-498e-9420-f6d30ae72b04", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Coca Cola 320ml", "qty": 1, "unit_price": 52000.0}, {"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "qty": 2, "unit_price": 30000.0}, {"product_id": 73, "product_code": "c57b5193-7c6a-4e72-be5f-bf08951cd0ec", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "qty": 2, "unit_price": 375250.0}, {"product_id": 83, "product_code": "a0500366-8dd9-44bc-ad93-6e2f9241f1bf", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng d\\u1ee9a 12.5% chai 360ml", "qty": 3, "unit_price": 38250.0}]	5	982000	[{"product_id": 88, "product_code": "e26b7e68-b6d3-48b3-afc4-352c85e6962a", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb 390ml", "score": 0.73}, {"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "score": 0.74}, {"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.73}, {"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "score": 0.85}]	f	2026-03-28 17:02:14.73356
65	HCM_Q1	TXN-20260311-00065	2026-03-11 16:10:14.743752+00	11	EDGE_HCM_Q1_01	[{"product_id": 138, "product_code": "8e13d676-f7e9-477f-940b-813f80469993", "name": "S\\u1eefa t\\u1eafm Lifebuoy (Chai 850g)", "qty": 3, "unit_price": 142500.0}]	1	427500	[{"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "score": 0.86}, {"product_id": 108, "product_code": "ba0eeecc-e4ce-4bd7-b4f0-91117d028872", "name": "Th\\u00f9ng M\\u00ec 3 Mi\\u1ec1n (30 g\\u00f3i)", "score": 0.82}, {"product_id": 69, "product_code": "c6db64ee-92ea-4113-8297-a2e94c4f6be6", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa dinh d\\u01b0\\u1ee1ng Gotz 55g", "score": 0.97}, {"product_id": 6, "product_code": "4261ad1a-adce-4554-9710-a9edbdc16f52", "name": "N\\u01b0\\u1edbc ch\\u1ea5m Nam Ng\\u01b0 \\u0110\\u1ec7 Nh\\u1ecb", "score": 0.74}]	f	2026-03-11 16:10:14.743752
66	HN_CG	TXN-20260308-00066	2026-03-08 04:27:14.755177+00	33	EDGE_HN_CG_01	[{"product_id": 43, "product_code": "d4bfaf6c-3b76-40b5-b6d1-ff43f5cd2555", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng v\\u1ecb t\\u1ef1 nhi\\u00ean TH true MILK Hilo 180ml", "qty": 2, "unit_price": 399500.0}, {"product_id": 158, "product_code": "8526f078-cb9e-4c78-ae7a-ab1526ddda7d", "name": "N\\u01b0\\u1edbc r\\u1eeda tay kh\\u00f4 (Chai 100ml)", "qty": 3, "unit_price": 30000.0}, {"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "qty": 1, "unit_price": 349000.0}]	3	1238000	[{"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "score": 0.71}, {"product_id": 74, "product_code": "bfc156f1-4268-4720-ba38-b2f6882dc6bd", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 250ml", "score": 0.82}, {"product_id": 68, "product_code": "5d22b162-c9c6-4540-ab8a-ff709f7148e3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa h\\u01b0\\u01a1ng vani Hoff 55g", "score": 0.91}, {"product_id": 13, "product_code": "2bcfabb7-eedf-4da1-ad8c-f464bb3e5ee6", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Tam Th\\u00e1i T\\u1eed Nh\\u1ea5t Ca s\\u00e1nh \\u0111\\u1eadm", "score": 0.84}]	f	2026-03-08 04:27:14.755177
67	HN_CG	TXN-20260312-00067	2026-03-12 00:48:14.765715+00	23	EDGE_HN_CG_01	[{"product_id": 167, "product_code": "1922c25c-8820-4cc8-9b62-4ffe1c5b9704", "name": "C\\u00e2y lau nh\\u00e0 360 \\u0111\\u1ed9 (B\\u1ed9)", "qty": 2, "unit_price": 180000.0}]	1	360000	[{"product_id": 81, "product_code": "1485f5ea-a1a9-4383-98c4-338a415c5e3d", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb \\u0111\\u00e0o 12% chai 360ml", "score": 0.7}, {"product_id": 52, "product_code": "ea03fd89-98bb-42ca-900a-59f1006717b8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "score": 0.8}, {"product_id": 107, "product_code": "950bc1a0-a654-4c1f-937a-91b5753c75c0", "name": "M\\u00ec H\\u1ea3o H\\u1ea3o T\\u00f4m Chua Cay", "score": 0.86}, {"product_id": 103, "product_code": "215bb35c-37c7-451d-8a5e-19d774e2ec28", "name": "B\\u00e1nh quy socola chip nh\\u00e2n socola Parle Platina Hide & Seek g\\u00f3i 112.5g", "score": 0.81}]	t	2026-03-12 00:48:14.765715
68	HN_CG	TXN-20260219-00068	2026-02-19 16:06:14.774853+00	41	EDGE_HN_CG_01	[{"product_id": 158, "product_code": "8526f078-cb9e-4c78-ae7a-ab1526ddda7d", "name": "N\\u01b0\\u1edbc r\\u1eeda tay kh\\u00f4 (Chai 100ml)", "qty": 1, "unit_price": 30000.0}, {"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "qty": 2, "unit_price": 30000.0}, {"product_id": 112, "product_code": "26a9aea3-5f05-45b5-81af-801b4e2e9d24", "name": "B\\u1ed9t ng\\u1ecdt Ajinomoto (454g)", "qty": 2, "unit_price": 32000.0}, {"product_id": 145, "product_code": "3f023ad8-02a4-4e95-8ec6-553c622e7d9d", "name": "N\\u01b0\\u1edbc lau s\\u00e0n Gift (1 L\\u00edt)", "qty": 1, "unit_price": 22000.0}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 1, "unit_price": 6800.0}]	5	182800	[{"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "score": 0.72}, {"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "score": 0.92}, {"product_id": 112, "product_code": "26a9aea3-5f05-45b5-81af-801b4e2e9d24", "name": "B\\u1ed9t ng\\u1ecdt Ajinomoto (454g)", "score": 0.62}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "score": 0.68}]	t	2026-02-19 16:06:14.774853
69	HN_CG	TXN-20260316-00069	2026-03-16 08:10:14.783062+00	8	EDGE_HN_CG_01	[{"product_id": 50, "product_code": "16150fd4-8086-42ac-a03a-6bcfd77425f2", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch BFAST b\\u1ed5 sung canxi 180ml", "qty": 2, "unit_price": 27000.0}, {"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 3, "unit_price": 37050.0}]	2	165150	[{"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "score": 0.66}, {"product_id": 10, "product_code": "63a338bb-de9f-45cb-b283-d0abab06015d", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Nh\\u1ecb Ca Tam Th\\u00e1i T\\u1eed chai", "score": 0.65}, {"product_id": 52, "product_code": "ea03fd89-98bb-42ca-900a-59f1006717b8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "score": 0.7}]	f	2026-03-16 08:10:14.783062
70	HCM_Q1	TXN-20260221-00070	2026-02-21 07:44:14.792585+00	\N	EDGE_HCM_Q1_01	[{"product_id": 81, "product_code": "1485f5ea-a1a9-4383-98c4-338a415c5e3d", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb \\u0111\\u00e0o 12% chai 360ml", "qty": 1, "unit_price": 42750.0}]	1	42750	[{"product_id": 94, "product_code": "d1b9db4c-7740-417c-9d54-b450251614c9", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml", "score": 0.94}, {"product_id": 172, "product_code": "17f75c8c-ac61-4e32-8355-90e37f46cc3c", "name": "M\\u00e0ng b\\u1ecdc th\\u1ef1c ph\\u1ea9m (Cu\\u1ed9n)", "score": 0.75}, {"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "score": 0.92}]	f	2026-02-21 07:44:14.792585
71	HCM_Q1	TXN-20260306-00071	2026-03-06 17:52:14.80284+00	50	EDGE_HCM_Q1_01	[{"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "qty": 1, "unit_price": 142800.0}, {"product_id": 150, "product_code": "8f4dc2fd-7d0d-449f-88a4-47cad03d38d2", "name": "T\\u00e3 qu\\u1ea7n Bobby (B\\u1ecbch M40)", "qty": 2, "unit_price": 210000.0}, {"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "qty": 1, "unit_price": 5000.0}]	3	567800	[{"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "score": 0.77}, {"product_id": 71, "product_code": "bbd97816-ba62-4a9a-8384-7d7bff031ab1", "name": "Th\\u00f9ng 24 lon Bia Heineken Silver 250ml", "score": 0.7}]	t	2026-03-06 17:52:14.80284
73	HN_CG	TXN-20260316-00073	2026-03-16 03:15:14.819564+00	\N	EDGE_HN_CG_01	[{"product_id": 137, "product_code": "f0cac878-618a-41d5-9319-8b85e8c0fc27", "name": "D\\u1ea7u g\\u1ed9i Clear Men (Chai 630g)", "qty": 1, "unit_price": 135000.0}]	1	135000	[{"product_id": 66, "product_code": "59989980-7fbb-4c6a-bf32-5d2cb1fa21c5", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Happy Star Vinamilk 100g", "score": 0.96}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.89}, {"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "score": 0.71}]	f	2026-03-16 03:15:14.819564
74	HCM_Q7	TXN-20260320-00074	2026-03-20 19:23:14.828745+00	60	EDGE_HCM_Q7_01	[{"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "qty": 3, "unit_price": 5000.0}, {"product_id": 109, "product_code": "013d09af-48c5-4c50-9709-5b6183c5e8cc", "name": "D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An", "qty": 1, "unit_price": 48000.0}, {"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "qty": 2, "unit_price": 11500.0}]	3	86000	[{"product_id": 141, "product_code": "0b4a4b09-46ec-4a6b-bc41-df4393645a3e", "name": "N\\u01b0\\u1edbc x\\u1ea3 v\\u1ea3i Comfort (T\\u00fai 1.6L)", "score": 0.86}, {"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "score": 0.89}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.84}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "score": 0.67}]	t	2026-03-20 19:23:14.828745
75	HCM_Q7	TXN-20260220-00075	2026-02-20 20:13:14.83778+00	16	EDGE_HCM_Q7_01	[{"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "qty": 2, "unit_price": 15000.0}, {"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "qty": 2, "unit_price": 30000.0}, {"product_id": 167, "product_code": "1922c25c-8820-4cc8-9b62-4ffe1c5b9704", "name": "C\\u00e2y lau nh\\u00e0 360 \\u0111\\u1ed9 (B\\u1ed9)", "qty": 2, "unit_price": 180000.0}, {"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "qty": 3, "unit_price": 25000.0}, {"product_id": 34, "product_code": "15458477-33d0-4386-bf74-bc53f8887361", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 1, "unit_price": 337500.0}]	5	862500	[{"product_id": 152, "product_code": "a544d61d-edb8-4b54-ad19-8f4745d8307a", "name": "S\\u1eefa r\\u1eeda m\\u1eb7t Acnes (100g)", "score": 0.68}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.76}, {"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "score": 0.67}, {"product_id": 73, "product_code": "c57b5193-7c6a-4e72-be5f-bf08951cd0ec", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "score": 0.93}]	t	2026-02-20 20:13:14.83778
76	HN_CG	TXN-20260328-00076	2026-03-28 05:00:14.84652+00	\N	EDGE_HN_CG_01	[{"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "qty": 2, "unit_price": 298000.0}, {"product_id": 68, "product_code": "5d22b162-c9c6-4540-ab8a-ff709f7148e3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa h\\u01b0\\u01a1ng vani Hoff 55g", "qty": 3, "unit_price": 65000.0}, {"product_id": 180, "product_code": "8f382477-a9b4-44d6-bf2a-59fae61d9166", "name": "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "qty": 2, "unit_price": 19000.0}, {"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 1, "unit_price": 355000.0}]	4	1184000	[{"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "score": 0.61}, {"product_id": 146, "product_code": "fd9f259d-1ea9-4994-ae7d-d00f930fcde4", "name": "N\\u01b0\\u1edbc t\\u1ea9y b\\u1ed3n c\\u1ea7u Vim (900ml)", "score": 0.8}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.89}]	t	2026-03-28 05:00:14.84652
77	HCM_Q7	TXN-20260312-00077	2026-03-12 17:56:14.85704+00	28	EDGE_HCM_Q7_01	[{"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "qty": 1, "unit_price": 65000.0}, {"product_id": 56, "product_code": "c11379c8-f11b-4bc0-bc6b-32483cb53628", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p 170ml", "qty": 2, "unit_price": 35150.0}]	2	135300	[{"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "score": 0.97}, {"product_id": 75, "product_code": "adaf187e-c86b-4ead-a4fc-fa93d98d1735", "name": "Th\\u00f9ng 24 lon Bia Blanc 1664 330ml", "score": 0.69}]	t	2026-03-12 17:56:14.85704
78	HCM_Q1	TXN-20260317-00078	2026-03-17 19:15:14.86732+00	56	EDGE_HCM_Q1_01	[{"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "qty": 3, "unit_price": 40000.0}, {"product_id": 102, "product_code": "81606b2f-15e4-4ffc-a73b-fe9afc07043e", "name": "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g", "qty": 2, "unit_price": 21250.0}, {"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "qty": 3, "unit_price": 33250.0}]	3	262250	[{"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.62}, {"product_id": 143, "product_code": "a3a7acbd-4cf2-4f56-9930-63c15fc00ecc", "name": "B\\u00e0n ch\\u1ea3i \\u0111\\u00e1nh r\\u0103ng Colgate", "score": 0.73}]	f	2026-03-17 19:15:14.86732
79	HN_CG	TXN-20260323-00079	2026-03-23 00:37:14.876467+00	33	EDGE_HN_CG_01	[{"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "qty": 3, "unit_price": 65000.0}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 1, "unit_price": 9600.0}, {"product_id": 102, "product_code": "81606b2f-15e4-4ffc-a73b-fe9afc07043e", "name": "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g", "qty": 2, "unit_price": 21250.0}, {"product_id": 172, "product_code": "17f75c8c-ac61-4e32-8355-90e37f46cc3c", "name": "M\\u00e0ng b\\u1ecdc th\\u1ef1c ph\\u1ea9m (Cu\\u1ed9n)", "qty": 1, "unit_price": 19000.0}, {"product_id": 95, "product_code": "0f57e196-eacf-4d9f-89a6-5fdd236a80c9", "name": "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "qty": 3, "unit_price": 22950.0}]	5	334950	[{"product_id": 120, "product_code": "95bd5a46-0188-4553-927a-64cb57498ebc", "name": "L\\u1ed1c 4 s\\u1eefa chua Vinamilk", "score": 0.72}, {"product_id": 34, "product_code": "15458477-33d0-4386-bf74-bc53f8887361", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "score": 0.8}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "score": 0.65}]	f	2026-03-23 00:37:14.876467
80	HCM_Q7	TXN-20260315-00080	2026-03-15 01:19:14.887002+00	\N	EDGE_HCM_Q7_01	[{"product_id": 68, "product_code": "5d22b162-c9c6-4540-ab8a-ff709f7148e3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa h\\u01b0\\u01a1ng vani Hoff 55g", "qty": 2, "unit_price": 65000.0}, {"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 1, "unit_price": 25000.0}, {"product_id": 195, "product_code": "0c817e5a-0d94-4f29-be97-bc218296a244", "name": "Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "qty": 2, "unit_price": 35000.0}]	3	225000	[{"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "score": 0.92}, {"product_id": 39, "product_code": "0e3740f8-9d6f-4f7b-b1bb-3b719c18c93b", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "score": 0.85}, {"product_id": 143, "product_code": "a3a7acbd-4cf2-4f56-9930-63c15fc00ecc", "name": "B\\u00e0n ch\\u1ea3i \\u0111\\u00e1nh r\\u0103ng Colgate", "score": 0.9}]	f	2026-03-15 01:19:14.887002
140	HCM_Q7	TXN-20260327-00140	2026-03-27 11:36:15.589598+00	1	EDGE_HCM_Q7_01	[{"product_id": 126, "product_code": "d487390c-5ffd-47eb-b891-e9feeaeb0830", "name": "Bia Tiger N\\u00e2u (Lon 330ml)", "qty": 3, "unit_price": 16000.0}]	1	48000	[{"product_id": 33, "product_code": "f5833d36-7b7f-4702-937f-8d1286c31a38", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "score": 0.67}, {"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "score": 0.81}]	f	2026-03-27 11:36:15.589598
81	HCM_Q7	TXN-20260308-00081	2026-03-08 19:04:14.897253+00	30	EDGE_HCM_Q7_01	[{"product_id": 30, "product_code": "f91639d0-6dfc-4083-a260-a2ad3c65eb41", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf g\\u00e0 \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 65g", "qty": 2, "unit_price": 43000.0}, {"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "qty": 2, "unit_price": 28500.0}, {"product_id": 11, "product_code": "c657b334-1d73-44af-b7cc-74d5d5bd1efa", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi \\u0111\\u1eadm \\u0111\\u1eb7c", "qty": 2, "unit_price": 35000.0}, {"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "qty": 1, "unit_price": 5000.0}]	4	218000	[{"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.64}, {"product_id": 90, "product_code": "61c35ff1-5a92-4568-9870-e345bc73a24c", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml", "score": 0.93}]	f	2026-03-08 19:04:14.897253
82	HN_CG	TXN-20260316-00082	2026-03-16 01:56:14.907475+00	1	EDGE_HN_CG_01	[{"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "qty": 1, "unit_price": 30000.0}, {"product_id": 147, "product_code": "3518ef51-5bc7-4266-bbc2-6ce2d3acbc53", "name": "Gi\\u1ea5y v\\u1ec7 sinh E'mos (L\\u1ed1c 10)", "qty": 2, "unit_price": 48000.0}, {"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "qty": 1, "unit_price": 33500.0}, {"product_id": 107, "product_code": "950bc1a0-a654-4c1f-937a-91b5753c75c0", "name": "M\\u00ec H\\u1ea3o H\\u1ea3o T\\u00f4m Chua Cay", "qty": 2, "unit_price": 3600.0}, {"product_id": 20, "product_code": "d9f8c780-f6e0-408f-9147-1072585bee2d", "name": "M\\u00ec Kokomi 90 t\\u00f4m chua cay g\\u00f3i 90g", "qty": 3, "unit_price": 3600.0}]	5	177500	[{"product_id": 101, "product_code": "26b41c6b-4f50-45ec-b945-2a2e9eb74025", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh c\\u00e1 v\\u1ecb t\\u00f4m n\\u01b0\\u1edbng m\\u00f4i \\u0111\\u1ecf Orion Marine Boy 35g", "score": 0.82}, {"product_id": 96, "product_code": "a903b525-93ec-4602-bf74-099d44d3ea67", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola h\\u01b0\\u01a1ng vani Gery Crunch Roll g\\u00f3i 23g", "score": 0.96}]	f	2026-03-16 01:56:14.907475
83	HN_CG	TXN-20260220-00083	2026-02-20 03:19:14.918028+00	18	EDGE_HN_CG_01	[{"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "qty": 3, "unit_price": 68000.0}, {"product_id": 2, "product_code": "76e07498-8366-4687-a82e-2a47ecd1e994", "name": "D\\u1ea7u th\\u1ef1c v\\u1eadt tinh luy\\u1ec7n C\\u00e1i L\\u00e2n", "qty": 3, "unit_price": 39100.0}, {"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "qty": 3, "unit_price": 142800.0}, {"product_id": 12, "product_code": "32c195be-0444-4c26-8b09-761cb0b32136", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi thanh d\\u1ecbu", "qty": 1, "unit_price": 22000.0}, {"product_id": 168, "product_code": "131a23d6-1d20-4d98-b9dd-2d0eb19e0b54", "name": "B\\u00f3ng \\u0111\\u00e8n LED \\u0110i\\u1ec7n Quang 20W", "qty": 1, "unit_price": 45000.0}]	5	816700	[{"product_id": 73, "product_code": "c57b5193-7c6a-4e72-be5f-bf08951cd0ec", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "score": 0.88}, {"product_id": 83, "product_code": "a0500366-8dd9-44bc-ad93-6e2f9241f1bf", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng d\\u1ee9a 12.5% chai 360ml", "score": 0.81}, {"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "score": 0.83}, {"product_id": 15, "product_code": "cebc7811-c35c-4a9d-8b37-854d28b07b22", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g", "score": 0.64}]	f	2026-02-20 03:19:14.918028
84	HCM_Q1	TXN-20260306-00084	2026-03-06 07:58:14.931767+00	\N	EDGE_HCM_Q1_01	[{"product_id": 100, "product_code": "46b1b7b5-3a08-4c49-96c5-44e9cf02c72d", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh quy socola Orion Miz 54g", "qty": 3, "unit_price": 246500.0}, {"product_id": 200, "product_code": "44e0b85c-6165-439b-84b4-6f85374c19e1", "name": "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "qty": 1, "unit_price": 70000.0}]	2	809500	[{"product_id": 111, "product_code": "39db55d0-6784-4457-900f-d85d7b17e783", "name": "H\\u1ea1t n\\u00eam Knorr (400g)", "score": 0.94}, {"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "score": 0.83}, {"product_id": 80, "product_code": "77e0bf6d-eb78-4ab7-8a73-d61458d018c6", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb vi\\u1ec7t qu\\u1ea5t 12% chai 360ml", "score": 0.74}]	t	2026-03-06 07:58:14.931767
85	HCM_Q7	TXN-20260219-00085	2026-02-19 04:34:14.954065+00	28	EDGE_HCM_Q7_01	[{"product_id": 158, "product_code": "8526f078-cb9e-4c78-ae7a-ab1526ddda7d", "name": "N\\u01b0\\u1edbc r\\u1eeda tay kh\\u00f4 (Chai 100ml)", "qty": 1, "unit_price": 30000.0}, {"product_id": 48, "product_code": "daa15e61-ad90-41f8-aecf-9db0eefdf004", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch v\\u1ecb socola Ovaltine b\\u1ed5 sung canxi 180ml", "qty": 3, "unit_price": 27200.0}, {"product_id": 112, "product_code": "26a9aea3-5f05-45b5-81af-801b4e2e9d24", "name": "B\\u1ed9t ng\\u1ecdt Ajinomoto (454g)", "qty": 2, "unit_price": 32000.0}]	3	175600	[{"product_id": 58, "product_code": "54ee9149-caee-4c90-9f0d-8a89945ffa5f", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.66}, {"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "score": 0.79}, {"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "score": 0.84}, {"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "score": 0.8}]	f	2026-02-19 04:34:14.954065
86	HCM_Q7	TXN-20260312-00086	2026-03-12 23:36:14.970242+00	\N	EDGE_HCM_Q7_01	[{"product_id": 64, "product_code": "0f123724-4435-43b5-a850-de579646313d", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua nha \\u0111am Nutimilk 100g", "qty": 3, "unit_price": 27900.0}, {"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "qty": 1, "unit_price": 7000.0}, {"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "qty": 1, "unit_price": 42000.0}]	3	132700	[{"product_id": 109, "product_code": "013d09af-48c5-4c50-9709-5b6183c5e8cc", "name": "D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An", "score": 0.85}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "score": 0.82}, {"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.7}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "score": 0.7}]	f	2026-03-12 23:36:14.970242
87	HCM_Q1	TXN-20260301-00087	2026-03-01 20:11:14.982209+00	46	EDGE_HCM_Q1_01	[{"product_id": 81, "product_code": "1485f5ea-a1a9-4383-98c4-338a415c5e3d", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb \\u0111\\u00e0o 12% chai 360ml", "qty": 3, "unit_price": 42750.0}, {"product_id": 151, "product_code": "4e6b1095-a3cb-4d03-b747-0b3080e9a160", "name": "X\\u00e0 b\\u00f4ng c\\u1ee5c X-Men", "qty": 2, "unit_price": 14250.0}, {"product_id": 186, "product_code": "da5a3390-cf73-4a9f-bffc-f6e02a0905b2", "name": "B\\u00fat bi Thi\\u00ean Long (C\\u00e2y)", "qty": 2, "unit_price": 3200.0}]	3	163150	[{"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "score": 0.63}, {"product_id": 48, "product_code": "daa15e61-ad90-41f8-aecf-9db0eefdf004", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch v\\u1ecb socola Ovaltine b\\u1ed5 sung canxi 180ml", "score": 0.97}]	f	2026-03-01 20:11:14.982209
117	HN_CG	TXN-20260323-00117	2026-03-23 08:02:15.338895+00	9	EDGE_HN_CG_01	[{"product_id": 16, "product_code": "9ce59ad8-ccbb-49de-9acf-155792a5655f", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o sa t\\u1ebf h\\u00e0nh t\\u00edm 75g", "qty": 2, "unit_price": 119000.0}]	1	238000	[{"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "score": 0.94}, {"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "score": 0.89}, {"product_id": 80, "product_code": "77e0bf6d-eb78-4ab7-8a73-d61458d018c6", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb vi\\u1ec7t qu\\u1ea5t 12% chai 360ml", "score": 0.66}, {"product_id": 150, "product_code": "8f4dc2fd-7d0d-449f-88a4-47cad03d38d2", "name": "T\\u00e3 qu\\u1ea7n Bobby (B\\u1ecbch M40)", "score": 0.72}]	f	2026-03-23 08:02:15.338895
88	HCM_Q1	TXN-20260220-00088	2026-02-20 18:08:14.996615+00	31	EDGE_HCM_Q1_01	[{"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "qty": 2, "unit_price": 40000.0}, {"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "qty": 3, "unit_price": 39000.0}, {"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "qty": 3, "unit_price": 68000.0}, {"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "qty": 2, "unit_price": 3800.0}]	4	408600	[{"product_id": 173, "product_code": "78a22c2f-8513-49ba-95df-227bbb48543e", "name": "Gi\\u1ea5y b\\u1ea1c n\\u01b0\\u1edbng (Cu\\u1ed9n)", "score": 0.65}, {"product_id": 102, "product_code": "81606b2f-15e4-4ffc-a73b-fe9afc07043e", "name": "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g", "score": 0.61}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.64}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "score": 0.61}]	f	2026-02-20 18:08:14.996615
89	HCM_Q1	TXN-20260322-00089	2026-03-22 02:12:15.008764+00	\N	EDGE_HCM_Q1_01	[{"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "qty": 1, "unit_price": 34000.0}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "qty": 1, "unit_price": 250000.0}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 1, "unit_price": 9600.0}, {"product_id": 198, "product_code": "2c790f44-7ee9-4c1d-9170-0f67eaf7e736", "name": "M\\u0169 b\\u1ea3o hi\\u1ec3m n\\u1eeda \\u0111\\u1ea7u", "qty": 1, "unit_price": 68000.0}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "qty": 3, "unit_price": 32000.0}]	5	457600	[{"product_id": 121, "product_code": "827e4a51-3225-4f53-a04f-e03b0e5b9f8d", "name": "S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "score": 0.82}, {"product_id": 6, "product_code": "4261ad1a-adce-4554-9710-a9edbdc16f52", "name": "N\\u01b0\\u1edbc ch\\u1ea5m Nam Ng\\u01b0 \\u0110\\u1ec7 Nh\\u1ecb", "score": 0.68}, {"product_id": 116, "product_code": "de0f18f5-f3b9-44bb-9d2d-ca990368168e", "name": "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "score": 0.82}]	f	2026-03-22 02:12:15.008764
90	HCM_Q7	TXN-20260216-00090	2026-02-16 02:25:15.023329+00	26	EDGE_HCM_Q7_01	[{"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "qty": 3, "unit_price": 22500.0}, {"product_id": 152, "product_code": "a544d61d-edb8-4b54-ad19-8f4745d8307a", "name": "S\\u1eefa r\\u1eeda m\\u1eb7t Acnes (100g)", "qty": 1, "unit_price": 52250.0}, {"product_id": 186, "product_code": "da5a3390-cf73-4a9f-bffc-f6e02a0905b2", "name": "B\\u00fat bi Thi\\u00ean Long (C\\u00e2y)", "qty": 3, "unit_price": 3200.0}, {"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 1, "unit_price": 25000.0}]	4	154350	[{"product_id": 142, "product_code": "11c60194-88d2-4816-997a-5553a8cb6196", "name": "Kem \\u0111\\u00e1nh r\\u0103ng P/S (180g)", "score": 0.94}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "score": 0.76}, {"product_id": 69, "product_code": "c6db64ee-92ea-4113-8297-a2e94c4f6be6", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa dinh d\\u01b0\\u1ee1ng Gotz 55g", "score": 0.78}]	t	2026-02-16 02:25:15.023329
91	HCM_Q7	TXN-20260221-00091	2026-02-21 20:18:15.037506+00	29	EDGE_HCM_Q7_01	[{"product_id": 130, "product_code": "260fa104-9d28-45a7-bb5e-06b373367221", "name": "B\\u00e1nh quy Cosy (G\\u00f3i 200g)", "qty": 3, "unit_price": 13500.0}, {"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "qty": 3, "unit_price": 10000.0}]	2	70500	[{"product_id": 76, "product_code": "aa017cb5-b496-42a5-9417-beec7b243112", "name": "Th\\u00f9ng 12 lon bia Hoegaarden Peach v\\u1ecb \\u0111\\u00e0o 500ml", "score": 0.87}, {"product_id": 186, "product_code": "da5a3390-cf73-4a9f-bffc-f6e02a0905b2", "name": "B\\u00fat bi Thi\\u00ean Long (C\\u00e2y)", "score": 0.96}]	f	2026-02-21 20:18:15.037506
92	HN_CG	TXN-20260221-00092	2026-02-21 02:33:15.050751+00	9	EDGE_HN_CG_01	[{"product_id": 52, "product_code": "ea03fd89-98bb-42ca-900a-59f1006717b8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "qty": 2, "unit_price": 298000.0}, {"product_id": 41, "product_code": "8c0bd0e0-9c72-4d67-9c29-61b269b31df8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 2, "unit_price": 355000.0}]	2	1306000	[{"product_id": 143, "product_code": "a3a7acbd-4cf2-4f56-9930-63c15fc00ecc", "name": "B\\u00e0n ch\\u1ea3i \\u0111\\u00e1nh r\\u0103ng Colgate", "score": 0.98}, {"product_id": 13, "product_code": "2bcfabb7-eedf-4da1-ad8c-f464bb3e5ee6", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Tam Th\\u00e1i T\\u1eed Nh\\u1ea5t Ca s\\u00e1nh \\u0111\\u1eadm", "score": 0.74}]	t	2026-02-21 02:33:15.050751
93	HN_CG	TXN-20260317-00093	2026-03-17 14:04:15.063296+00	\N	EDGE_HN_CG_01	[{"product_id": 111, "product_code": "39db55d0-6784-4457-900f-d85d7b17e783", "name": "H\\u1ea1t n\\u00eam Knorr (400g)", "qty": 1, "unit_price": 30400.0}, {"product_id": 30, "product_code": "f91639d0-6dfc-4083-a260-a2ad3c65eb41", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf g\\u00e0 \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 65g", "qty": 2, "unit_price": 43000.0}, {"product_id": 159, "product_code": "faa88516-1182-495d-981d-3a5f206d2770", "name": "S\\u00e1p kh\\u1eed m\\u00f9i ph\\u00f2ng (H\\u1ed9p)", "qty": 2, "unit_price": 40000.0}]	3	196400	[{"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "score": 0.93}, {"product_id": 12, "product_code": "32c195be-0444-4c26-8b09-761cb0b32136", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi thanh d\\u1ecbu", "score": 0.7}, {"product_id": 198, "product_code": "2c790f44-7ee9-4c1d-9170-0f67eaf7e736", "name": "M\\u0169 b\\u1ea3o hi\\u1ec3m n\\u1eeda \\u0111\\u1ea7u", "score": 0.66}]	f	2026-03-17 14:04:15.063296
94	HN_CG	TXN-20260325-00094	2026-03-25 11:59:15.07448+00	\N	EDGE_HN_CG_01	[{"product_id": 130, "product_code": "260fa104-9d28-45a7-bb5e-06b373367221", "name": "B\\u00e1nh quy Cosy (G\\u00f3i 200g)", "qty": 1, "unit_price": 13500.0}]	1	13500	[{"product_id": 41, "product_code": "8c0bd0e0-9c72-4d67-9c29-61b269b31df8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "score": 0.87}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "score": 0.89}, {"product_id": 75, "product_code": "adaf187e-c86b-4ead-a4fc-fa93d98d1735", "name": "Th\\u00f9ng 24 lon Bia Blanc 1664 330ml", "score": 0.79}]	f	2026-03-25 11:59:15.07448
95	HCM_Q7	TXN-20260313-00095	2026-03-13 01:29:15.085718+00	1	EDGE_HCM_Q7_01	[{"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 1, "unit_price": 52000.0}, {"product_id": 88, "product_code": "e26b7e68-b6d3-48b3-afc4-352c85e6962a", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb 390ml", "qty": 2, "unit_price": 118000.0}]	2	288000	[{"product_id": 93, "product_code": "204e5daa-e27a-42e2-ad34-d29fcb5d84a5", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 320ml", "score": 0.69}, {"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "score": 0.89}, {"product_id": 171, "product_code": "34b1c04a-0e91-4eaf-ae2d-f379c0324d29", "name": "Pin AAA Panasonic (V\\u1ec9 2 vi\\u00ean)", "score": 0.8}]	t	2026-03-13 01:29:15.085718
96	HCM_Q7	TXN-20260226-00096	2026-02-26 15:34:15.099166+00	\N	EDGE_HCM_Q7_01	[{"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "qty": 2, "unit_price": 425000.0}, {"product_id": 198, "product_code": "2c790f44-7ee9-4c1d-9170-0f67eaf7e736", "name": "M\\u0169 b\\u1ea3o hi\\u1ec3m n\\u1eeda \\u0111\\u1ea7u", "qty": 2, "unit_price": 68000.0}, {"product_id": 3, "product_code": "fb8b76f0-baea-440d-acf3-f80e738a7958", "name": "D\\u1ea7u \\u0103n th\\u01b0\\u1ee3ng h\\u1ea1ng Neptune Light", "qty": 2, "unit_price": 62100.0}, {"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "qty": 1, "unit_price": 5000.0}]	4	1115200	[{"product_id": 195, "product_code": "0c817e5a-0d94-4f29-be97-bc218296a244", "name": "Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "score": 0.95}, {"product_id": 10, "product_code": "63a338bb-de9f-45cb-b283-d0abab06015d", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Nh\\u1ecb Ca Tam Th\\u00e1i T\\u1eed chai", "score": 0.66}, {"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "score": 0.82}]	t	2026-02-26 15:34:15.099166
97	HCM_Q7	TXN-20260218-00097	2026-02-18 10:43:15.112782+00	\N	EDGE_HCM_Q7_01	[{"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 3, "unit_price": 25000.0}, {"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "qty": 3, "unit_price": 425000.0}, {"product_id": 180, "product_code": "8f382477-a9b4-44d6-bf2a-59fae61d9166", "name": "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "qty": 3, "unit_price": 19000.0}, {"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "qty": 3, "unit_price": 39000.0}, {"product_id": 115, "product_code": "11086cc9-d30a-4145-acaf-8e2084c851f0", "name": "T\\u01b0\\u01a1ng \\u1edbt Chinsu (250g)", "qty": 2, "unit_price": 12000.0}]	5	1548000	[{"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "score": 0.63}, {"product_id": 199, "product_code": "78df9983-9047-45ca-8867-aa9f19c6e3d6", "name": "\\u00c1o m\\u01b0a ti\\u1ec7n l\\u1ee3i (C\\u00e1i)", "score": 0.8}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "score": 0.75}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.87}]	f	2026-02-18 10:43:15.112782
98	HN_CG	TXN-20260304-00098	2026-03-04 01:32:15.126701+00	57	EDGE_HN_CG_01	[{"product_id": 152, "product_code": "a544d61d-edb8-4b54-ad19-8f4745d8307a", "name": "S\\u1eefa r\\u1eeda m\\u1eb7t Acnes (100g)", "qty": 3, "unit_price": 52250.0}, {"product_id": 67, "product_code": "a67c2aa4-d081-41f2-a440-30d00cd60c5b", "name": "L\\u1ed1c 2 h\\u0169 s\\u01b0\\u0303a chua n\\u00ea\\u0301p c\\u00e2\\u0309m Sa\\u0300i Go\\u0300n Milk 120g", "qty": 1, "unit_price": 27000.0}, {"product_id": 62, "product_code": "8e6ed997-217f-4dc4-ba92-611c2a6bbd91", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n \\u00edt \\u0111\\u01b0\\u1eddng Nutimilk 100g", "qty": 2, "unit_price": 26000.0}, {"product_id": 199, "product_code": "78df9983-9047-45ca-8867-aa9f19c6e3d6", "name": "\\u00c1o m\\u01b0a ti\\u1ec7n l\\u1ee3i (C\\u00e1i)", "qty": 2, "unit_price": 10000.0}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 3, "unit_price": 9600.0}]	5	284550	[{"product_id": 13, "product_code": "2bcfabb7-eedf-4da1-ad8c-f464bb3e5ee6", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng Tam Th\\u00e1i T\\u1eed Nh\\u1ea5t Ca s\\u00e1nh \\u0111\\u1eadm", "score": 0.85}, {"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "score": 0.65}]	f	2026-03-04 01:32:15.126701
99	HN_CG	TXN-20260316-00099	2026-03-16 14:19:15.139985+00	19	EDGE_HN_CG_01	[{"product_id": 173, "product_code": "78a22c2f-8513-49ba-95df-227bbb48543e", "name": "Gi\\u1ea5y b\\u1ea1c n\\u01b0\\u1edbng (Cu\\u1ed9n)", "qty": 3, "unit_price": 25000.0}, {"product_id": 36, "product_code": "6ea649b0-f9e4-44cb-9fb9-768d1889cdf6", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "qty": 3, "unit_price": 425000.0}, {"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "qty": 1, "unit_price": 15000.0}, {"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "qty": 2, "unit_price": 5000.0}, {"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "qty": 2, "unit_price": 7000.0}]	5	1389000	[{"product_id": 109, "product_code": "013d09af-48c5-4c50-9709-5b6183c5e8cc", "name": "D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An", "score": 0.62}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "score": 0.94}, {"product_id": 21, "product_code": "9ad51e21-230b-486c-abce-5487f7b09ed3", "name": "M\\u00ec H\\u1ea3o 100 t\\u00f4m chua cay g\\u00f3i 65g", "score": 0.78}, {"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "score": 0.77}]	t	2026-03-16 14:19:15.139985
100	HCM_Q7	TXN-20260227-00100	2026-02-27 13:08:15.153026+00	29	EDGE_HCM_Q7_01	[{"product_id": 188, "product_code": "4a5f7c93-02f6-48e0-bcb4-a1c7ae3aec53", "name": "B\\u00fat ch\\u00ec g\\u1ed7 2B", "qty": 3, "unit_price": 3000.0}, {"product_id": 107, "product_code": "950bc1a0-a654-4c1f-937a-91b5753c75c0", "name": "M\\u00ec H\\u1ea3o H\\u1ea3o T\\u00f4m Chua Cay", "qty": 2, "unit_price": 3600.0}, {"product_id": 42, "product_code": "13cbc909-c57c-4c13-8304-1abb2e7d16e6", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "qty": 1, "unit_price": 386750.0}, {"product_id": 37, "product_code": "6f831c1e-17cc-4ea1-848a-33cbc4c7ec9a", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 3, "unit_price": 375000.0}]	4	1527950	[{"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.78}, {"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "score": 0.88}, {"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "score": 0.96}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "score": 0.74}]	f	2026-02-27 13:08:15.153026
101	HCM_Q1	TXN-20260330-00101	2026-03-30 13:30:15.164644+00	20	EDGE_HCM_Q1_01	[{"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 3, "unit_price": 9600.0}, {"product_id": 76, "product_code": "aa017cb5-b496-42a5-9417-beec7b243112", "name": "Th\\u00f9ng 12 lon bia Hoegaarden Peach v\\u1ecb \\u0111\\u00e0o 500ml", "qty": 2, "unit_price": 445000.0}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "qty": 1, "unit_price": 18000.0}]	3	936800	[{"product_id": 73, "product_code": "c57b5193-7c6a-4e72-be5f-bf08951cd0ec", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "score": 0.91}, {"product_id": 56, "product_code": "c11379c8-f11b-4bc0-bc6b-32483cb53628", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p 170ml", "score": 0.79}, {"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "score": 0.65}]	f	2026-03-30 13:30:15.164644
102	HN_CG	TXN-20260323-00102	2026-03-23 00:59:15.178212+00	\N	EDGE_HN_CG_01	[{"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 2, "unit_price": 52000.0}, {"product_id": 185, "product_code": "cf4e420e-2ede-4a08-8209-0eaa5a110cf5", "name": "D\\u00e2y r\\u00fat nh\\u1ef1a (T\\u00fai 100 s\\u1ee3i)", "qty": 2, "unit_price": 12750.0}, {"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "qty": 3, "unit_price": 8000.0}, {"product_id": 34, "product_code": "15458477-33d0-4386-bf74-bc53f8887361", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 2, "unit_price": 337500.0}]	4	828500	[{"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.85}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "score": 0.76}, {"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "score": 0.69}, {"product_id": 160, "product_code": "d560d1cf-83fa-47da-9467-26fa419a73ba", "name": "Thu\\u1ed1c x\\u1ecbt mu\\u1ed7i Raid (600ml)", "score": 0.75}]	t	2026-03-23 00:59:15.178212
103	HN_CG	TXN-20260327-00103	2026-03-27 23:06:15.194693+00	8	EDGE_HN_CG_01	[{"product_id": 22, "product_code": "4f92b81a-203d-4ec7-b261-f1ffbe9b5ec4", "name": "M\\u00ec x\\u00e0o kh\\u00f4 Indomie Mi Goreng v\\u1ecb \\u0111\\u1eb7c bi\\u1ec7t g\\u00f3i 85g", "qty": 1, "unit_price": 5900.0}, {"product_id": 50, "product_code": "16150fd4-8086-42ac-a03a-6bcfd77425f2", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch BFAST b\\u1ed5 sung canxi 180ml", "qty": 2, "unit_price": 27000.0}, {"product_id": 159, "product_code": "faa88516-1182-495d-981d-3a5f206d2770", "name": "S\\u00e1p kh\\u1eed m\\u00f9i ph\\u00f2ng (H\\u1ed9p)", "qty": 3, "unit_price": 40000.0}, {"product_id": 139, "product_code": "efbd986b-4531-4883-afb4-194c9b59a109", "name": "B\\u1ed9t gi\\u1eb7t OMO (T\\u00fai 3kg)", "qty": 1, "unit_price": 125000.0}, {"product_id": 148, "product_code": "d6f2920e-e16a-4096-8159-a938f4b8ce59", "name": "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "qty": 1, "unit_price": 16200.0}]	5	321100	[{"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "score": 0.68}, {"product_id": 5, "product_code": "9258ca2f-5e05-4eac-be09-b5a69a4b9cd0", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0 nh\\u00e3n v\\u00e0ng 14 \\u0111\\u1ed9 \\u0111\\u1ea1m", "score": 0.92}, {"product_id": 71, "product_code": "bbd97816-ba62-4a9a-8384-7d7bff031ab1", "name": "Th\\u00f9ng 24 lon Bia Heineken Silver 250ml", "score": 0.92}, {"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "score": 0.82}]	f	2026-03-27 23:06:15.194693
104	HCM_Q1	TXN-20260311-00104	2026-03-11 05:23:15.209137+00	27	EDGE_HCM_Q1_01	[{"product_id": 136, "product_code": "53ec6e96-b534-42e0-a986-9d6d2d36e86d", "name": "D\\u1ea7u g\\u1ed9i Sunsilk (Chai 650g)", "qty": 1, "unit_price": 88000.0}]	1	88000	[{"product_id": 139, "product_code": "efbd986b-4531-4883-afb4-194c9b59a109", "name": "B\\u1ed9t gi\\u1eb7t OMO (T\\u00fai 3kg)", "score": 0.71}, {"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "score": 0.67}]	t	2026-03-11 05:23:15.209137
105	HCM_Q1	TXN-20260307-00105	2026-03-07 14:19:15.221507+00	46	EDGE_HCM_Q1_01	[{"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "qty": 1, "unit_price": 349000.0}]	1	349000	[{"product_id": 67, "product_code": "a67c2aa4-d081-41f2-a440-30d00cd60c5b", "name": "L\\u1ed1c 2 h\\u0169 s\\u01b0\\u0303a chua n\\u00ea\\u0301p c\\u00e2\\u0309m Sa\\u0300i Go\\u0300n Milk 120g", "score": 0.62}, {"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "score": 0.69}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.83}]	t	2026-03-07 14:19:15.221507
106	HCM_Q1	TXN-20260317-00106	2026-03-17 17:22:15.230909+00	30	EDGE_HCM_Q1_01	[{"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "qty": 3, "unit_price": 12350.0}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "qty": 3, "unit_price": 95200.0}, {"product_id": 124, "product_code": "4603c6b9-3f0e-4455-9c80-afad12742d51", "name": "N\\u01b0\\u1edbc su\\u1ed1i Aquafina (500ml)", "qty": 3, "unit_price": 4750.0}, {"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 1, "unit_price": 37050.0}, {"product_id": 163, "product_code": "5acdac1a-898e-4a9f-8acd-f8590ce29d7b", "name": "C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)", "qty": 1, "unit_price": 12000.0}]	5	385950	[{"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "score": 0.75}, {"product_id": 33, "product_code": "f5833d36-7b7f-4702-937f-8d1286c31a38", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "score": 0.63}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.84}, {"product_id": 146, "product_code": "fd9f259d-1ea9-4994-ae7d-d00f930fcde4", "name": "N\\u01b0\\u1edbc t\\u1ea9y b\\u1ed3n c\\u1ea7u Vim (900ml)", "score": 0.68}]	f	2026-03-17 17:22:15.230909
107	HN_CG	TXN-20260312-00107	2026-03-12 21:29:15.24064+00	\N	EDGE_HN_CG_01	[{"product_id": 116, "product_code": "de0f18f5-f3b9-44bb-9d2d-ca990368168e", "name": "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "qty": 1, "unit_price": 30000.0}, {"product_id": 11, "product_code": "c657b334-1d73-44af-b7cc-74d5d5bd1efa", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi \\u0111\\u1eadm \\u0111\\u1eb7c", "qty": 1, "unit_price": 35000.0}, {"product_id": 1, "product_code": "9583297f-78a6-4dfc-84a5-82f214b9e86e", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh tinh luy\\u1ec7n Janbee", "qty": 2, "unit_price": 69500.0}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "qty": 2, "unit_price": 32000.0}, {"product_id": 159, "product_code": "faa88516-1182-495d-981d-3a5f206d2770", "name": "S\\u00e1p kh\\u1eed m\\u00f9i ph\\u00f2ng (H\\u1ed9p)", "qty": 3, "unit_price": 40000.0}]	5	388000	[{"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "score": 0.82}, {"product_id": 90, "product_code": "61c35ff1-5a92-4568-9870-e345bc73a24c", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml", "score": 0.79}, {"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "score": 0.62}, {"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "score": 0.88}]	t	2026-03-12 21:29:15.24064
108	HN_CG	TXN-20260310-00108	2026-03-10 20:18:15.252994+00	\N	EDGE_HN_CG_01	[{"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 3, "unit_price": 25000.0}, {"product_id": 130, "product_code": "260fa104-9d28-45a7-bb5e-06b373367221", "name": "B\\u00e1nh quy Cosy (G\\u00f3i 200g)", "qty": 2, "unit_price": 13500.0}]	2	102000	[{"product_id": 116, "product_code": "de0f18f5-f3b9-44bb-9d2d-ca990368168e", "name": "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "score": 0.97}, {"product_id": 70, "product_code": "83bab65c-5e02-45a8-936d-58eaa4e206a2", "name": "Th\\u00f9ng 24 lon Bia Tiger lon 250ml", "score": 0.73}, {"product_id": 63, "product_code": "ffab1e43-67a3-4455-b9f5-ece65ebd4ebb", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n nha \\u0111am Lothamilk 100g", "score": 0.77}, {"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "score": 0.83}]	f	2026-03-10 20:18:15.252994
109	HCM_Q7	TXN-20260217-00109	2026-02-17 21:35:15.265003+00	35	EDGE_HCM_Q7_01	[{"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "qty": 3, "unit_price": 42500.0}]	1	127500	[{"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "score": 0.97}, {"product_id": 173, "product_code": "78a22c2f-8513-49ba-95df-227bbb48543e", "name": "Gi\\u1ea5y b\\u1ea1c n\\u01b0\\u1edbng (Cu\\u1ed9n)", "score": 0.74}, {"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.83}, {"product_id": 91, "product_code": "845e5e02-35a6-498e-9420-f6d30ae72b04", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Coca Cola 320ml", "score": 0.75}]	t	2026-02-17 21:35:15.265003
110	HCM_Q1	TXN-20260319-00110	2026-03-19 14:47:15.274566+00	49	EDGE_HCM_Q1_01	[{"product_id": 175, "product_code": "c55a887f-03c5-45e6-9934-5f8a9a007306", "name": "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "qty": 3, "unit_price": 10000.0}, {"product_id": 182, "product_code": "04931d60-d635-4729-8b9e-1171306f235b", "name": "N\\u1ebfn c\\u00e2y (G\\u00f3i 5 c\\u00e2y)", "qty": 3, "unit_price": 10000.0}, {"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "qty": 2, "unit_price": 17850.0}]	3	95700	[{"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "score": 0.97}, {"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "score": 0.61}]	f	2026-03-19 14:47:15.274566
133	HCM_Q7	TXN-20260323-00133	2026-03-23 01:47:15.521515+00	43	EDGE_HCM_Q7_01	[{"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "qty": 2, "unit_price": 15000.0}, {"product_id": 113, "product_code": "e7753b8d-850e-4de8-935e-b4cb3e98063a", "name": "\\u0110\\u01b0\\u1eddng tinh luy\\u1ec7n Bi\\u00ean H\\u00f2a (1kg)", "qty": 1, "unit_price": 17600.0}]	2	47600	[{"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "score": 0.67}, {"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "score": 0.65}]	t	2026-03-23 01:47:15.521515
111	HCM_Q7	TXN-20260216-00111	2026-02-16 18:03:15.284703+00	\N	EDGE_HCM_Q7_01	[{"product_id": 129, "product_code": "fb1ea21f-cda1-4678-a372-358a68f83a9c", "name": "K\\u1eb9o c\\u1ee9ng Dynamite", "qty": 3, "unit_price": 8000.0}, {"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "qty": 3, "unit_price": 28500.0}, {"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 3, "unit_price": 355000.0}, {"product_id": 142, "product_code": "11c60194-88d2-4816-997a-5553a8cb6196", "name": "Kem \\u0111\\u00e1nh r\\u0103ng P/S (180g)", "qty": 3, "unit_price": 28000.0}, {"product_id": 50, "product_code": "16150fd4-8086-42ac-a03a-6bcfd77425f2", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch BFAST b\\u1ed5 sung canxi 180ml", "qty": 1, "unit_price": 27000.0}]	5	1285500	[{"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "score": 0.65}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "score": 0.95}]	t	2026-02-16 18:03:15.284703
112	HCM_Q1	TXN-20260304-00112	2026-03-04 04:22:15.296027+00	42	EDGE_HCM_Q1_01	[{"product_id": 83, "product_code": "a0500366-8dd9-44bc-ad93-6e2f9241f1bf", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng d\\u1ee9a 12.5% chai 360ml", "qty": 1, "unit_price": 38250.0}]	1	38250	[{"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "score": 0.89}, {"product_id": 93, "product_code": "204e5daa-e27a-42e2-ad34-d29fcb5d84a5", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 320ml", "score": 0.94}, {"product_id": 133, "product_code": "7a904b8a-d0d0-4b76-95cf-4b2020758a9e", "name": "N\\u01b0\\u1edbc t\\u0103ng l\\u1ef1c Redbull (Lon)", "score": 0.69}]	f	2026-03-04 04:22:15.296027
113	HCM_Q1	TXN-20260316-00113	2026-03-16 19:12:15.305598+00	37	EDGE_HCM_Q1_01	[{"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "qty": 1, "unit_price": 5000.0}]	1	5000	[{"product_id": 43, "product_code": "d4bfaf6c-3b76-40b5-b6d1-ff43f5cd2555", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng v\\u1ecb t\\u1ef1 nhi\\u00ean TH true MILK Hilo 180ml", "score": 0.72}, {"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.84}]	f	2026-03-16 19:12:15.305598
114	HN_CG	TXN-20260316-00114	2026-03-16 06:46:15.313405+00	\N	EDGE_HN_CG_01	[{"product_id": 28, "product_code": "91aed179-28dd-4cb2-96db-44c239795d5f", "name": "Ph\\u1edf b\\u00f2 Vifon g\\u00f3i 90g (c\\u00f3 g\\u00f3i th\\u1ecbt th\\u1eadt)", "qty": 1, "unit_price": 17000.0}, {"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 2, "unit_price": 52000.0}]	2	121000	[{"product_id": 19, "product_code": "aca2f004-f76e-481b-abe7-d495d4a2d9d1", "name": "Th\\u00f9ng 24 ly m\\u00ec Handy H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 67g", "score": 0.83}, {"product_id": 199, "product_code": "78df9983-9047-45ca-8867-aa9f19c6e3d6", "name": "\\u00c1o m\\u01b0a ti\\u1ec7n l\\u1ee3i (C\\u00e1i)", "score": 0.77}]	f	2026-03-16 06:46:15.313405
115	HCM_Q7	TXN-20260304-00115	2026-03-04 15:33:15.320933+00	4	EDGE_HCM_Q7_01	[{"product_id": 15, "product_code": "cebc7811-c35c-4a9d-8b37-854d28b07b22", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g", "qty": 3, "unit_price": 110200.0}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 1, "unit_price": 9600.0}, {"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 3, "unit_price": 25000.0}, {"product_id": 161, "product_code": "d0ce3076-c06f-42af-ba23-221c0ee27198", "name": "Nhang mu\\u1ed7i (H\\u1ed9p 10 khoanh)", "qty": 1, "unit_price": 8000.0}]	4	423200	[{"product_id": 103, "product_code": "215bb35c-37c7-451d-8a5e-19d774e2ec28", "name": "B\\u00e1nh quy socola chip nh\\u00e2n socola Parle Platina Hide & Seek g\\u00f3i 112.5g", "score": 0.89}, {"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.69}, {"product_id": 159, "product_code": "faa88516-1182-495d-981d-3a5f206d2770", "name": "S\\u00e1p kh\\u1eed m\\u00f9i ph\\u00f2ng (H\\u1ed9p)", "score": 0.83}]	t	2026-03-04 15:33:15.320933
116	HN_CG	TXN-20260226-00116	2026-02-26 07:02:15.329627+00	44	EDGE_HN_CG_01	[{"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "qty": 1, "unit_price": 18000.0}]	1	18000	[{"product_id": 153, "product_code": "0fae3be1-0f57-4a82-aba9-d13e180c1943", "name": "Dao c\\u1ea1o r\\u00e2u Gillette (C\\u00e2y)", "score": 0.63}, {"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "score": 0.9}]	t	2026-02-26 07:02:15.329627
118	HN_CG	TXN-20260219-00118	2026-02-19 10:49:15.348461+00	33	EDGE_HN_CG_01	[{"product_id": 14, "product_code": "7d31d029-8f17-4074-ad5e-96f50b6b9465", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en", "qty": 1, "unit_price": 41000.0}, {"product_id": 109, "product_code": "013d09af-48c5-4c50-9709-5b6183c5e8cc", "name": "D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An", "qty": 2, "unit_price": 48000.0}, {"product_id": 89, "product_code": "4362ec25-fdc1-4b2a-9588-6642962e5302", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Pepsi Cola 390ml", "qty": 1, "unit_price": 118000.0}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "qty": 3, "unit_price": 298000.0}, {"product_id": 52, "product_code": "ea03fd89-98bb-42ca-900a-59f1006717b8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "qty": 2, "unit_price": 298000.0}]	5	1745000	[{"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "score": 0.92}, {"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "score": 0.82}, {"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.73}]	f	2026-02-19 10:49:15.348461
119	HCM_Q1	TXN-20260301-00119	2026-03-01 22:26:15.358281+00	1	EDGE_HCM_Q1_01	[{"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "qty": 1, "unit_price": 40000.0}, {"product_id": 59, "product_code": "b9c6ad3b-cba2-4de1-96f6-b27fe38a368f", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "qty": 2, "unit_price": 24650.0}]	2	89300	[{"product_id": 190, "product_code": "91a2bcb3-d18b-47dc-ab24-5af040967bf2", "name": "Th\\u01b0\\u1edbc k\\u1ebb 20cm", "score": 0.75}, {"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "score": 0.91}, {"product_id": 53, "product_code": "d5b1b057-5bcf-4629-a973-7f8e9c0bca3c", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "score": 0.6}]	f	2026-03-01 22:26:15.358281
120	HCM_Q7	TXN-20260319-00120	2026-03-19 08:28:15.367844+00	38	EDGE_HCM_Q7_01	[{"product_id": 12, "product_code": "32c195be-0444-4c26-8b09-761cb0b32136", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi thanh d\\u1ecbu", "qty": 1, "unit_price": 22000.0}, {"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 2, "unit_price": 37050.0}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "qty": 3, "unit_price": 298000.0}]	3	990100	[{"product_id": 63, "product_code": "ffab1e43-67a3-4455-b9f5-ece65ebd4ebb", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n nha \\u0111am Lothamilk 100g", "score": 0.67}, {"product_id": 46, "product_code": "8636600f-9b6f-4cb4-a120-cf70c55c20e6", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "score": 0.7}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "score": 0.64}, {"product_id": 6, "product_code": "4261ad1a-adce-4554-9710-a9edbdc16f52", "name": "N\\u01b0\\u1edbc ch\\u1ea5m Nam Ng\\u01b0 \\u0110\\u1ec7 Nh\\u1ecb", "score": 0.92}]	t	2026-03-19 08:28:15.367844
121	HCM_Q7	TXN-20260220-00121	2026-02-20 03:43:15.383791+00	24	EDGE_HCM_Q7_01	[{"product_id": 135, "product_code": "c7f42ff3-6047-4f08-866c-1b32209e3f90", "name": "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "qty": 3, "unit_price": 18000.0}, {"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "qty": 1, "unit_price": 19000.0}]	2	73000	[{"product_id": 204, "product_code": "e03863a3-5056-43ed-af9e-77bdb148f682", "name": "C\\u1ee7 s\\u1ea1c USB 2 c\\u1ed5ng", "score": 0.67}, {"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "score": 0.74}]	t	2026-02-20 03:43:15.383791
122	HCM_Q1	TXN-20260316-00122	2026-03-16 15:59:15.398062+00	\N	EDGE_HCM_Q1_01	[{"product_id": 203, "product_code": "cd3322e6-fa79-4ff1-9ec1-017716f5f8af", "name": "C\\u00e1p s\\u1ea1c Android/iPhone", "qty": 2, "unit_price": 40000.0}, {"product_id": 39, "product_code": "0e3740f8-9d6f-4f7b-b1bb-3b719c18c93b", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "qty": 1, "unit_price": 330000.0}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "qty": 3, "unit_price": 45000.0}]	3	545000	[{"product_id": 54, "product_code": "c5544e90-b58e-4a17-89af-5f131087703b", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "score": 0.9}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "score": 0.9}, {"product_id": 21, "product_code": "9ad51e21-230b-486c-abce-5487f7b09ed3", "name": "M\\u00ec H\\u1ea3o 100 t\\u00f4m chua cay g\\u00f3i 65g", "score": 0.83}]	f	2026-03-16 15:59:15.398062
123	HCM_Q7	TXN-20260218-00123	2026-02-18 22:58:15.409612+00	31	EDGE_HCM_Q7_01	[{"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 1, "unit_price": 52000.0}, {"product_id": 69, "product_code": "c6db64ee-92ea-4113-8297-a2e94c4f6be6", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa dinh d\\u01b0\\u1ee1ng Gotz 55g", "qty": 1, "unit_price": 34500.0}, {"product_id": 149, "product_code": "37ee0bd9-0b99-403e-96ab-f314af9c2e8e", "name": "B\\u0103ng v\\u1ec7 sinh Diana (G\\u00f3i 8)", "qty": 1, "unit_price": 16200.0}, {"product_id": 103, "product_code": "215bb35c-37c7-451d-8a5e-19d774e2ec28", "name": "B\\u00e1nh quy socola chip nh\\u00e2n socola Parle Platina Hide & Seek g\\u00f3i 112.5g", "qty": 1, "unit_price": 26000.0}]	4	128700	[{"product_id": 102, "product_code": "81606b2f-15e4-4ffc-a73b-fe9afc07043e", "name": "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g", "score": 0.72}, {"product_id": 56, "product_code": "c11379c8-f11b-4bc0-bc6b-32483cb53628", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p 170ml", "score": 0.94}]	f	2026-02-18 22:58:15.409612
124	HCM_Q1	TXN-20260302-00124	2026-03-02 01:00:15.420859+00	23	EDGE_HCM_Q1_01	[{"product_id": 150, "product_code": "8f4dc2fd-7d0d-449f-88a4-47cad03d38d2", "name": "T\\u00e3 qu\\u1ea7n Bobby (B\\u1ecbch M40)", "qty": 2, "unit_price": 210000.0}, {"product_id": 11, "product_code": "c657b334-1d73-44af-b7cc-74d5d5bd1efa", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi \\u0111\\u1eadm \\u0111\\u1eb7c", "qty": 2, "unit_price": 35000.0}]	2	490000	[{"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "score": 0.72}, {"product_id": 95, "product_code": "0f57e196-eacf-4d9f-89a6-5fdd236a80c9", "name": "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "score": 0.75}, {"product_id": 128, "product_code": "a010e906-1854-42a0-944b-8bcd42f82e55", "name": "Snack Khoai t\\u00e2y O'Star", "score": 0.67}]	f	2026-03-02 01:00:15.420859
125	HN_CG	TXN-20260327-00125	2026-03-27 06:37:15.430833+00	60	EDGE_HN_CG_01	[{"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "qty": 3, "unit_price": 11500.0}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 1, "unit_price": 170000.0}]	2	204500	[{"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.91}, {"product_id": 65, "product_code": "0433b59d-902c-4298-8e26-55d4ccbaf182", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n kh\\u00f4ng \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "score": 0.86}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.7}, {"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "score": 0.87}]	t	2026-03-27 06:37:15.430833
126	HCM_Q7	TXN-20260322-00126	2026-03-22 05:25:15.442065+00	\N	EDGE_HCM_Q7_01	[{"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "qty": 1, "unit_price": 8500.0}, {"product_id": 168, "product_code": "131a23d6-1d20-4d98-b9dd-2d0eb19e0b54", "name": "B\\u00f3ng \\u0111\\u00e8n LED \\u0110i\\u1ec7n Quang 20W", "qty": 3, "unit_price": 45000.0}, {"product_id": 4, "product_code": "2552366a-29a2-46a3-943a-3d8fb45b3fad", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "qty": 3, "unit_price": 59000.0}, {"product_id": 121, "product_code": "827e4a51-3225-4f53-a04f-e03b0e5b9f8d", "name": "S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "qty": 1, "unit_price": 26000.0}, {"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "qty": 2, "unit_price": 22500.0}]	5	391500	[{"product_id": 202, "product_code": "0a2dc91b-cdf6-46b2-99d4-697dbd70067f", "name": "Tai nghe c\\u00f3 d\\u00e2y (C\\u00e1i)", "score": 0.87}, {"product_id": 142, "product_code": "11c60194-88d2-4816-997a-5553a8cb6196", "name": "Kem \\u0111\\u00e1nh r\\u0103ng P/S (180g)", "score": 0.78}, {"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "score": 0.9}, {"product_id": 120, "product_code": "95bd5a46-0188-4553-927a-64cb57498ebc", "name": "L\\u1ed1c 4 s\\u1eefa chua Vinamilk", "score": 0.72}]	t	2026-03-22 05:25:15.442065
127	HCM_Q7	TXN-20260217-00127	2026-02-17 06:18:15.453051+00	9	EDGE_HCM_Q7_01	[{"product_id": 189, "product_code": "93e833a2-fb76-46e8-90d0-51b4a2067b2a", "name": "G\\u00f4m t\\u1ea9y (C\\u1ee5c)", "qty": 1, "unit_price": 5000.0}, {"product_id": 3, "product_code": "fb8b76f0-baea-440d-acf3-f80e738a7958", "name": "D\\u1ea7u \\u0103n th\\u01b0\\u1ee3ng h\\u1ea1ng Neptune Light", "qty": 2, "unit_price": 62100.0}, {"product_id": 128, "product_code": "a010e906-1854-42a0-944b-8bcd42f82e55", "name": "Snack Khoai t\\u00e2y O'Star", "qty": 2, "unit_price": 9500.0}]	3	148200	[{"product_id": 196, "product_code": "c2e580f2-5d4f-48aa-8b5a-e9e74fc29bfe", "name": "B\\u0103ng c\\u00e1 nh\\u00e2n Urgo (H\\u1ed9p 100)", "score": 0.8}, {"product_id": 200, "product_code": "44e0b85c-6165-439b-84b4-6f85374c19e1", "name": "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "score": 0.72}, {"product_id": 177, "product_code": "991f1b12-1dc2-498a-83bb-75bf860ad56b", "name": "K\\u1eb9p qu\\u1ea7n \\u00e1o (V\\u1ec9 20)", "score": 0.61}]	f	2026-02-17 06:18:15.453051
128	HN_CG	TXN-20260225-00128	2026-02-25 05:27:15.464955+00	\N	EDGE_HN_CG_01	[{"product_id": 101, "product_code": "26b41c6b-4f50-45ec-b945-2a2e9eb74025", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh c\\u00e1 v\\u1ecb t\\u00f4m n\\u01b0\\u1edbng m\\u00f4i \\u0111\\u1ecf Orion Marine Boy 35g", "qty": 2, "unit_price": 260000.0}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "qty": 1, "unit_price": 95200.0}]	2	615200	[{"product_id": 164, "product_code": "5576682c-00ee-4aab-8888-3526e2bf7626", "name": "Bao tay cao su (\\u0110\\u00f4i)", "score": 0.67}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "score": 0.86}, {"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "score": 0.67}]	t	2026-02-25 05:27:15.464955
129	HCM_Q7	TXN-20260331-00129	2026-03-31 12:19:15.475678+00	43	EDGE_HCM_Q7_01	[{"product_id": 18, "product_code": "fc0359c0-800a-40c9-8e49-660ab593f7e3", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "qty": 2, "unit_price": 105300.0}, {"product_id": 117, "product_code": "44ff85fd-7cc4-4731-9c5d-a8da1e1f1c6f", "name": "X\\u00fac x\\u00edch Vissan (G\\u00f3i 5 c\\u00e2y)", "qty": 2, "unit_price": 18000.0}, {"product_id": 15, "product_code": "cebc7811-c35c-4a9d-8b37-854d28b07b22", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g", "qty": 1, "unit_price": 110200.0}, {"product_id": 95, "product_code": "0f57e196-eacf-4d9f-89a6-5fdd236a80c9", "name": "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "qty": 1, "unit_price": 22950.0}, {"product_id": 133, "product_code": "7a904b8a-d0d0-4b76-95cf-4b2020758a9e", "name": "N\\u01b0\\u1edbc t\\u0103ng l\\u1ef1c Redbull (Lon)", "qty": 1, "unit_price": 12000.0}]	5	391750	[{"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "score": 0.96}, {"product_id": 18, "product_code": "fc0359c0-800a-40c9-8e49-660ab593f7e3", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec Kokomi 90 t\\u00f4m chua cay 90g", "score": 0.93}, {"product_id": 100, "product_code": "46b1b7b5-3a08-4c49-96c5-44e9cf02c72d", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh quy socola Orion Miz 54g", "score": 0.65}]	f	2026-03-31 12:19:15.475678
139	HCM_Q7	TXN-20260304-00139	2026-03-04 20:47:15.579431+00	21	EDGE_HCM_Q7_01	[{"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "qty": 2, "unit_price": 7000.0}]	1	14000	[{"product_id": 188, "product_code": "4a5f7c93-02f6-48e0-bcb4-a1c7ae3aec53", "name": "B\\u00fat ch\\u00ec g\\u1ed7 2B", "score": 0.73}, {"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.68}]	f	2026-03-04 20:47:15.579431
130	HCM_Q1	TXN-20260303-00130	2026-03-03 14:47:15.48747+00	33	EDGE_HCM_Q1_01	[{"product_id": 71, "product_code": "bbd97816-ba62-4a9a-8384-7d7bff031ab1", "name": "Th\\u00f9ng 24 lon Bia Heineken Silver 250ml", "qty": 2, "unit_price": 355000.0}, {"product_id": 52, "product_code": "ea03fd89-98bb-42ca-900a-59f1006717b8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "qty": 3, "unit_price": 298000.0}, {"product_id": 2, "product_code": "76e07498-8366-4687-a82e-2a47ecd1e994", "name": "D\\u1ea7u th\\u1ef1c v\\u1eadt tinh luy\\u1ec7n C\\u00e1i L\\u00e2n", "qty": 1, "unit_price": 39100.0}, {"product_id": 37, "product_code": "6f831c1e-17cc-4ea1-848a-33cbc4c7ec9a", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 3, "unit_price": 375000.0}]	4	2768100	[{"product_id": 126, "product_code": "d487390c-5ffd-47eb-b891-e9feeaeb0830", "name": "Bia Tiger N\\u00e2u (Lon 330ml)", "score": 0.61}, {"product_id": 118, "product_code": "071cea0f-3714-449f-b21f-86ddce66fd4d", "name": "C\\u00e1 h\\u1ed9p 3 C\\u00f4 G\\u00e1i", "score": 0.63}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "score": 0.85}, {"product_id": 148, "product_code": "d6f2920e-e16a-4096-8159-a938f4b8ce59", "name": "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "score": 0.95}]	t	2026-03-03 14:47:15.48747
131	HCM_Q1	TXN-20260319-00131	2026-03-19 19:03:15.500713+00	58	EDGE_HCM_Q1_01	[{"product_id": 188, "product_code": "4a5f7c93-02f6-48e0-bcb4-a1c7ae3aec53", "name": "B\\u00fat ch\\u00ec g\\u1ed7 2B", "qty": 1, "unit_price": 3000.0}, {"product_id": 111, "product_code": "39db55d0-6784-4457-900f-d85d7b17e783", "name": "H\\u1ea1t n\\u00eam Knorr (400g)", "qty": 2, "unit_price": 30400.0}, {"product_id": 118, "product_code": "071cea0f-3714-449f-b21f-86ddce66fd4d", "name": "C\\u00e1 h\\u1ed9p 3 C\\u00f4 G\\u00e1i", "qty": 3, "unit_price": 20000.0}, {"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "qty": 1, "unit_price": 35500.0}, {"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "qty": 1, "unit_price": 68000.0}]	5	227300	[{"product_id": 71, "product_code": "bbd97816-ba62-4a9a-8384-7d7bff031ab1", "name": "Th\\u00f9ng 24 lon Bia Heineken Silver 250ml", "score": 0.8}, {"product_id": 161, "product_code": "d0ce3076-c06f-42af-ba23-221c0ee27198", "name": "Nhang mu\\u1ed7i (H\\u1ed9p 10 khoanh)", "score": 0.85}]	f	2026-03-19 19:03:15.500713
132	HCM_Q1	TXN-20260321-00132	2026-03-21 09:26:15.511977+00	7	EDGE_HCM_Q1_01	[{"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "qty": 3, "unit_price": 30000.0}, {"product_id": 200, "product_code": "44e0b85c-6165-439b-84b4-6f85374c19e1", "name": "D\\u00f9 c\\u1ea7m tay g\\u1ea5p g\\u1ecdn", "qty": 1, "unit_price": 70000.0}, {"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "qty": 2, "unit_price": 45000.0}, {"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "qty": 1, "unit_price": 12350.0}, {"product_id": 116, "product_code": "de0f18f5-f3b9-44bb-9d2d-ca990368168e", "name": "Tr\\u1ee9ng g\\u00e0 t\\u01b0\\u01a1i (V\\u1ec9 10 qu\\u1ea3)", "qty": 1, "unit_price": 30000.0}]	5	292350	[{"product_id": 192, "product_code": "b812638a-f73d-4a60-9695-eac88da8a809", "name": "B\\u1ea5m kim s\\u1ed1 10 (C\\u00e1i)", "score": 0.88}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "score": 0.93}, {"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "score": 0.75}, {"product_id": 88, "product_code": "e26b7e68-b6d3-48b3-afc4-352c85e6962a", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb 390ml", "score": 0.6}]	f	2026-03-21 09:26:15.511977
134	HCM_Q7	TXN-20260216-00134	2026-02-16 00:26:15.531787+00	12	EDGE_HCM_Q7_01	[{"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "qty": 2, "unit_price": 15000.0}, {"product_id": 9, "product_code": "e4c1b87f-da03-460d-970f-cccf1b363bc7", "name": "N\\u01b0\\u1edbc m\\u1eafm Chinsu c\\u00e1 c\\u01a1m bi\\u1ec3n \\u0111\\u00f4ng 25 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 3, "unit_price": 48450.0}]	2	175350	[{"product_id": 134, "product_code": "f321fc35-eb7c-428c-a6bd-77a3f0df00a4", "name": "Tr\\u00e0 xanh C2 (Chai 360ml)", "score": 0.85}, {"product_id": 165, "product_code": "e7082b36-2f83-4c1f-a986-57c985941c24", "name": "T\\u00fai \\u0111\\u1ef1ng r\\u00e1c (Cu\\u1ed9n 3 m\\u00e0u)", "score": 0.64}, {"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "score": 0.86}, {"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "score": 0.77}]	t	2026-02-16 00:26:15.531787
135	HCM_Q1	TXN-20260305-00135	2026-03-05 17:39:15.541947+00	\N	EDGE_HCM_Q1_01	[{"product_id": 24, "product_code": "0c8ccc68-ac2a-4543-99d6-166020d0dbfa", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng s\\u01b0\\u1eddn heo 55g", "qty": 2, "unit_price": 250000.0}, {"product_id": 5, "product_code": "9258ca2f-5e05-4eac-be09-b5a69a4b9cd0", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0 nh\\u00e3n v\\u00e0ng 14 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 1, "unit_price": 41500.0}]	2	541500	[{"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.9}, {"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.92}]	f	2026-03-05 17:39:15.541947
136	HCM_Q7	TXN-20260325-00136	2026-03-25 06:19:15.550524+00	60	EDGE_HCM_Q7_01	[{"product_id": 102, "product_code": "81606b2f-15e4-4ffc-a73b-fe9afc07043e", "name": "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g", "qty": 1, "unit_price": 21250.0}, {"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "qty": 1, "unit_price": 42000.0}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 2, "unit_price": 170000.0}, {"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "qty": 3, "unit_price": 20800.0}, {"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "qty": 2, "unit_price": 37000.0}]	5	539650	[{"product_id": 118, "product_code": "071cea0f-3714-449f-b21f-86ddce66fd4d", "name": "C\\u00e1 h\\u1ed9p 3 C\\u00f4 G\\u00e1i", "score": 0.63}, {"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "score": 0.91}]	t	2026-03-25 06:19:15.550524
137	HCM_Q7	TXN-20260224-00137	2026-02-24 23:29:15.560229+00	\N	EDGE_HCM_Q7_01	[{"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "qty": 2, "unit_price": 15000.0}]	1	30000	[{"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.86}, {"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "score": 0.97}, {"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "score": 0.86}, {"product_id": 100, "product_code": "46b1b7b5-3a08-4c49-96c5-44e9cf02c72d", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh quy socola Orion Miz 54g", "score": 0.73}]	f	2026-02-24 23:29:15.560229
138	HN_CG	TXN-20260329-00138	2026-03-29 21:51:15.569782+00	46	EDGE_HN_CG_01	[{"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "qty": 1, "unit_price": 20800.0}]	1	20800	[{"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "score": 0.63}, {"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "score": 0.65}, {"product_id": 63, "product_code": "ffab1e43-67a3-4455-b9f5-ece65ebd4ebb", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n nha \\u0111am Lothamilk 100g", "score": 0.79}, {"product_id": 159, "product_code": "faa88516-1182-495d-981d-3a5f206d2770", "name": "S\\u00e1p kh\\u1eed m\\u00f9i ph\\u00f2ng (H\\u1ed9p)", "score": 0.68}]	t	2026-03-29 21:51:15.569782
141	HCM_Q7	TXN-20260312-00141	2026-03-12 23:11:15.60126+00	16	EDGE_HCM_Q7_01	[{"product_id": 46, "product_code": "8636600f-9b6f-4cb4-a120-cf70c55c20e6", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "qty": 3, "unit_price": 31500.0}, {"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "qty": 1, "unit_price": 8000.0}, {"product_id": 64, "product_code": "0f123724-4435-43b5-a850-de579646313d", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua nha \\u0111am Nutimilk 100g", "qty": 2, "unit_price": 27900.0}, {"product_id": 78, "product_code": "23ac668a-0cd2-437b-8ff2-4e7f09f1f70e", "name": "Bia L\\u1ea1c Vi\\u1ec7t lon 330ml", "qty": 2, "unit_price": 9600.0}]	4	177500	[{"product_id": 102, "product_code": "81606b2f-15e4-4ffc-a73b-fe9afc07043e", "name": "B\\u00e1nh quy socola chip nh\\u00e2n kem d\\u00e2u Parle Platina Hide & Seek g\\u00f3i 112.5g", "score": 0.78}, {"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "score": 0.76}, {"product_id": 43, "product_code": "d4bfaf6c-3b76-40b5-b6d1-ff43f5cd2555", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng v\\u1ecb t\\u1ef1 nhi\\u00ean TH true MILK Hilo 180ml", "score": 0.83}]	t	2026-03-12 23:11:15.60126
142	HCM_Q1	TXN-20260312-00142	2026-03-12 03:21:15.610577+00	10	EDGE_HCM_Q1_01	[{"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 2, "unit_price": 6800.0}, {"product_id": 45, "product_code": "70aecc30-273a-4640-ae9e-bf45c96ba51b", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng lof Kun 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 3, "unit_price": 376000.0}, {"product_id": 66, "product_code": "59989980-7fbb-4c6a-bf32-5d2cb1fa21c5", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Happy Star Vinamilk 100g", "qty": 3, "unit_price": 25500.0}, {"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "qty": 2, "unit_price": 65000.0}, {"product_id": 119, "product_code": "b3278e99-958a-4236-81bc-9cd0c9604c9c", "name": "L\\u1ed1c 4 s\\u1eefa t\\u01b0\\u01a1i TH True Milk", "qty": 1, "unit_price": 32000.0}]	5	1380100	[{"product_id": 121, "product_code": "827e4a51-3225-4f53-a04f-e03b0e5b9f8d", "name": "S\\u1eefa \\u0111\\u1eb7c \\u00d4ng Th\\u1ecd (Lon)", "score": 0.6}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "score": 0.93}, {"product_id": 40, "product_code": "662bdd0b-b218-4630-b448-3d2702743375", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t TH true MILK 180ml", "score": 0.88}, {"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "score": 0.74}]	t	2026-03-12 03:21:15.610577
143	HCM_Q7	TXN-20260329-00143	2026-03-29 14:15:15.620842+00	38	EDGE_HCM_Q7_01	[{"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "qty": 3, "unit_price": 12350.0}]	1	37050	[{"product_id": 66, "product_code": "59989980-7fbb-4c6a-bf32-5d2cb1fa21c5", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Happy Star Vinamilk 100g", "score": 0.87}, {"product_id": 198, "product_code": "2c790f44-7ee9-4c1d-9170-0f67eaf7e736", "name": "M\\u0169 b\\u1ea3o hi\\u1ec3m n\\u1eeda \\u0111\\u1ea7u", "score": 0.79}, {"product_id": 193, "product_code": "057d7a10-7e86-4899-a4d3-2bbb14ab8e8d", "name": "B\\u00eca h\\u1ed3 s\\u01a1 Clearbag (C\\u00e1i)", "score": 0.79}]	t	2026-03-29 14:15:15.620842
144	HCM_Q1	TXN-20260329-00144	2026-03-29 18:57:15.634038+00	53	EDGE_HCM_Q1_01	[{"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "qty": 3, "unit_price": 12000.0}, {"product_id": 181, "product_code": "e483f862-1cbe-45fd-bdb1-169e28072fc2", "name": "B\\u1eadt l\\u1eeda gas", "qty": 1, "unit_price": 3000.0}, {"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "qty": 2, "unit_price": 4750.0}]	3	48500	[{"product_id": 38, "product_code": "bd3729b1-38e4-4118-8d61-d2cb460b770e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "score": 0.82}, {"product_id": 66, "product_code": "59989980-7fbb-4c6a-bf32-5d2cb1fa21c5", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Happy Star Vinamilk 100g", "score": 0.85}, {"product_id": 64, "product_code": "0f123724-4435-43b5-a850-de579646313d", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua nha \\u0111am Nutimilk 100g", "score": 0.66}, {"product_id": 155, "product_code": "4dd70e94-850f-406f-a440-c4a161d99325", "name": "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "score": 0.64}]	f	2026-03-29 18:57:15.634038
145	HCM_Q1	TXN-20260215-00145	2026-02-15 08:07:15.642691+00	\N	EDGE_HCM_Q1_01	[{"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "qty": 3, "unit_price": 42000.0}, {"product_id": 65, "product_code": "0433b59d-902c-4298-8e26-55d4ccbaf182", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n kh\\u00f4ng \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "qty": 3, "unit_price": 26000.0}]	2	204000	[{"product_id": 79, "product_code": "dcf4b890-c91e-4ef3-bf6e-b4433d191182", "name": "Bia Corona Extra chai 250ml", "score": 0.93}, {"product_id": 188, "product_code": "4a5f7c93-02f6-48e0-bcb4-a1c7ae3aec53", "name": "B\\u00fat ch\\u00ec g\\u1ed7 2B", "score": 0.88}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "score": 0.63}, {"product_id": 193, "product_code": "057d7a10-7e86-4899-a4d3-2bbb14ab8e8d", "name": "B\\u00eca h\\u1ed3 s\\u01a1 Clearbag (C\\u00e1i)", "score": 0.84}]	f	2026-02-15 08:07:15.642691
146	HCM_Q1	TXN-20260304-00146	2026-03-04 12:28:15.652541+00	5	EDGE_HCM_Q1_01	[{"product_id": 135, "product_code": "c7f42ff3-6047-4f08-866c-1b32209e3f90", "name": "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "qty": 2, "unit_price": 18000.0}, {"product_id": 107, "product_code": "950bc1a0-a654-4c1f-937a-91b5753c75c0", "name": "M\\u00ec H\\u1ea3o H\\u1ea3o T\\u00f4m Chua Cay", "qty": 1, "unit_price": 3600.0}, {"product_id": 168, "product_code": "131a23d6-1d20-4d98-b9dd-2d0eb19e0b54", "name": "B\\u00f3ng \\u0111\\u00e8n LED \\u0110i\\u1ec7n Quang 20W", "qty": 3, "unit_price": 45000.0}, {"product_id": 74, "product_code": "bfc156f1-4268-4720-ba38-b2f6882dc6bd", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 250ml", "qty": 1, "unit_price": 276000.0}]	4	450600	[{"product_id": 129, "product_code": "fb1ea21f-cda1-4678-a372-358a68f83a9c", "name": "K\\u1eb9o c\\u1ee9ng Dynamite", "score": 0.77}, {"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "score": 0.91}]	t	2026-03-04 12:28:15.652541
147	HCM_Q1	TXN-20260219-00147	2026-02-19 12:34:15.662096+00	\N	EDGE_HCM_Q1_01	[{"product_id": 113, "product_code": "e7753b8d-850e-4de8-935e-b4cb3e98063a", "name": "\\u0110\\u01b0\\u1eddng tinh luy\\u1ec7n Bi\\u00ean H\\u00f2a (1kg)", "qty": 2, "unit_price": 17600.0}, {"product_id": 161, "product_code": "d0ce3076-c06f-42af-ba23-221c0ee27198", "name": "Nhang mu\\u1ed7i (H\\u1ed9p 10 khoanh)", "qty": 1, "unit_price": 8000.0}, {"product_id": 160, "product_code": "d560d1cf-83fa-47da-9467-26fa419a73ba", "name": "Thu\\u1ed1c x\\u1ecbt mu\\u1ed7i Raid (600ml)", "qty": 2, "unit_price": 61750.0}, {"product_id": 28, "product_code": "91aed179-28dd-4cb2-96db-44c239795d5f", "name": "Ph\\u1edf b\\u00f2 Vifon g\\u00f3i 90g (c\\u00f3 g\\u00f3i th\\u1ecbt th\\u1eadt)", "qty": 1, "unit_price": 17000.0}]	4	183700	[{"product_id": 8, "product_code": "f14b1d05-1fb7-4ffd-832c-bda06d1396e8", "name": "N\\u01b0\\u1edbc m\\u1eafm Barona \\u0110\\u1ea1i Nh\\u1ea5t 12 \\u0111\\u1ed9 \\u0111\\u1ea1m", "score": 0.78}, {"product_id": 150, "product_code": "8f4dc2fd-7d0d-449f-88a4-47cad03d38d2", "name": "T\\u00e3 qu\\u1ea7n Bobby (B\\u1ecbch M40)", "score": 0.86}, {"product_id": 61, "product_code": "cfcd4967-30f5-4502-acbe-6b72adfab32b", "name": "L\\u1ed1c 4 h\\u0169 s\\u1eefa chua \\u0103n co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Lothamilk 100g", "score": 0.64}]	t	2026-02-19 12:34:15.662096
148	HCM_Q7	TXN-20260310-00148	2026-03-10 05:56:15.671292+00	\N	EDGE_HCM_Q7_01	[{"product_id": 194, "product_code": "3fe5094c-900b-4c6d-9730-f0f768c3f1e1", "name": "Dao r\\u1ecdc gi\\u1ea5y (C\\u00e2y)", "qty": 2, "unit_price": 8500.0}, {"product_id": 87, "product_code": "b336ff02-4595-449e-ada1-c89697da7fc2", "name": "Th\\u00f9ng 12 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 1.5 l\\u00edt", "qty": 2, "unit_price": 180000.0}, {"product_id": 155, "product_code": "4dd70e94-850f-406f-a440-c4a161d99325", "name": "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "qty": 1, "unit_price": 35000.0}, {"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "qty": 2, "unit_price": 42000.0}]	4	496000	[{"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "score": 0.93}, {"product_id": 15, "product_code": "cebc7811-c35c-4a9d-8b37-854d28b07b22", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec H\\u1ea3o H\\u1ea3o t\\u00f4m chua cay 75g", "score": 0.91}, {"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "score": 0.6}]	f	2026-03-10 05:56:15.671292
149	HCM_Q7	TXN-20260330-00149	2026-03-30 20:47:15.679855+00	43	EDGE_HCM_Q7_01	[{"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "qty": 2, "unit_price": 22500.0}, {"product_id": 106, "product_code": "b612273d-326d-4837-811f-90d838f60748", "name": "G\\u1ea1o ST25 (T\\u00fai 5kg)", "qty": 1, "unit_price": 152000.0}, {"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "qty": 3, "unit_price": 10000.0}, {"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "qty": 2, "unit_price": 34000.0}]	4	295000	[{"product_id": 84, "product_code": "a4592c5b-8367-4468-b3e8-cbda4d9c38fa", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng v\\u1ea3i 12.5% chai 360ml", "score": 0.83}, {"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "score": 0.75}, {"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "score": 0.83}, {"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "score": 0.63}]	f	2026-03-30 20:47:15.679855
150	HCM_Q1	TXN-20260228-00150	2026-02-28 15:20:15.69007+00	\N	EDGE_HCM_Q1_01	[{"product_id": 201, "product_code": "e2b8c4e1-00d7-476e-9541-5da23db32d9e", "name": "V\\u1edb ch\\u00e2n nam/n\\u1eef (\\u0110\\u00f4i)", "qty": 3, "unit_price": 12000.0}, {"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "qty": 3, "unit_price": 5000.0}, {"product_id": 130, "product_code": "260fa104-9d28-45a7-bb5e-06b373367221", "name": "B\\u00e1nh quy Cosy (G\\u00f3i 200g)", "qty": 2, "unit_price": 13500.0}, {"product_id": 9, "product_code": "e4c1b87f-da03-460d-970f-cccf1b363bc7", "name": "N\\u01b0\\u1edbc m\\u1eafm Chinsu c\\u00e1 c\\u01a1m bi\\u1ec3n \\u0111\\u00f4ng 25 \\u0111\\u1ed9 \\u0111\\u1ea1m", "qty": 1, "unit_price": 48450.0}, {"product_id": 33, "product_code": "f5833d36-7b7f-4702-937f-8d1286c31a38", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "qty": 2, "unit_price": 270000.0}]	5	666450	[{"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "score": 0.69}, {"product_id": 139, "product_code": "efbd986b-4531-4883-afb4-194c9b59a109", "name": "B\\u1ed9t gi\\u1eb7t OMO (T\\u00fai 3kg)", "score": 0.66}, {"product_id": 62, "product_code": "8e6ed997-217f-4dc4-ba92-611c2a6bbd91", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u1eefa chua \\u0103n \\u00edt \\u0111\\u01b0\\u1eddng Nutimilk 100g", "score": 0.96}]	f	2026-02-28 15:20:15.69007
151	HCM_Q7	TXN-20260224-00151	2026-02-24 20:53:15.700052+00	43	EDGE_HCM_Q7_01	[{"product_id": 172, "product_code": "17f75c8c-ac61-4e32-8355-90e37f46cc3c", "name": "M\\u00e0ng b\\u1ecdc th\\u1ef1c ph\\u1ea9m (Cu\\u1ed9n)", "qty": 2, "unit_price": 19000.0}, {"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 1, "unit_price": 345000.0}, {"product_id": 171, "product_code": "34b1c04a-0e91-4eaf-ae2d-f379c0324d29", "name": "Pin AAA Panasonic (V\\u1ec9 2 vi\\u00ean)", "qty": 3, "unit_price": 15000.0}, {"product_id": 35, "product_code": "313a33b8-b547-45a7-ae0a-92edf3d8ed09", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng kh\\u00f4ng \\u0111\\u01b0\\u1eddng Vinamilk S\\u1eefa t\\u01b0\\u01a1i 100% 1 l\\u00edt", "qty": 2, "unit_price": 385000.0}]	4	1198000	[{"product_id": 197, "product_code": "068f6987-474e-4559-aac7-6903691b2dad", "name": "D\\u1ea7u gi\\u00f3 xanh Con \\u00d3 (Chai)", "score": 0.73}, {"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "score": 0.95}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "score": 0.88}, {"product_id": 165, "product_code": "e7082b36-2f83-4c1f-a986-57c985941c24", "name": "T\\u00fai \\u0111\\u1ef1ng r\\u00e1c (Cu\\u1ed9n 3 m\\u00e0u)", "score": 0.88}]	f	2026-02-24 20:53:15.700052
152	HCM_Q1	TXN-20260323-00152	2026-03-23 07:15:15.708655+00	48	EDGE_HCM_Q1_01	[{"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "qty": 3, "unit_price": 34000.0}, {"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "qty": 3, "unit_price": 3800.0}, {"product_id": 30, "product_code": "f91639d0-6dfc-4083-a260-a2ad3c65eb41", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf g\\u00e0 \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 65g", "qty": 1, "unit_price": 43000.0}, {"product_id": 147, "product_code": "3518ef51-5bc7-4266-bbc2-6ce2d3acbc53", "name": "Gi\\u1ea5y v\\u1ec7 sinh E'mos (L\\u1ed1c 10)", "qty": 2, "unit_price": 48000.0}, {"product_id": 95, "product_code": "0f57e196-eacf-4d9f-89a6-5fdd236a80c9", "name": "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "qty": 1, "unit_price": 22950.0}]	5	275350	[{"product_id": 100, "product_code": "46b1b7b5-3a08-4c49-96c5-44e9cf02c72d", "name": "Th\\u00f9ng 20 h\\u1ed9p B\\u00e1nh quy socola Orion Miz 54g", "score": 0.72}, {"product_id": 109, "product_code": "013d09af-48c5-4c50-9709-5b6183c5e8cc", "name": "D\\u1ea7u \\u0103n T\\u01b0\\u1eddng An", "score": 0.74}]	f	2026-03-23 07:15:15.708655
153	HCM_Q7	TXN-20260302-00153	2026-03-02 13:01:15.717924+00	19	EDGE_HCM_Q7_01	[{"product_id": 128, "product_code": "a010e906-1854-42a0-944b-8bcd42f82e55", "name": "Snack Khoai t\\u00e2y O'Star", "qty": 2, "unit_price": 9500.0}, {"product_id": 175, "product_code": "c55a887f-03c5-45e6-9934-5f8a9a007306", "name": "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "qty": 1, "unit_price": 10000.0}]	2	29000	[{"product_id": 9, "product_code": "e4c1b87f-da03-460d-970f-cccf1b363bc7", "name": "N\\u01b0\\u1edbc m\\u1eafm Chinsu c\\u00e1 c\\u01a1m bi\\u1ec3n \\u0111\\u00f4ng 25 \\u0111\\u1ed9 \\u0111\\u1ea1m", "score": 0.79}, {"product_id": 154, "product_code": "5b0ce6be-f2d9-4e5a-af4d-7e4477ae9970", "name": "B\\u1ecdt c\\u1ea1o r\\u00e2u (Chai 200ml)", "score": 0.86}, {"product_id": 82, "product_code": "7301020d-0402-4b78-969e-9e061a2a830f", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb d\\u00e2u 12% chai 360ml", "score": 0.7}, {"product_id": 80, "product_code": "77e0bf6d-eb78-4ab7-8a73-d61458d018c6", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb vi\\u1ec7t qu\\u1ea5t 12% chai 360ml", "score": 0.92}]	f	2026-03-02 13:01:15.717924
154	HCM_Q7	TXN-20260316-00154	2026-03-16 18:52:15.726446+00	\N	EDGE_HCM_Q7_01	[{"product_id": 40, "product_code": "662bdd0b-b218-4630-b448-3d2702743375", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t TH true MILK 180ml", "qty": 1, "unit_price": 425000.0}, {"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "qty": 1, "unit_price": 5000.0}, {"product_id": 54, "product_code": "c5544e90-b58e-4a17-89af-5f131087703b", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "qty": 2, "unit_price": 34500.0}]	3	499000	[{"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "score": 0.81}, {"product_id": 41, "product_code": "8c0bd0e0-9c72-4d67-9c29-61b269b31df8", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "score": 0.73}, {"product_id": 6, "product_code": "4261ad1a-adce-4554-9710-a9edbdc16f52", "name": "N\\u01b0\\u1edbc ch\\u1ea5m Nam Ng\\u01b0 \\u0110\\u1ec7 Nh\\u1ecb", "score": 0.86}]	f	2026-03-16 18:52:15.726446
155	HN_CG	TXN-20260222-00155	2026-02-22 15:45:15.735091+00	36	EDGE_HN_CG_01	[{"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "qty": 3, "unit_price": 11500.0}, {"product_id": 34, "product_code": "15458477-33d0-4386-bf74-bc53f8887361", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 220ml", "qty": 2, "unit_price": 337500.0}, {"product_id": 83, "product_code": "a0500366-8dd9-44bc-ad93-6e2f9241f1bf", "name": "R\\u01b0\\u1ee3u soju Rice+ h\\u01b0\\u01a1ng d\\u1ee9a 12.5% chai 360ml", "qty": 2, "unit_price": 38250.0}, {"product_id": 193, "product_code": "057d7a10-7e86-4899-a4d3-2bbb14ab8e8d", "name": "B\\u00eca h\\u1ed3 s\\u01a1 Clearbag (C\\u00e1i)", "qty": 3, "unit_price": 3000.0}]	4	795000	[{"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "score": 0.78}, {"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "score": 0.94}]	t	2026-02-22 15:45:15.735091
156	HN_CG	TXN-20260216-00156	2026-02-16 11:40:15.743281+00	55	EDGE_HN_CG_01	[{"product_id": 97, "product_code": "37f71635-5dd1-431a-b46d-bc5c35acb0ec", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola Gery Crunch Roll g\\u00f3i 23g", "qty": 1, "unit_price": 5000.0}, {"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "qty": 1, "unit_price": 42000.0}]	2	47000	[{"product_id": 46, "product_code": "8636600f-9b6f-4cb4-a120-cf70c55c20e6", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch \\u00edt \\u0111\\u01b0\\u1eddng Milo A2 180ml", "score": 0.97}, {"product_id": 14, "product_code": "7d31d029-8f17-4074-ad5e-96f50b6b9465", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en", "score": 0.85}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.83}]	t	2026-02-16 11:40:15.743281
157	HCM_Q7	TXN-20260217-00157	2026-02-17 14:50:15.751853+00	12	EDGE_HCM_Q7_01	[{"product_id": 199, "product_code": "78df9983-9047-45ca-8867-aa9f19c6e3d6", "name": "\\u00c1o m\\u01b0a ti\\u1ec7n l\\u1ee3i (C\\u00e1i)", "qty": 2, "unit_price": 10000.0}, {"product_id": 178, "product_code": "d266d4ae-3907-4253-8443-ae1cf4103dde", "name": "Th\\u1edbt nh\\u1ef1a tr\\u00f2n", "qty": 3, "unit_price": 40000.0}, {"product_id": 204, "product_code": "e03863a3-5056-43ed-af9e-77bdb148f682", "name": "C\\u1ee7 s\\u1ea1c USB 2 c\\u1ed5ng", "qty": 2, "unit_price": 45000.0}, {"product_id": 172, "product_code": "17f75c8c-ac61-4e32-8355-90e37f46cc3c", "name": "M\\u00e0ng b\\u1ecdc th\\u1ef1c ph\\u1ea9m (Cu\\u1ed9n)", "qty": 2, "unit_price": 19000.0}]	4	268000	[{"product_id": 95, "product_code": "0f57e196-eacf-4d9f-89a6-5fdd236a80c9", "name": "B\\u00e1nh cracker rau c\\u1ee7 ch\\u00e0 b\\u00f4ng Tipo h\\u1ed9p 132g", "score": 0.64}, {"product_id": 3, "product_code": "fb8b76f0-baea-440d-acf3-f80e738a7958", "name": "D\\u1ea7u \\u0103n th\\u01b0\\u1ee3ng h\\u1ea1ng Neptune Light", "score": 0.65}, {"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.84}]	f	2026-02-17 14:50:15.751853
158	HCM_Q7	TXN-20260304-00158	2026-03-04 08:03:15.760677+00	7	EDGE_HCM_Q7_01	[{"product_id": 47, "product_code": "a38415d3-461f-40db-836e-c2658544e3ff", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa socola l\\u00faa m\\u1ea1ch Lof Kun c\\u00f3 th\\u1ea1ch 170ml", "qty": 1, "unit_price": 33500.0}, {"product_id": 99, "product_code": "14b30760-cebe-46ff-8768-3e7e7bbdcae5", "name": "B\\u00e1nh quy b\\u01a1 v\\u00e0 cacao Danisa Abbracci h\\u1ed9p 168g", "qty": 1, "unit_price": 35500.0}, {"product_id": 124, "product_code": "4603c6b9-3f0e-4455-9c80-afad12742d51", "name": "N\\u01b0\\u1edbc su\\u1ed1i Aquafina (500ml)", "qty": 2, "unit_price": 4750.0}, {"product_id": 166, "product_code": "96957d5e-8c41-4952-9b85-b76b950196f3", "name": "Ch\\u1ed5i \\u0111\\u00f3t qu\\u00e9t nh\\u00e0", "qty": 1, "unit_price": 35000.0}, {"product_id": 180, "product_code": "8f382477-a9b4-44d6-bf2a-59fae61d9166", "name": "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "qty": 3, "unit_price": 19000.0}]	5	170500	[{"product_id": 48, "product_code": "daa15e61-ad90-41f8-aecf-9db0eefdf004", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch v\\u1ecb socola Ovaltine b\\u1ed5 sung canxi 180ml", "score": 0.75}, {"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "score": 0.91}, {"product_id": 180, "product_code": "8f382477-a9b4-44d6-bf2a-59fae61d9166", "name": "K\\u00e9o c\\u1eaft gi\\u1ea5y/b\\u1ebfp", "score": 0.9}, {"product_id": 6, "product_code": "4261ad1a-adce-4554-9710-a9edbdc16f52", "name": "N\\u01b0\\u1edbc ch\\u1ea5m Nam Ng\\u01b0 \\u0110\\u1ec7 Nh\\u1ecb", "score": 0.8}]	f	2026-03-04 08:03:15.760677
159	HCM_Q1	TXN-20260223-00159	2026-02-23 10:58:15.768848+00	29	EDGE_HCM_Q1_01	[{"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 1, "unit_price": 345000.0}, {"product_id": 11, "product_code": "c657b334-1d73-44af-b7cc-74d5d5bd1efa", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi \\u0111\\u1eadm \\u0111\\u1eb7c", "qty": 1, "unit_price": 35000.0}, {"product_id": 33, "product_code": "f5833d36-7b7f-4702-937f-8d1286c31a38", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "qty": 3, "unit_price": 270000.0}]	3	1190000	[{"product_id": 22, "product_code": "4f92b81a-203d-4ec7-b261-f1ffbe9b5ec4", "name": "M\\u00ec x\\u00e0o kh\\u00f4 Indomie Mi Goreng v\\u1ecb \\u0111\\u1eb7c bi\\u1ec7t g\\u00f3i 85g", "score": 0.79}, {"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "score": 0.74}]	t	2026-02-23 10:58:15.768848
160	HCM_Q1	TXN-20260322-00160	2026-03-22 23:08:15.777513+00	34	EDGE_HCM_Q1_01	[{"product_id": 169, "product_code": "8531a0bb-c2d8-42da-b318-d7a1cf5a767b", "name": "\\u1ed4 c\\u1eafm \\u0111i\\u1ec7n n\\u1ed1i d\\u00e0i (3 m\\u00e9t)", "qty": 3, "unit_price": 68000.0}, {"product_id": 137, "product_code": "f0cac878-618a-41d5-9319-8b85e8c0fc27", "name": "D\\u1ea7u g\\u1ed9i Clear Men (Chai 630g)", "qty": 2, "unit_price": 135000.0}, {"product_id": 114, "product_code": "ce2da010-513b-4127-8f02-30e3f362500e", "name": "Mu\\u1ed1i I-\\u1ed1t (G\\u00f3i 500g)", "qty": 3, "unit_price": 5000.0}]	3	489000	[{"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "score": 0.68}, {"product_id": 138, "product_code": "8e13d676-f7e9-477f-940b-813f80469993", "name": "S\\u1eefa t\\u1eafm Lifebuoy (Chai 850g)", "score": 0.64}, {"product_id": 131, "product_code": "596df514-3b1f-463c-92f3-fdfb93e41684", "name": "Ng\\u0169 c\\u1ed1c dinh d\\u01b0\\u1ee1ng (G\\u00f3i 500g)", "score": 0.91}]	f	2026-03-22 23:08:15.777513
161	HCM_Q1	TXN-20260304-00161	2026-03-04 15:04:15.785622+00	14	EDGE_HCM_Q1_01	[{"product_id": 92, "product_code": "6774e6fd-3534-44d2-8bf7-40170e50ac56", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Fanta h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb chai 1.5 l\\u00edt", "qty": 2, "unit_price": 17850.0}, {"product_id": 72, "product_code": "ecb6b5c5-539c-4c4a-89a3-ad676f69c353", "name": "Th\\u00f9ng 24 lon Bia S\\u00e0i G\\u00f2n Lager 330ml", "qty": 2, "unit_price": 206400.0}, {"product_id": 33, "product_code": "f5833d36-7b7f-4702-937f-8d1286c31a38", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 110ml", "qty": 2, "unit_price": 270000.0}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 3, "unit_price": 6800.0}, {"product_id": 160, "product_code": "d560d1cf-83fa-47da-9467-26fa419a73ba", "name": "Thu\\u1ed1c x\\u1ecbt mu\\u1ed7i Raid (600ml)", "qty": 1, "unit_price": 61750.0}]	5	1070650	[{"product_id": 66, "product_code": "59989980-7fbb-4c6a-bf32-5d2cb1fa21c5", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Happy Star Vinamilk 100g", "score": 0.76}, {"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "score": 0.86}]	t	2026-03-04 15:04:15.785622
162	HN_CG	TXN-20260304-00162	2026-03-04 05:38:15.793815+00	37	EDGE_HN_CG_01	[{"product_id": 155, "product_code": "4dd70e94-850f-406f-a440-c4a161d99325", "name": "Dung d\\u1ecbch v\\u1ec7 sinh ph\\u1ee5 n\\u1eef (Chai)", "qty": 3, "unit_price": 35000.0}, {"product_id": 42, "product_code": "13cbc909-c57c-4c13-8304-1abb2e7d16e6", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "qty": 1, "unit_price": 386750.0}, {"product_id": 108, "product_code": "ba0eeecc-e4ce-4bd7-b4f0-91117d028872", "name": "Th\\u00f9ng M\\u00ec 3 Mi\\u1ec1n (30 g\\u00f3i)", "qty": 1, "unit_price": 85000.0}, {"product_id": 40, "product_code": "662bdd0b-b218-4630-b448-3d2702743375", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t TH true MILK 180ml", "qty": 2, "unit_price": 425000.0}, {"product_id": 81, "product_code": "1485f5ea-a1a9-4383-98c4-338a415c5e3d", "name": "R\\u01b0\\u1ee3u soju Heejin v\\u1ecb \\u0111\\u00e0o 12% chai 360ml", "qty": 1, "unit_price": 42750.0}]	5	1469500	[{"product_id": 141, "product_code": "0b4a4b09-46ec-4a6b-bc41-df4393645a3e", "name": "N\\u01b0\\u1edbc x\\u1ea3 v\\u1ea3i Comfort (T\\u00fai 1.6L)", "score": 0.84}, {"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "score": 0.74}, {"product_id": 17, "product_code": "85b32dea-9fe5-4511-aa87-20e9db48996c", "name": "Th\\u00f9ng 30 g\\u00f3i m\\u00ec x\\u00e0o H\\u1ea3o H\\u1ea3o t\\u00f4m x\\u00e0o chua ng\\u1ecdt 75g", "score": 0.73}, {"product_id": 85, "product_code": "c34d6ee1-5a04-45bf-9b79-84e2f5289aef", "name": "Th\\u00f9ng 24 lon n\\u01b0\\u1edbc ng\\u1ecdt Pepsi kh\\u00f4ng calo v\\u1ecb chanh 320ml", "score": 0.7}]	f	2026-03-04 05:38:15.793815
163	HCM_Q1	TXN-20260225-00163	2026-02-25 17:43:15.80235+00	\N	EDGE_HCM_Q1_01	[{"product_id": 45, "product_code": "70aecc30-273a-4640-ae9e-bf45c96ba51b", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng lof Kun 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 2, "unit_price": 376000.0}]	1	752000	[{"product_id": 25, "product_code": "6ea2d57b-df3a-4461-8a6e-db601dd728eb", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng h\\u1ea3i s\\u1ea3n cay g\\u00f3i 66g", "score": 0.87}, {"product_id": 136, "product_code": "53ec6e96-b534-42e0-a986-9d6d2d36e86d", "name": "D\\u1ea7u g\\u1ed9i Sunsilk (Chai 650g)", "score": 0.93}, {"product_id": 90, "product_code": "61c35ff1-5a92-4568-9870-e345bc73a24c", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Coca Cola lon 320ml", "score": 0.81}]	f	2026-02-25 17:43:15.80235
164	HCM_Q7	TXN-20260214-00164	2026-02-14 12:57:15.811136+00	9	EDGE_HCM_Q7_01	[{"product_id": 3, "product_code": "fb8b76f0-baea-440d-acf3-f80e738a7958", "name": "D\\u1ea7u \\u0103n th\\u01b0\\u1ee3ng h\\u1ea1ng Neptune Light", "qty": 1, "unit_price": 62100.0}, {"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "qty": 1, "unit_price": 33250.0}, {"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "qty": 2, "unit_price": 22500.0}]	3	140350	[{"product_id": 14, "product_code": "7d31d029-8f17-4074-ad5e-96f50b6b9465", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en", "score": 0.97}, {"product_id": 186, "product_code": "da5a3390-cf73-4a9f-bffc-f6e02a0905b2", "name": "B\\u00fat bi Thi\\u00ean Long (C\\u00e2y)", "score": 0.87}, {"product_id": 164, "product_code": "5576682c-00ee-4aab-8888-3526e2bf7626", "name": "Bao tay cao su (\\u0110\\u00f4i)", "score": 0.69}]	f	2026-02-14 12:57:15.811136
165	HCM_Q7	TXN-20260312-00165	2026-03-12 03:50:15.818135+00	28	EDGE_HCM_Q7_01	[{"product_id": 184, "product_code": "e366d057-07fc-4551-a1ee-ee55890fbff7", "name": "Keo 502 (Chai)", "qty": 2, "unit_price": 5000.0}, {"product_id": 59, "product_code": "b9c6ad3b-cba2-4de1-96f6-b27fe38a368f", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "qty": 1, "unit_price": 24650.0}, {"product_id": 79, "product_code": "dcf4b890-c91e-4ef3-bf6e-b4433d191182", "name": "Bia Corona Extra chai 250ml", "qty": 3, "unit_price": 31000.0}, {"product_id": 163, "product_code": "5acdac1a-898e-4a9f-8acd-f8590ce29d7b", "name": "C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)", "qty": 1, "unit_price": 12000.0}, {"product_id": 23, "product_code": "9d0cd1db-dbef-4a18-b865-111036abce29", "name": "Th\\u00f9ng 24 g\\u00f3i mi\\u1ebfn Ph\\u00fa H\\u01b0\\u01a1ng th\\u1ecbt b\\u1eb1m 55g", "qty": 1, "unit_price": 250000.0}]	5	389650	[{"product_id": 43, "product_code": "d4bfaf6c-3b76-40b5-b6d1-ff43f5cd2555", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng v\\u1ecb t\\u1ef1 nhi\\u00ean TH true MILK Hilo 180ml", "score": 0.62}, {"product_id": 148, "product_code": "d6f2920e-e16a-4096-8159-a938f4b8ce59", "name": "Kh\\u0103n gi\\u1ea5y r\\u00fat Pulppy (H\\u1ed9p)", "score": 0.88}]	f	2026-03-12 03:50:15.818135
175	HCM_Q7	TXN-20260221-00175	2026-02-21 14:37:15.900694+00	\N	EDGE_HCM_Q7_01	[{"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "qty": 3, "unit_price": 12000.0}, {"product_id": 191, "product_code": "1e416e03-2048-4d85-8f63-b6085adb65ae", "name": "H\\u1ed3 d\\u00e1n gi\\u1ea5y (Chai)", "qty": 3, "unit_price": 3800.0}]	2	47400	[{"product_id": 181, "product_code": "e483f862-1cbe-45fd-bdb1-169e28072fc2", "name": "B\\u1eadt l\\u1eeda gas", "score": 0.95}, {"product_id": 115, "product_code": "11086cc9-d30a-4145-acaf-8e2084c851f0", "name": "T\\u01b0\\u01a1ng \\u1edbt Chinsu (250g)", "score": 0.63}]	f	2026-02-21 14:37:15.900694
166	HN_CG	TXN-20260318-00166	2026-03-18 18:39:15.827304+00	33	EDGE_HN_CG_01	[{"product_id": 179, "product_code": "116ca6a2-d366-440f-951e-05cd8176868b", "name": "Dao th\\u00e1i lan c\\u00e1n v\\u00e0ng", "qty": 3, "unit_price": 12000.0}, {"product_id": 32, "product_code": "58fe169c-bca1-464e-a180-f17b0a59883e", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 2, "unit_price": 345000.0}, {"product_id": 104, "product_code": "28a42565-eba9-41ff-b3ad-4eda339d7363", "name": "B\\u00e1nh quy ph\\u00f4 mai Gery h\\u1ed9p 180g", "qty": 3, "unit_price": 39000.0}, {"product_id": 4, "product_code": "2552366a-29a2-46a3-943a-3d8fb45b3fad", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "qty": 3, "unit_price": 59000.0}, {"product_id": 158, "product_code": "8526f078-cb9e-4c78-ae7a-ab1526ddda7d", "name": "N\\u01b0\\u1edbc r\\u1eeda tay kh\\u00f4 (Chai 100ml)", "qty": 3, "unit_price": 30000.0}]	5	1110000	[{"product_id": 170, "product_code": "b3ddb87e-8557-4283-bd9e-e384d80b0026", "name": "Pin AA Con \\u00d3 (V\\u1ec9 4 vi\\u00ean)", "score": 0.62}, {"product_id": 136, "product_code": "53ec6e96-b534-42e0-a986-9d6d2d36e86d", "name": "D\\u1ea7u g\\u1ed9i Sunsilk (Chai 650g)", "score": 0.77}, {"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "score": 0.66}, {"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "score": 0.95}]	t	2026-03-18 18:39:15.827304
167	HN_CG	TXN-20260324-00167	2026-03-24 06:41:15.836466+00	\N	EDGE_HN_CG_01	[{"product_id": 127, "product_code": "93732245-6096-4556-a353-202308e968d1", "name": "B\\u00e1nh ChocoPie (H\\u1ed9p 6 c\\u00e1i)", "qty": 3, "unit_price": 28500.0}, {"product_id": 98, "product_code": "ee26af7b-4793-4bac-83ef-42dcff20b99a", "name": "B\\u00e1nh cracker v\\u1ecb d\\u1eeba s\\u1ea7u ri\\u00eang Bibica Gooka Nougat Filling h\\u1ed9p 360g", "qty": 1, "unit_price": 65000.0}, {"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 3, "unit_price": 355000.0}, {"product_id": 96, "product_code": "a903b525-93ec-4602-bf74-099d44d3ea67", "name": "B\\u00e1nh cu\\u1ed9n ph\\u1ee7 socola h\\u01b0\\u01a1ng vani Gery Crunch Roll g\\u00f3i 23g", "qty": 1, "unit_price": 5000.0}]	4	1220500	[{"product_id": 76, "product_code": "aa017cb5-b496-42a5-9417-beec7b243112", "name": "Th\\u00f9ng 12 lon bia Hoegaarden Peach v\\u1ecb \\u0111\\u00e0o 500ml", "score": 0.6}, {"product_id": 68, "product_code": "5d22b162-c9c6-4540-ab8a-ff709f7148e3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa h\\u01b0\\u01a1ng vani Hoff 55g", "score": 0.84}, {"product_id": 55, "product_code": "4deccf3e-0f6b-4f7e-932a-5acf275d938f", "name": "L\\u1ed1c 4 chai s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p 170ml", "score": 0.75}]	t	2026-03-24 06:41:15.836466
168	HN_CG	TXN-20260308-00168	2026-03-08 18:28:15.844024+00	23	EDGE_HN_CG_01	[{"product_id": 2, "product_code": "76e07498-8366-4687-a82e-2a47ecd1e994", "name": "D\\u1ea7u th\\u1ef1c v\\u1eadt tinh luy\\u1ec7n C\\u00e1i L\\u00e2n", "qty": 2, "unit_price": 39100.0}]	1	78200	[{"product_id": 111, "product_code": "39db55d0-6784-4457-900f-d85d7b17e783", "name": "H\\u1ea1t n\\u00eam Knorr (400g)", "score": 0.68}, {"product_id": 126, "product_code": "d487390c-5ffd-47eb-b891-e9feeaeb0830", "name": "Bia Tiger N\\u00e2u (Lon 330ml)", "score": 0.8}]	t	2026-03-08 18:28:15.844024
169	HN_CG	TXN-20260319-00169	2026-03-19 23:48:15.852405+00	26	EDGE_HN_CG_01	[{"product_id": 77, "product_code": "48e76a9b-f890-482e-8a03-cd6700870620", "name": "Th\\u00f9ng 12 lon bia Budweiser 500ml", "qty": 2, "unit_price": 349000.0}, {"product_id": 94, "product_code": "d1b9db4c-7740-417c-9d54-b450251614c9", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml", "qty": 1, "unit_price": 10000.0}, {"product_id": 110, "product_code": "5c3c9117-2fac-436a-b807-4cba00d3d6a1", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0", "qty": 2, "unit_price": 42000.0}]	3	792000	[{"product_id": 42, "product_code": "13cbc909-c57c-4c13-8304-1abb2e7d16e6", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t kh\\u00f4ng \\u0111\\u01b0\\u1eddng TH true MILK h\\u1ed9p 1 l\\u00edt", "score": 0.88}, {"product_id": 36, "product_code": "6ea649b0-f9e4-44cb-9fb9-768d1889cdf6", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng \\u00edt \\u0111\\u01b0\\u1eddng TH true MILK 180ml", "score": 0.6}, {"product_id": 91, "product_code": "845e5e02-35a6-498e-9420-f6d30ae72b04", "name": "6 lon n\\u01b0\\u1edbc ng\\u1ecdt Coca Cola 320ml", "score": 0.94}]	f	2026-03-19 23:48:15.852405
170	HCM_Q7	TXN-20260228-00170	2026-02-28 20:22:15.859426+00	\N	EDGE_HCM_Q7_01	[{"product_id": 171, "product_code": "34b1c04a-0e91-4eaf-ae2d-f379c0324d29", "name": "Pin AAA Panasonic (V\\u1ec9 2 vi\\u00ean)", "qty": 1, "unit_price": 15000.0}, {"product_id": 51, "product_code": "11f2305b-4158-4922-83d3-32a4ec214596", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam YoMost 170ml", "qty": 2, "unit_price": 298000.0}]	2	611000	[{"product_id": 205, "product_code": "57f232f5-1156-4349-a927-f00ce7a05827", "name": "Th\\u1ebb c\\u00e0o \\u0111i\\u1ec7n tho\\u1ea1i 20k", "score": 0.65}, {"product_id": 175, "product_code": "c55a887f-03c5-45e6-9934-5f8a9a007306", "name": "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "score": 0.89}, {"product_id": 183, "product_code": "5a20e1d3-d558-4cad-ae30-cbb947a1256f", "name": "B\\u0103ng keo trong (Cu\\u1ed9n l\\u1edbn)", "score": 0.9}]	f	2026-02-28 20:22:15.859426
171	HCM_Q1	TXN-20260310-00171	2026-03-10 04:01:15.867702+00	50	EDGE_HCM_Q1_01	[{"product_id": 14, "product_code": "7d31d029-8f17-4074-ad5e-96f50b6b9465", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng th\\u01b0\\u1ee3ng h\\u1ea1ng Nam D\\u01b0\\u01a1ng ch\\u00ednh hi\\u1ec7u Con M\\u00e8o \\u0110en", "qty": 3, "unit_price": 41000.0}, {"product_id": 174, "product_code": "fdd4d2f8-60fd-4b2e-ada3-76b372f6a0c0", "name": "Mi\\u1ebfng r\\u1eeda ch\\u00e9n (Mi\\u1ebfng)", "qty": 1, "unit_price": 4750.0}]	2	127750	[{"product_id": 73, "product_code": "c57b5193-7c6a-4e72-be5f-bf08951cd0ec", "name": "Th\\u00f9ng 24 lon Bia Tiger B\\u1ea1c 330ml", "score": 0.89}, {"product_id": 125, "product_code": "0865ac34-b3ed-4b11-8a79-3e59ecf6d80f", "name": "Coca Cola (Chai 1.5L)", "score": 0.69}, {"product_id": 22, "product_code": "4f92b81a-203d-4ec7-b261-f1ffbe9b5ec4", "name": "M\\u00ec x\\u00e0o kh\\u00f4 Indomie Mi Goreng v\\u1ecb \\u0111\\u1eb7c bi\\u1ec7t g\\u00f3i 85g", "score": 0.66}]	t	2026-03-10 04:01:15.867702
172	HCM_Q7	TXN-20260324-00172	2026-03-24 18:53:15.87525+00	28	EDGE_HCM_Q7_01	[{"product_id": 122, "product_code": "eb6dd78c-2cff-4373-a62a-ad27ce8d8d87", "name": "C\\u00e0 ph\\u00ea G7 3in1 (H\\u1ed9p 18 g\\u00f3i)", "qty": 3, "unit_price": 52000.0}, {"product_id": 181, "product_code": "e483f862-1cbe-45fd-bdb1-169e28072fc2", "name": "B\\u1eadt l\\u1eeda gas", "qty": 3, "unit_price": 3000.0}]	2	165000	[{"product_id": 162, "product_code": "8f8b80aa-8a45-4b12-add5-6d36bd69dcdf", "name": "Javel t\\u1ea9y tr\\u1eafng (Chai 1L)", "score": 0.65}, {"product_id": 163, "product_code": "5acdac1a-898e-4a9f-8acd-f8590ce29d7b", "name": "C\\u1ecd r\\u1eeda b\\u1ed3n c\\u1ea7u (C\\u00e2y)", "score": 0.75}, {"product_id": 39, "product_code": "0e3740f8-9d6f-4f7b-b1bb-3b719c18c93b", "name": "Th\\u00f9ng 48 b\\u1ecbch s\\u1eefa dinh d\\u01b0\\u1ee1ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 220ml", "score": 0.7}, {"product_id": 59, "product_code": "b9c6ad3b-cba2-4de1-96f6-b27fe38a368f", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng b\\u1ea1c h\\u00e0 v\\u00e0 vi\\u1ec7t qu\\u1ea5t YoMost 170ml", "score": 0.67}]	t	2026-03-24 18:53:15.87525
173	HCM_Q1	TXN-20260304-00173	2026-03-04 02:36:15.883431+00	20	EDGE_HCM_Q1_01	[{"product_id": 57, "product_code": "e56f880f-1868-440c-aef9-7faa345362ed", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng cam Nutriboost Hy L\\u1ea1p chai 170ml", "qty": 3, "unit_price": 10000.0}, {"product_id": 87, "product_code": "b336ff02-4595-449e-ada1-c89697da7fc2", "name": "Th\\u00f9ng 12 chai n\\u01b0\\u1edbc ng\\u1ecdt Mirinda v\\u1ecb soda kem 1.5 l\\u00edt", "qty": 2, "unit_price": 180000.0}]	2	390000	[{"product_id": 29, "product_code": "0e9e5f9f-bf21-41ba-b432-761f82316db3", "name": "L\\u1ed1c 5 g\\u00f3i ph\\u1edf b\\u00f2 t\\u00e1i l\\u0103n \\u0110\\u1ec7 Nh\\u1ea5t g\\u00f3i 68g", "score": 0.71}, {"product_id": 69, "product_code": "c6db64ee-92ea-4113-8297-a2e94c4f6be6", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa dinh d\\u01b0\\u1ee1ng Gotz 55g", "score": 0.73}, {"product_id": 94, "product_code": "d1b9db4c-7740-417c-9d54-b450251614c9", "name": "N\\u01b0\\u1edbc ng\\u1ecdt Mirinda h\\u01b0\\u01a1ng x\\u00e1 x\\u1ecb lon 320ml", "score": 0.76}]	f	2026-03-04 02:36:15.883431
174	HN_CG	TXN-20260320-00174	2026-03-20 09:08:15.891451+00	31	EDGE_HN_CG_01	[{"product_id": 156, "product_code": "88a52c8d-5e20-4da9-b186-dba57601f4c2", "name": "T\\u0103m b\\u00f4ng r\\u00e1y tai (H\\u1ed9p)", "qty": 2, "unit_price": 8000.0}, {"product_id": 26, "product_code": "92e98c7f-ab4f-4150-b20a-c06c519dc674", "name": "Mi\\u1ebfn tr\\u1ed9n Ph\\u00fa H\\u01b0\\u01a1ng g\\u00e0 x\\u00e0o chua ng\\u1ecdt g\\u00f3i 69g", "qty": 2, "unit_price": 11500.0}, {"product_id": 111, "product_code": "39db55d0-6784-4457-900f-d85d7b17e783", "name": "H\\u1ea1t n\\u00eam Knorr (400g)", "qty": 2, "unit_price": 30400.0}]	3	99800	[{"product_id": 4, "product_code": "2552366a-29a2-46a3-943a-3d8fb45b3fad", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh nguy\\u00ean ch\\u1ea5t Simply", "score": 0.93}, {"product_id": 175, "product_code": "c55a887f-03c5-45e6-9934-5f8a9a007306", "name": "B\\u00f9i nh\\u00f9i s\\u1eaft (G\\u00f3i)", "score": 0.73}, {"product_id": 142, "product_code": "11c60194-88d2-4816-997a-5553a8cb6196", "name": "Kem \\u0111\\u00e1nh r\\u0103ng P/S (180g)", "score": 0.88}, {"product_id": 198, "product_code": "2c790f44-7ee9-4c1d-9170-0f67eaf7e736", "name": "M\\u0169 b\\u1ea3o hi\\u1ec3m n\\u1eeda \\u0111\\u1ea7u", "score": 0.74}]	t	2026-03-20 09:08:15.891451
176	HCM_Q1	TXN-20260308-00176	2026-03-08 02:59:15.909241+00	46	EDGE_HCM_Q1_01	[{"product_id": 195, "product_code": "0c817e5a-0d94-4f29-be97-bc218296a244", "name": "Kh\\u1ea9u trang y t\\u1ebf (H\\u1ed9p 50)", "qty": 3, "unit_price": 35000.0}, {"product_id": 144, "product_code": "2869b301-5fec-407f-b472-6e72ee034c9f", "name": "N\\u01b0\\u1edbc r\\u1eeda ch\\u00e9n Sunlight (750ml)", "qty": 1, "unit_price": 21250.0}, {"product_id": 89, "product_code": "4362ec25-fdc1-4b2a-9588-6642962e5302", "name": "Th\\u00f9ng 24 chai n\\u01b0\\u1edbc ng\\u1ecdt Pepsi Cola 390ml", "qty": 2, "unit_price": 118000.0}]	3	362250	[{"product_id": 135, "product_code": "c7f42ff3-6047-4f08-866c-1b32209e3f90", "name": "B\\u00fan kh\\u00f4 Safoco (G\\u00f3i 400g)", "score": 0.61}, {"product_id": 129, "product_code": "fb1ea21f-cda1-4678-a372-358a68f83a9c", "name": "K\\u1eb9o c\\u1ee9ng Dynamite", "score": 0.83}, {"product_id": 203, "product_code": "cd3322e6-fa79-4ff1-9ec1-017716f5f8af", "name": "C\\u00e1p s\\u1ea1c Android/iPhone", "score": 0.86}]	t	2026-03-08 02:59:15.909241
177	HN_CG	TXN-20260321-00177	2026-03-21 02:51:15.919049+00	26	EDGE_HN_CG_01	[{"product_id": 176, "product_code": "2eab34da-0a77-4a39-acbb-0e800b733966", "name": "M\\u00f3c ph\\u01a1i qu\\u1ea7n \\u00e1o (V\\u1ec9 10)", "qty": 3, "unit_price": 33250.0}, {"product_id": 137, "product_code": "f0cac878-618a-41d5-9319-8b85e8c0fc27", "name": "D\\u1ea7u g\\u1ed9i Clear Men (Chai 630g)", "qty": 2, "unit_price": 135000.0}, {"product_id": 132, "product_code": "df4e7bad-75ab-4bb8-822a-e66ec36f0a38", "name": "\\u0110\\u1eadu ph\\u1ed9ng da c\\u00e1 (H\\u0169 200g)", "qty": 3, "unit_price": 22500.0}, {"product_id": 20, "product_code": "d9f8c780-f6e0-408f-9147-1072585bee2d", "name": "M\\u00ec Kokomi 90 t\\u00f4m chua cay g\\u00f3i 90g", "qty": 2, "unit_price": 3600.0}]	4	444450	[{"product_id": 53, "product_code": "d5b1b057-5bcf-4629-a973-7f8e9c0bca3c", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa chua l\\u00ean men t\\u1ef1 nhi\\u00ean h\\u01b0\\u01a1ng nho c\\u00f3 th\\u1ea1ch LOF Malto 170ml", "score": 0.66}, {"product_id": 48, "product_code": "daa15e61-ad90-41f8-aecf-9db0eefdf004", "name": "L\\u1ed1c 4 h\\u1ed9p S\\u1eefa l\\u00faa m\\u1ea1ch v\\u1ecb socola Ovaltine b\\u1ed5 sung canxi 180ml", "score": 0.68}, {"product_id": 1, "product_code": "9583297f-78a6-4dfc-84a5-82f214b9e86e", "name": "D\\u1ea7u \\u0111\\u1eadu n\\u00e0nh tinh luy\\u1ec7n Janbee", "score": 0.86}]	t	2026-03-21 02:51:15.919049
178	HCM_Q7	TXN-20260316-00178	2026-03-16 08:37:15.927181+00	18	EDGE_HCM_Q7_01	[{"product_id": 31, "product_code": "26cbd778-6e9e-46de-a952-c88d7b54be33", "name": "Th\\u00f9ng 24 bi\\u0323ch s\\u1eefa dinh d\\u01b0\\u1ee1ng \\u00edt \\u0111\\u01b0\\u1eddng Dutch Lady 180ml", "qty": 3, "unit_price": 170000.0}, {"product_id": 44, "product_code": "5fa3eef2-4d7e-4720-b97e-5173a5175c91", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng c\\u00f3 \\u0111\\u01b0\\u1eddng Vinamilk 100% S\\u1eefa t\\u01b0\\u01a1i 180ml", "qty": 1, "unit_price": 355000.0}, {"product_id": 58, "product_code": "54ee9149-caee-4c90-9f0d-8a89945ffa5f", "name": "S\\u1eefa chua u\\u1ed1ng h\\u01b0\\u01a1ng vi\\u1ec7t qu\\u1ea5t Nutriboost Hy L\\u1ea1p chai 170ml", "qty": 2, "unit_price": 10000.0}, {"product_id": 12, "product_code": "32c195be-0444-4c26-8b09-761cb0b32136", "name": "N\\u01b0\\u1edbc t\\u01b0\\u01a1ng \\u0111\\u1eadu n\\u00e0nh Maggi thanh d\\u1ecbu", "qty": 1, "unit_price": 22000.0}, {"product_id": 137, "product_code": "f0cac878-618a-41d5-9319-8b85e8c0fc27", "name": "D\\u1ea7u g\\u1ed9i Clear Men (Chai 630g)", "qty": 2, "unit_price": 135000.0}]	5	1177000	[{"product_id": 165, "product_code": "e7082b36-2f83-4c1f-a986-57c985941c24", "name": "T\\u00fai \\u0111\\u1ef1ng r\\u00e1c (Cu\\u1ed9n 3 m\\u00e0u)", "score": 0.98}, {"product_id": 64, "product_code": "0f123724-4435-43b5-a850-de579646313d", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua nha \\u0111am Nutimilk 100g", "score": 0.68}]	f	2026-03-16 08:37:15.927181
179	HCM_Q7	TXN-20260313-00179	2026-03-13 07:36:15.936419+00	\N	EDGE_HCM_Q7_01	[{"product_id": 68, "product_code": "5d22b162-c9c6-4540-ab8a-ff709f7148e3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p v\\u00e1ng s\\u1eefa h\\u01b0\\u01a1ng vani Hoff 55g", "qty": 3, "unit_price": 65000.0}, {"product_id": 185, "product_code": "cf4e420e-2ede-4a08-8209-0eaa5a110cf5", "name": "D\\u00e2y r\\u00fat nh\\u1ef1a (T\\u00fai 100 s\\u1ee3i)", "qty": 1, "unit_price": 12750.0}, {"product_id": 35, "product_code": "313a33b8-b547-45a7-ae0a-92edf3d8ed09", "name": "Th\\u00f9ng 12 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng kh\\u00f4ng \\u0111\\u01b0\\u1eddng Vinamilk S\\u1eefa t\\u01b0\\u01a1i 100% 1 l\\u00edt", "qty": 2, "unit_price": 385000.0}, {"product_id": 105, "product_code": "aa137a76-b19a-456d-abc9-fefb303c0521", "name": "B\\u00e1nh c\\u00e1 v\\u1ecb rong bi\\u1ec3n tuy\\u1ebft xanh Orion Marine Boy h\\u1ed9p 32g", "qty": 1, "unit_price": 12350.0}, {"product_id": 157, "product_code": "9945b4f0-0b1d-46e2-b225-2cded06debbf", "name": "Kh\\u0103n \\u01b0\\u1edbt Baby (G\\u00f3i 80 t\\u1edd)", "qty": 3, "unit_price": 25000.0}]	5	1065100	[{"product_id": 66, "product_code": "59989980-7fbb-4c6a-bf32-5d2cb1fa21c5", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Happy Star Vinamilk 100g", "score": 0.8}, {"product_id": 5, "product_code": "9258ca2f-5e05-4eac-be09-b5a69a4b9cd0", "name": "N\\u01b0\\u1edbc m\\u1eafm Nam Ng\\u01b0 nh\\u00e3n v\\u00e0ng 14 \\u0111\\u1ed9 \\u0111\\u1ea1m", "score": 0.97}]	f	2026-03-13 07:36:15.936419
180	HCM_Q1	TXN-20260304-00180	2026-03-04 06:30:15.947686+00	38	EDGE_HCM_Q1_01	[{"product_id": 40, "product_code": "662bdd0b-b218-4630-b448-3d2702743375", "name": "Th\\u00f9ng 48 h\\u1ed9p s\\u1eefa t\\u01b0\\u01a1i ti\\u1ec7t tr\\u00f9ng nguy\\u00ean ch\\u1ea5t TH true MILK 180ml", "qty": 2, "unit_price": 425000.0}, {"product_id": 115, "product_code": "11086cc9-d30a-4145-acaf-8e2084c851f0", "name": "T\\u01b0\\u01a1ng \\u1edbt Chinsu (250g)", "qty": 1, "unit_price": 12000.0}, {"product_id": 60, "product_code": "af2ba8ff-ed0a-4780-9152-5d873dba29b3", "name": "L\\u00f4\\u0301c 4 h\\u00f4\\u0323p s\\u01b0\\u0303a chua co\\u0301 \\u0111\\u01b0\\u01a1\\u0300ng Nutimilk 100g", "qty": 2, "unit_price": 20800.0}, {"product_id": 187, "product_code": "8d1b6427-b718-48bd-8808-6af55eca8d5a", "name": "V\\u1edf h\\u1ecdc sinh 96 trang", "qty": 1, "unit_price": 6800.0}]	4	910400	[{"product_id": 49, "product_code": "7ca3de98-74e3-4a43-9113-06cb5c8f9e50", "name": "L\\u1ed1c 4 h\\u1ed9p s\\u1eefa l\\u00faa m\\u1ea1ch Ovaltine DHA+ 180ml", "score": 0.79}, {"product_id": 146, "product_code": "fd9f259d-1ea9-4994-ae7d-d00f930fcde4", "name": "N\\u01b0\\u1edbc t\\u1ea9y b\\u1ed3n c\\u1ea7u Vim (900ml)", "score": 0.88}]	f	2026-03-04 06:30:15.947686
\.


--
-- Data for Name: user_accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_accounts (id, email, password_hash, is_admin, customer_pk, created_at) FROM stdin;
1	customer0001@gmail.com	$2b$12$KjsalJFdNWaOGGFWpx7UYe03TVxCczkq6hkXEXnpa5wGdukSFMvRC	f	1	2026-03-31 17:39:14.035216
2	customer0002@gmail.com	$2b$12$JxAgxfY85z7EUqBlm3DTZeOHj8lNFn7AwHWh7jG2vf1yk/FXL.Ziq	f	2	2026-03-31 17:39:14.035216
3	customer0003@gmail.com	$2b$12$QtY2fYJoQEDXNC5tUX3iz.wS4tOtr8w1wBguGzGzPmZFgq7D56wNe	f	3	2026-03-31 17:39:14.035216
4	customer0004@gmail.com	$2b$12$q4XLo3aLLHLJ35M2KTJpAO/ewtPIljY59tBPKcoSUOpiu5TK6bk.i	f	4	2026-03-31 17:39:14.035216
5	customer0005@gmail.com	$2b$12$HIidieyjR9h5i8ItR.hdLOcYNtDKjel0VUrywC5kOpNSzpfJkEyEO	f	5	2026-03-31 17:39:14.035216
6	customer0006@gmail.com	$2b$12$PJsKy2UgFr6/xOOWHfd/a.60lzwdPTEYDnjKLO9aMyQdsnn6.3BEC	f	6	2026-03-31 17:39:14.035216
7	customer0007@gmail.com	$2b$12$3ZgP6Ze91Ko3TnAG72TLQuR/xVtwhCB29pbK819997pCcZtTPYOA6	f	7	2026-03-31 17:39:14.035216
8	customer0008@gmail.com	$2b$12$mecgV991nCgY2bQGLSNZLuSKhSOXHLQXMxF6kXtI2Nbgphjvmq71W	f	8	2026-03-31 17:39:14.035216
9	customer0009@gmail.com	$2b$12$GgITfQ5invhj3B8v45kuQ.hrsbK6HXsb8vs2DjxcozhlNrd3O/npa	f	9	2026-03-31 17:39:14.035216
10	customer0010@gmail.com	$2b$12$mYKKDkDsxcsSOSI6EeVvXuoZqvEOIy1ct1i71MQnE7ZHe1ZX4Hy8u	f	10	2026-03-31 17:39:14.035216
11	customer0011@gmail.com	$2b$12$PjmheppVl.6ov3MN1i5NJeBEl5rzqoH4yqErUk47X8luKgWR0BjTu	f	11	2026-03-31 17:39:14.035216
12	customer0012@gmail.com	$2b$12$VJu/E8X.LH186OBxnRJgWe6JElcrzpz40D4kRzth8h.QGPcTLoH/i	f	12	2026-03-31 17:39:14.035216
13	customer0013@gmail.com	$2b$12$ENAiGLUNAHvWG.Ovc2xVgeFUgrNtdAocEk1w3LXuR3ZNR2oNKyTlq	f	13	2026-03-31 17:39:14.035216
14	customer0014@gmail.com	$2b$12$36C/3PLbQC0eDZhP7qJlwegoPxp8ipRLzGb8cOs47mrcNwYaeOxdu	f	14	2026-03-31 17:39:14.035216
15	customer0015@gmail.com	$2b$12$2RFacZZ7d0Lo42M.6CFnnuScv0n46aorhrFYSdbGgFBpQWk2HhpZ2	f	15	2026-03-31 17:39:14.035216
16	customer0016@gmail.com	$2b$12$o3mo66wElf24r6gfIhQVjujnQgjSIPtuhECJ6pcb.bNlh.rtCdkQC	f	16	2026-03-31 17:39:14.035216
17	customer0017@gmail.com	$2b$12$c3a9YkIfEzV3r/EocQEg5ONdmBRq67DNF3Idp85m71Ozav7kAz9v.	f	17	2026-03-31 17:39:14.035216
18	customer0018@gmail.com	$2b$12$BnVokFf6N9rRNZJdE5em/uy3sKfoFnQuWZ2tuqw4zSgfBcA/6adrS	f	18	2026-03-31 17:39:14.035216
19	customer0019@gmail.com	$2b$12$xsMqnDW7AQtWmi1TqWjMZuVDklRVj0CHNAQXsKbEf1UwGEGob8uRO	f	19	2026-03-31 17:39:14.035216
20	customer0020@gmail.com	$2b$12$acMhgKU3ur/lnGzarWMH/e8nWEfwWOfp0/QufxJt.LMwqD4VqK0v2	f	20	2026-03-31 17:39:14.035216
21	customer0021@gmail.com	$2b$12$oR51u6li0ZOz0Nkvvlf.Lu50JMDxAq4Zmal6.ZyRobejeEvQR7HQ.	f	21	2026-03-31 17:39:14.035216
22	customer0022@gmail.com	$2b$12$qwEiMMzgyHCIg1ZU25eaH.StD89F2sX10wPzi8KLh1rddQDPL4i7S	f	22	2026-03-31 17:39:14.035216
23	customer0023@gmail.com	$2b$12$7iMw80SdhFz9QkK8HmJAY.IkKf8Rk6X8l5VAXE2QCL9prudylXGsi	f	23	2026-03-31 17:39:14.035216
24	customer0024@gmail.com	$2b$12$uNmiPhRXKjgaGu80CXMJ5eb6RBu8HRTbDiS5j/BgRcgFNkCCTS.9G	f	24	2026-03-31 17:39:14.035216
25	customer0025@gmail.com	$2b$12$lK7A9Mf2erwI7o2DnXATNeJVxmERjCb1jpxAmNgNUG/PbYpp.Gdpq	f	25	2026-03-31 17:39:14.035216
26	customer0026@gmail.com	$2b$12$OGIpe8Z8nEqFx/0xIIiWB.2KSZSTzphXP7Yty67enqXLGwYk7.lIW	f	26	2026-03-31 17:39:14.035216
27	customer0027@gmail.com	$2b$12$IGjnKjpt2KHbJvPHe1fF4O/l1WHTt8ze7mPA2KA8rFQbBUtBk3zeK	f	27	2026-03-31 17:39:14.035216
28	customer0028@gmail.com	$2b$12$BYxx//fHQ9y7MxTgI3DIquoZLpCVZOcwfG/yMzkXOt.Bc.OvTTl3.	f	28	2026-03-31 17:39:14.035216
29	customer0029@gmail.com	$2b$12$S0CwR4JdRUQ07J4FxshbNe/7RS1WeVGldZK1lLhB96QwgzFlQV152	f	29	2026-03-31 17:39:14.035216
30	customer0030@gmail.com	$2b$12$.buw7cpvFlsUVmrz5gukCOcdx2K6hpPoJYL15rTtAy1/2ZiBvnBrC	f	30	2026-03-31 17:39:14.035216
31	customer0031@gmail.com	$2b$12$8pOC0hst3v4WSYOp.L2.ZOyw/hgVObti69jUJ.5MbCvDbdHdoGlpi	f	31	2026-03-31 17:39:14.035216
32	customer0032@gmail.com	$2b$12$ZeFnjMXRoAWlVTbEwSZf/.0t4m/4vSNtfiZL2..xTkxC21EJrOgei	f	32	2026-03-31 17:39:14.035216
33	customer0033@gmail.com	$2b$12$sbHvFQhOt6Sy3kS9N262beHJaTIU5pTLWVwAiUv4KyoIQJVs3xyj2	f	33	2026-03-31 17:39:14.035216
34	customer0034@gmail.com	$2b$12$e8BmNyyrSIKia7FlQ5UdPOvs9S1x0NKvHicdMKjyC8FD0qNpI0YZ6	f	34	2026-03-31 17:39:14.035216
35	customer0035@gmail.com	$2b$12$rmlfMqFICygNpa0gvwdFquTusdOgTP9a78.nYT8AGvI6HKqEfhIey	f	35	2026-03-31 17:39:14.035216
36	customer0036@gmail.com	$2b$12$7HDzuhOkzsQccBVZmJqfg.gIcHCx9M5juJKVMd1IadbfuMOAYxLRe	f	36	2026-03-31 17:39:14.035216
37	customer0037@gmail.com	$2b$12$rW3Mz3TD4FbYKlsfeqTGXOukSnPt9t9d/H4d64/NtLljM/eHcBQo6	f	37	2026-03-31 17:39:14.035216
38	customer0038@gmail.com	$2b$12$1AcW400K6z6vAKVHx9Jd4.n9KLwubyOnha/u4jo9eFWvahEf3qsUG	f	38	2026-03-31 17:39:14.035216
39	customer0039@gmail.com	$2b$12$3kZSk612IHEJnmW8JoEutOoQzV6t/rprQ16JrgMznFjtA.b3k7efu	f	39	2026-03-31 17:39:14.035216
40	customer0040@gmail.com	$2b$12$vamPQKTDJiLWiKf7l7Vtv.r/DubkhWdGLt7CYqwikNloxZ0v/ifma	f	40	2026-03-31 17:39:14.035216
41	customer0041@gmail.com	$2b$12$I/oaIhL9MKTs11ClivBH1OXn4YJzuQPuBi4D45Lr8F0c8s.yafxSS	f	41	2026-03-31 17:39:14.035216
42	customer0042@gmail.com	$2b$12$oN.cwPqUMxbZSun1bLwRQeLS3xqsXZeWSOC8OUabTOrUBwHfpSxFu	f	42	2026-03-31 17:39:14.035216
43	customer0043@gmail.com	$2b$12$3ru2SbA4rzhszTh2kEBPl.OR7dRBg7pkV7WekI4B4ZpbNf8SMRkPG	f	43	2026-03-31 17:39:14.035216
44	customer0044@gmail.com	$2b$12$exNaw0lyu2MVAgOkhWHt4OzjZL2tZFl78WKi/mhlVx.qJ7UVrvteC	f	44	2026-03-31 17:39:14.035216
45	customer0045@gmail.com	$2b$12$FqrixoJz9rJ5IoysOlu1p.ls5n1u5vh.4q1wdqciQn0bMuF2xBvny	f	45	2026-03-31 17:39:14.035216
46	customer0046@gmail.com	$2b$12$dEqDe/J3BYMx/2e1qHQaxO1/R4/P5jLwY4DyTT7tMMRcBMPT8AFZW	f	46	2026-03-31 17:39:14.035216
47	customer0047@gmail.com	$2b$12$ebgstvgx57QjYd0dzkTPXuRQs7Ic0HkJ8gVPYp2xOeKIC2d8vT2LO	f	47	2026-03-31 17:39:14.035216
48	customer0048@gmail.com	$2b$12$f3OIHEW3yBw6n1fxMAqaqO9WDW5e5xMdN9EJLbuHWAQdL6ucLVMGO	f	48	2026-03-31 17:39:14.035216
49	customer0049@gmail.com	$2b$12$wq9MBcbGoKxZoBwHLMglvufSf46z0QYuYgkwCq4KUoa805eLGENXm	f	49	2026-03-31 17:39:14.035216
50	customer0050@gmail.com	$2b$12$jescwcTvw8wNIUapzJfo/uXLqXviDnEIpZO/WvwFJDxZB/MUEcv6y	f	50	2026-03-31 17:39:14.035216
51	customer0051@gmail.com	$2b$12$UAwIyalkos2HCr4IOcJnkeRQSQ/3Z8HJMLC/QoGV8qmyG7zpZUqZ2	f	51	2026-03-31 17:39:14.035216
52	customer0052@gmail.com	$2b$12$R1ToTeKNM3KHdRZTPhGUVe122O/AFjrPlUNU0ZOGT0RiMi4ly254C	f	52	2026-03-31 17:39:14.035216
53	customer0053@gmail.com	$2b$12$EXQYvXNxDnqvZQ5.gqzZsumcx1nVjKrjBBK/XHwhvw7Doj2MwfFgq	f	53	2026-03-31 17:39:14.035216
54	customer0054@gmail.com	$2b$12$0w22eiN3mJbDUq8BefQwYORYo05v2gfe.tQbn2Cs3oGEJUk8OdFVC	f	54	2026-03-31 17:39:14.035216
55	customer0055@gmail.com	$2b$12$yKqhQjPd.k5mPEQ8wktiqu07li7.A7mIy8JdCcOzFtbrJUL9nYfmC	f	55	2026-03-31 17:39:14.035216
56	customer0056@gmail.com	$2b$12$w3FApXlt9KaoiDehXXfbwOa/fxE/XP0zdPwPwHPJZeZpsNfsjqlW6	f	56	2026-03-31 17:39:14.035216
57	customer0057@gmail.com	$2b$12$hIa53c0hGhFpNB/KY0m2nOv98AJciPCKWFx9lA.0YjiXb20XZn6Qi	f	57	2026-03-31 17:39:14.035216
58	customer0058@gmail.com	$2b$12$Owsa1kOiTqUOykkdoFnoK.n8c44XEwio.nAah10/r49Z/gpjrlot.	f	58	2026-03-31 17:39:14.035216
59	customer0059@gmail.com	$2b$12$rHILDdzOg7NtcRZOA4iHkeXqN7VdpP0MynGepRr3k6klaAhcaigzS	f	59	2026-03-31 17:39:14.035216
60	customer0060@gmail.com	$2b$12$tkX0K8F6XmB5NykOkWc6Ru/bpEMQKoKR99tlwKx8Di9pLbLhT0fGa	f	60	2026-03-31 17:39:14.035216
61	admin@gmail.com	$2b$12$hvZeT6WWRI26kN8bBKNfUendKlepx7Wq1yRsBab0hZNp7lwCSjWwm	t	\N	2026-04-02 10:59:26.774977
\.


--
-- Name: ab_experiment_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ab_experiment_events_id_seq', 120, true);


--
-- Name: ab_experiments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ab_experiments_id_seq', 1, true);


--
-- Name: branch_inventory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.branch_inventory_id_seq', 615, true);


--
-- Name: branch_metrics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.branch_metrics_id_seq', 99, true);


--
-- Name: customer_consents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customer_consents_id_seq', 60, true);


--
-- Name: customer_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customer_stats_id_seq', 60, true);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customers_id_seq', 60, true);


--
-- Name: face_embeddings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.face_embeddings_id_seq', 1, false);


--
-- Name: face_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.face_events_id_seq', 180, true);


--
-- Name: federated_client_updates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.federated_client_updates_id_seq', 9, true);


--
-- Name: federated_learning_rounds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.federated_learning_rounds_id_seq', 3, true);


--
-- Name: inventory_optimizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_optimizations_id_seq', 60, true);


--
-- Name: model_performance_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.model_performance_logs_id_seq', 42, true);


--
-- Name: model_versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.model_versions_id_seq', 2, true);


--
-- Name: privacy_audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.privacy_audit_logs_id_seq', 60, true);


--
-- Name: product_associations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_associations_id_seq', 307, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 205, true);


--
-- Name: promotion_branches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.promotion_branches_id_seq', 3, true);


--
-- Name: promotion_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.promotion_products_id_seq', 24, true);


--
-- Name: promotions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.promotions_id_seq', 2, true);


--
-- Name: recommendations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recommendations_id_seq', 180, true);


--
-- Name: transaction_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transaction_items_id_seq', 548, true);


--
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transactions_id_seq', 180, true);


--
-- Name: user_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_accounts_id_seq', 61, true);


--
-- Name: product_associations _product_related_uc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_associations
    ADD CONSTRAINT _product_related_uc UNIQUE (product_id, related_product_id);


--
-- Name: ab_experiment_events ab_experiment_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_experiment_events
    ADD CONSTRAINT ab_experiment_events_pkey PRIMARY KEY (id);


--
-- Name: ab_experiments ab_experiments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_experiments
    ADD CONSTRAINT ab_experiments_pkey PRIMARY KEY (id);


--
-- Name: branch_inventory branch_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_inventory
    ADD CONSTRAINT branch_inventory_pkey PRIMARY KEY (id);


--
-- Name: branch_metrics branch_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_metrics
    ADD CONSTRAINT branch_metrics_pkey PRIMARY KEY (id);


--
-- Name: customer_consents customer_consents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_consents
    ADD CONSTRAINT customer_consents_pkey PRIMARY KEY (id);


--
-- Name: customer_stats customer_stats_customer_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_stats
    ADD CONSTRAINT customer_stats_customer_id_key UNIQUE (customer_id);


--
-- Name: customer_stats customer_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_stats
    ADD CONSTRAINT customer_stats_pkey PRIMARY KEY (id);


--
-- Name: customers customers_cccd_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_cccd_key UNIQUE (cccd);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: edge_devices edge_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edge_devices
    ADD CONSTRAINT edge_devices_pkey PRIMARY KEY (id);


--
-- Name: face_embeddings face_embeddings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.face_embeddings
    ADD CONSTRAINT face_embeddings_pkey PRIMARY KEY (id);


--
-- Name: face_events face_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.face_events
    ADD CONSTRAINT face_events_pkey PRIMARY KEY (id);


--
-- Name: federated_client_updates federated_client_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federated_client_updates
    ADD CONSTRAINT federated_client_updates_pkey PRIMARY KEY (id);


--
-- Name: federated_learning_rounds federated_learning_rounds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federated_learning_rounds
    ADD CONSTRAINT federated_learning_rounds_pkey PRIMARY KEY (id);


--
-- Name: inventory_optimizations inventory_optimizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_optimizations
    ADD CONSTRAINT inventory_optimizations_pkey PRIMARY KEY (id);


--
-- Name: model_performance_logs model_performance_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_performance_logs
    ADD CONSTRAINT model_performance_logs_pkey PRIMARY KEY (id);


--
-- Name: model_versions model_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_versions
    ADD CONSTRAINT model_versions_pkey PRIMARY KEY (id);


--
-- Name: model_versions model_versions_version_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_versions
    ADD CONSTRAINT model_versions_version_key UNIQUE (version);


--
-- Name: privacy_audit_logs privacy_audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.privacy_audit_logs
    ADD CONSTRAINT privacy_audit_logs_pkey PRIMARY KEY (id);


--
-- Name: product_associations product_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_associations
    ADD CONSTRAINT product_associations_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: promotion_branches promotion_branches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_branches
    ADD CONSTRAINT promotion_branches_pkey PRIMARY KEY (id);


--
-- Name: promotion_products promotion_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_products
    ADD CONSTRAINT promotion_products_pkey PRIMARY KEY (id);


--
-- Name: promotions promotions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_pkey PRIMARY KEY (id);


--
-- Name: recommendations recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: stores stores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (id);


--
-- Name: transaction_items transaction_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_items
    ADD CONSTRAINT transaction_items_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: branch_inventory uq_branch_inventory_branch_product; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_inventory
    ADD CONSTRAINT uq_branch_inventory_branch_product UNIQUE (branch_id, product_id);


--
-- Name: branch_metrics uq_branch_metrics_branch_date; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_metrics
    ADD CONSTRAINT uq_branch_metrics_branch_date UNIQUE (branch_id, date);


--
-- Name: inventory_optimizations uq_inventory_opt_branch_product_action; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_optimizations
    ADD CONSTRAINT uq_inventory_opt_branch_product_action UNIQUE (branch_id, product_id, action);


--
-- Name: promotion_branches uq_promotion_branch; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_branches
    ADD CONSTRAINT uq_promotion_branch UNIQUE (promotion_id, branch_id);


--
-- Name: promotion_products uq_promotion_product; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_products
    ADD CONSTRAINT uq_promotion_product UNIQUE (promotion_id, product_id);


--
-- Name: user_accounts user_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_accounts
    ADD CONSTRAINT user_accounts_pkey PRIMARY KEY (id);


--
-- Name: ix_ab_experiment_events_experiment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ab_experiment_events_experiment_id ON public.ab_experiment_events USING btree (experiment_id);


--
-- Name: ix_ab_experiment_events_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ab_experiment_events_id ON public.ab_experiment_events USING btree (id);


--
-- Name: ix_ab_experiment_events_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ab_experiment_events_timestamp ON public.ab_experiment_events USING btree ("timestamp");


--
-- Name: ix_ab_experiments_experiment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_ab_experiments_experiment_id ON public.ab_experiments USING btree (experiment_id);


--
-- Name: ix_ab_experiments_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ab_experiments_id ON public.ab_experiments USING btree (id);


--
-- Name: ix_branch_inventory_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_branch_inventory_branch_id ON public.branch_inventory USING btree (branch_id);


--
-- Name: ix_branch_inventory_branch_stock; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_branch_inventory_branch_stock ON public.branch_inventory USING btree (branch_id, stock);


--
-- Name: ix_branch_inventory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_branch_inventory_id ON public.branch_inventory USING btree (id);


--
-- Name: ix_branch_inventory_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_branch_inventory_product_id ON public.branch_inventory USING btree (product_id);


--
-- Name: ix_branch_metrics_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_branch_metrics_branch_id ON public.branch_metrics USING btree (branch_id);


--
-- Name: ix_branch_metrics_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_branch_metrics_date ON public.branch_metrics USING btree (date);


--
-- Name: ix_branch_metrics_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_branch_metrics_id ON public.branch_metrics USING btree (id);


--
-- Name: ix_customer_consents_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_customer_consents_customer_id ON public.customer_consents USING btree (customer_id);


--
-- Name: ix_customer_consents_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_customer_consents_id ON public.customer_consents USING btree (id);


--
-- Name: ix_customer_stats_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_customer_stats_id ON public.customer_stats USING btree (id);


--
-- Name: ix_customers_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_customers_customer_id ON public.customers USING btree (customer_id);


--
-- Name: ix_customers_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_customers_id ON public.customers USING btree (id);


--
-- Name: ix_edge_devices_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_edge_devices_branch_id ON public.edge_devices USING btree (branch_id);


--
-- Name: ix_edge_devices_last_seen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_edge_devices_last_seen ON public.edge_devices USING btree (last_seen);


--
-- Name: ix_face_embeddings_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_face_embeddings_customer_id ON public.face_embeddings USING btree (customer_id);


--
-- Name: ix_face_embeddings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_face_embeddings_id ON public.face_embeddings USING btree (id);


--
-- Name: ix_face_events_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_face_events_branch_id ON public.face_events USING btree (branch_id);


--
-- Name: ix_face_events_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_face_events_customer_id ON public.face_events USING btree (customer_id);


--
-- Name: ix_face_events_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_face_events_device_id ON public.face_events USING btree (device_id);


--
-- Name: ix_face_events_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_face_events_id ON public.face_events USING btree (id);


--
-- Name: ix_face_events_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_face_events_timestamp ON public.face_events USING btree ("timestamp");


--
-- Name: ix_face_events_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_face_events_transaction_id ON public.face_events USING btree (transaction_id);


--
-- Name: ix_federated_client_updates_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_federated_client_updates_branch_id ON public.federated_client_updates USING btree (branch_id);


--
-- Name: ix_federated_client_updates_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_federated_client_updates_id ON public.federated_client_updates USING btree (id);


--
-- Name: ix_federated_client_updates_round_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_federated_client_updates_round_number ON public.federated_client_updates USING btree (round_number);


--
-- Name: ix_federated_learning_rounds_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_federated_learning_rounds_id ON public.federated_learning_rounds USING btree (id);


--
-- Name: ix_federated_learning_rounds_round_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_federated_learning_rounds_round_number ON public.federated_learning_rounds USING btree (round_number);


--
-- Name: ix_inventory_optimizations_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_inventory_optimizations_branch_id ON public.inventory_optimizations USING btree (branch_id);


--
-- Name: ix_inventory_optimizations_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_inventory_optimizations_id ON public.inventory_optimizations USING btree (id);


--
-- Name: ix_inventory_optimizations_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_inventory_optimizations_product_id ON public.inventory_optimizations USING btree (product_id);


--
-- Name: ix_model_performance_logs_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_model_performance_logs_date ON public.model_performance_logs USING btree (date);


--
-- Name: ix_model_performance_logs_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_model_performance_logs_id ON public.model_performance_logs USING btree (id);


--
-- Name: ix_model_performance_logs_model_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_model_performance_logs_model_version ON public.model_performance_logs USING btree (model_version);


--
-- Name: ix_model_versions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_model_versions_id ON public.model_versions USING btree (id);


--
-- Name: ix_privacy_audit_logs_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_privacy_audit_logs_customer_id ON public.privacy_audit_logs USING btree (customer_id);


--
-- Name: ix_privacy_audit_logs_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_privacy_audit_logs_id ON public.privacy_audit_logs USING btree (id);


--
-- Name: ix_privacy_audit_logs_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_privacy_audit_logs_timestamp ON public.privacy_audit_logs USING btree ("timestamp");


--
-- Name: ix_product_associations_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_product_associations_id ON public.product_associations USING btree (id);


--
-- Name: ix_product_associations_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_product_associations_product_id ON public.product_associations USING btree (product_id);


--
-- Name: ix_product_associations_related_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_product_associations_related_product_id ON public.product_associations USING btree (related_product_id);


--
-- Name: ix_products_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_products_id ON public.products USING btree (id);


--
-- Name: ix_products_product_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_products_product_code ON public.products USING btree (product_code);


--
-- Name: ix_promotion_branches_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_promotion_branches_branch_id ON public.promotion_branches USING btree (branch_id);


--
-- Name: ix_promotion_branches_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_promotion_branches_id ON public.promotion_branches USING btree (id);


--
-- Name: ix_promotion_products_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_promotion_products_id ON public.promotion_products USING btree (id);


--
-- Name: ix_promotion_products_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_promotion_products_product_id ON public.promotion_products USING btree (product_id);


--
-- Name: ix_promotions_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_promotions_code ON public.promotions USING btree (code);


--
-- Name: ix_promotions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_promotions_id ON public.promotions USING btree (id);


--
-- Name: ix_recommendations_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_recommendations_branch_id ON public.recommendations USING btree (branch_id);


--
-- Name: ix_recommendations_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_recommendations_customer_id ON public.recommendations USING btree (customer_id);


--
-- Name: ix_recommendations_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_recommendations_device_id ON public.recommendations USING btree (device_id);


--
-- Name: ix_recommendations_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_recommendations_id ON public.recommendations USING btree (id);


--
-- Name: ix_recommendations_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_recommendations_timestamp ON public.recommendations USING btree ("timestamp");


--
-- Name: ix_recommendations_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_recommendations_transaction_id ON public.recommendations USING btree (transaction_id);


--
-- Name: ix_transaction_items_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transaction_items_product_id ON public.transaction_items USING btree (product_id);


--
-- Name: ix_transaction_items_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transaction_items_transaction_id ON public.transaction_items USING btree (transaction_id);


--
-- Name: ix_transactions_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_branch_id ON public.transactions USING btree (branch_id);


--
-- Name: ix_transactions_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_customer_id ON public.transactions USING btree (customer_id);


--
-- Name: ix_transactions_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_device_id ON public.transactions USING btree (device_id);


--
-- Name: ix_transactions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_id ON public.transactions USING btree (id);


--
-- Name: ix_transactions_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_timestamp ON public.transactions USING btree ("timestamp");


--
-- Name: ix_transactions_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_transactions_transaction_id ON public.transactions USING btree (transaction_id);


--
-- Name: ix_user_accounts_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_user_accounts_email ON public.user_accounts USING btree (email);


--
-- Name: ix_user_accounts_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_accounts_id ON public.user_accounts USING btree (id);


--
-- Name: ab_experiment_events ab_experiment_events_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_experiment_events
    ADD CONSTRAINT ab_experiment_events_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.stores(id);


--
-- Name: ab_experiment_events ab_experiment_events_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_experiment_events
    ADD CONSTRAINT ab_experiment_events_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: ab_experiment_events ab_experiment_events_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_experiment_events
    ADD CONSTRAINT ab_experiment_events_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.edge_devices(id);


--
-- Name: ab_experiment_events ab_experiment_events_experiment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_experiment_events
    ADD CONSTRAINT ab_experiment_events_experiment_id_fkey FOREIGN KEY (experiment_id) REFERENCES public.ab_experiments(experiment_id) ON DELETE CASCADE;


--
-- Name: branch_inventory branch_inventory_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_inventory
    ADD CONSTRAINT branch_inventory_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.stores(id);


--
-- Name: branch_inventory branch_inventory_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_inventory
    ADD CONSTRAINT branch_inventory_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: branch_metrics branch_metrics_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_metrics
    ADD CONSTRAINT branch_metrics_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.stores(id);


--
-- Name: customer_consents customer_consents_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_consents
    ADD CONSTRAINT customer_consents_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: customer_stats customer_stats_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_stats
    ADD CONSTRAINT customer_stats_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: customers customers_preferred_branch_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_preferred_branch_fkey FOREIGN KEY (preferred_branch) REFERENCES public.stores(id);


--
-- Name: edge_devices edge_devices_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edge_devices
    ADD CONSTRAINT edge_devices_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.stores(id);


--
-- Name: face_embeddings face_embeddings_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.face_embeddings
    ADD CONSTRAINT face_embeddings_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: face_events face_events_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.face_events
    ADD CONSTRAINT face_events_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.stores(id);


--
-- Name: face_events face_events_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.face_events
    ADD CONSTRAINT face_events_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: face_events face_events_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.face_events
    ADD CONSTRAINT face_events_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.edge_devices(id);


--
-- Name: federated_client_updates federated_client_updates_round_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federated_client_updates
    ADD CONSTRAINT federated_client_updates_round_number_fkey FOREIGN KEY (round_number) REFERENCES public.federated_learning_rounds(round_number) ON DELETE CASCADE;


--
-- Name: inventory_optimizations inventory_optimizations_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_optimizations
    ADD CONSTRAINT inventory_optimizations_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: inventory_optimizations inventory_optimizations_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_optimizations
    ADD CONSTRAINT inventory_optimizations_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: model_performance_logs model_performance_logs_model_version_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_performance_logs
    ADD CONSTRAINT model_performance_logs_model_version_fkey FOREIGN KEY (model_version) REFERENCES public.model_versions(version) ON DELETE CASCADE;


--
-- Name: privacy_audit_logs privacy_audit_logs_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.privacy_audit_logs
    ADD CONSTRAINT privacy_audit_logs_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: product_associations product_associations_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_associations
    ADD CONSTRAINT product_associations_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_associations product_associations_related_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_associations
    ADD CONSTRAINT product_associations_related_product_id_fkey FOREIGN KEY (related_product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: promotion_branches promotion_branches_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_branches
    ADD CONSTRAINT promotion_branches_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: promotion_branches promotion_branches_promotion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_branches
    ADD CONSTRAINT promotion_branches_promotion_id_fkey FOREIGN KEY (promotion_id) REFERENCES public.promotions(id) ON DELETE CASCADE;


--
-- Name: promotion_products promotion_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_products
    ADD CONSTRAINT promotion_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: promotion_products promotion_products_promotion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_products
    ADD CONSTRAINT promotion_products_promotion_id_fkey FOREIGN KEY (promotion_id) REFERENCES public.promotions(id) ON DELETE CASCADE;


--
-- Name: recommendations recommendations_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.stores(id);


--
-- Name: recommendations recommendations_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: recommendations recommendations_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.edge_devices(id);


--
-- Name: transaction_items transaction_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_items
    ADD CONSTRAINT transaction_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: transaction_items transaction_items_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_items
    ADD CONSTRAINT transaction_items_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(id);


--
-- Name: transactions transactions_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.stores(id);


--
-- Name: transactions transactions_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: transactions transactions_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.edge_devices(id);


--
-- Name: user_accounts user_accounts_customer_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_accounts
    ADD CONSTRAINT user_accounts_customer_pk_fkey FOREIGN KEY (customer_pk) REFERENCES public.customers(id);


--
-- PostgreSQL database dump complete
--

\unrestrict bNqaCUhD2zYwzdZNpGNIOcbsf0dkwuKI8mL7CxUX3YSPkMl6tYDXog2OzSMprdu

