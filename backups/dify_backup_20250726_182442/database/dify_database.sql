--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13
-- Dumped by pg_dump version 15.13

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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: uuidv7(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.uuidv7() RETURNS uuid
    LANGUAGE sql PARALLEL SAFE
    AS $$
    -- Replace the first 48 bits of a uuidv4 with the current
    -- number of milliseconds since 1970-01-01 UTC
    -- and set the "ver" field to 7 by setting additional bits
SELECT encode(
               set_bit(
                       set_bit(
                               overlay(uuid_send(gen_random_uuid()) placing
                                       substring(int8send((extract(epoch from clock_timestamp()) * 1000)::bigint) from
                                                 3)
                                       from 1 for 6),
                               52, 1),
                       53, 1), 'hex')::uuid;
$$;


ALTER FUNCTION public.uuidv7() OWNER TO postgres;

--
-- Name: FUNCTION uuidv7(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.uuidv7() IS 'Generate a uuid-v7 value with a 48-bit timestamp (millisecond precision) and 74 bits of randomness';


--
-- Name: uuidv7_boundary(timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.uuidv7_boundary(timestamp with time zone) RETURNS uuid
    LANGUAGE sql STABLE STRICT PARALLEL SAFE
    AS $_$
    /* uuid fields: version=0b0111, variant=0b10 */
SELECT encode(
               overlay('\x00000000000070008000000000000000'::bytea
                       placing substring(int8send(floor(extract(epoch from $1) * 1000)::bigint) from 3)
                       from 1 for 6),
               'hex')::uuid;
$_$;


ALTER FUNCTION public.uuidv7_boundary(timestamp with time zone) OWNER TO postgres;

--
-- Name: FUNCTION uuidv7_boundary(timestamp with time zone); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.uuidv7_boundary(timestamp with time zone) IS 'Generate a non-random uuidv7 with the given timestamp (first 48 bits) and all random bits to 0. As the smallest possible uuidv7 for that timestamp, it may be used as a boundary for partitions.';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_integrates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_integrates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    account_id uuid NOT NULL,
    provider character varying(16) NOT NULL,
    open_id character varying(255) NOT NULL,
    encrypted_token character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.account_integrates OWNER TO postgres;

--
-- Name: account_plugin_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_plugin_permissions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    install_permission character varying(16) DEFAULT 'everyone'::character varying NOT NULL,
    debug_permission character varying(16) DEFAULT 'noone'::character varying NOT NULL
);


ALTER TABLE public.account_plugin_permissions OWNER TO postgres;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255),
    password_salt character varying(255),
    avatar character varying(255),
    interface_language character varying(255),
    interface_theme character varying(255),
    timezone character varying(255),
    last_login_at timestamp without time zone,
    last_login_ip character varying(255),
    status character varying(16) DEFAULT 'active'::character varying NOT NULL,
    initialized_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    last_active_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.accounts OWNER TO postgres;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: api_based_extensions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_based_extensions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    api_endpoint character varying(255) NOT NULL,
    api_key text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.api_based_extensions OWNER TO postgres;

--
-- Name: api_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_requests (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    api_token_id uuid NOT NULL,
    path character varying(255) NOT NULL,
    request text,
    response text,
    ip character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.api_requests OWNER TO postgres;

--
-- Name: api_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_tokens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid,
    type character varying(16) NOT NULL,
    token character varying(255) NOT NULL,
    last_used_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    tenant_id uuid
);


ALTER TABLE public.api_tokens OWNER TO postgres;

--
-- Name: app_annotation_hit_histories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_annotation_hit_histories (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    annotation_id uuid NOT NULL,
    source text NOT NULL,
    question text NOT NULL,
    account_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    score double precision DEFAULT 0 NOT NULL,
    message_id uuid NOT NULL,
    annotation_question text NOT NULL,
    annotation_content text NOT NULL
);


ALTER TABLE public.app_annotation_hit_histories OWNER TO postgres;

--
-- Name: app_annotation_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_annotation_settings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    score_threshold double precision DEFAULT 0 NOT NULL,
    collection_binding_id uuid NOT NULL,
    created_user_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_user_id uuid NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.app_annotation_settings OWNER TO postgres;

--
-- Name: app_dataset_joins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_dataset_joins (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    dataset_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.app_dataset_joins OWNER TO postgres;

--
-- Name: app_mcp_servers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_mcp_servers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    app_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    server_code character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'normal'::character varying NOT NULL,
    parameters text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.app_mcp_servers OWNER TO postgres;

--
-- Name: app_model_configs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_model_configs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    provider character varying(255),
    model_id character varying(255),
    configs json,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    opening_statement text,
    suggested_questions text,
    suggested_questions_after_answer text,
    more_like_this text,
    model text,
    user_input_form text,
    pre_prompt text,
    agent_mode text,
    speech_to_text text,
    sensitive_word_avoidance text,
    retriever_resource text,
    dataset_query_variable character varying(255),
    prompt_type character varying(255) DEFAULT 'simple'::character varying NOT NULL,
    chat_prompt_config text,
    completion_prompt_config text,
    dataset_configs text,
    external_data_tools text,
    file_upload text,
    text_to_speech text,
    created_by uuid,
    updated_by uuid
);


ALTER TABLE public.app_model_configs OWNER TO postgres;

--
-- Name: apps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.apps (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    mode character varying(255) NOT NULL,
    icon character varying(255),
    icon_background character varying(255),
    app_model_config_id uuid,
    status character varying(255) DEFAULT 'normal'::character varying NOT NULL,
    enable_site boolean NOT NULL,
    enable_api boolean NOT NULL,
    api_rpm integer DEFAULT 0 NOT NULL,
    api_rph integer DEFAULT 0 NOT NULL,
    is_demo boolean DEFAULT false NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    is_universal boolean DEFAULT false NOT NULL,
    workflow_id uuid,
    description text DEFAULT ''::character varying NOT NULL,
    tracing text,
    max_active_requests integer,
    icon_type character varying(255),
    created_by uuid,
    updated_by uuid,
    use_icon_as_answer_icon boolean DEFAULT false NOT NULL
);


ALTER TABLE public.apps OWNER TO postgres;

--
-- Name: task_id_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.task_id_sequence OWNER TO postgres;

--
-- Name: celery_taskmeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.celery_taskmeta (
    id integer DEFAULT nextval('public.task_id_sequence'::regclass) NOT NULL,
    task_id character varying(155),
    status character varying(50),
    result bytea,
    date_done timestamp without time zone,
    traceback text,
    name character varying(155),
    args bytea,
    kwargs bytea,
    worker character varying(155),
    retries integer,
    queue character varying(155)
);


ALTER TABLE public.celery_taskmeta OWNER TO postgres;

--
-- Name: taskset_id_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.taskset_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taskset_id_sequence OWNER TO postgres;

--
-- Name: celery_tasksetmeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.celery_tasksetmeta (
    id integer DEFAULT nextval('public.taskset_id_sequence'::regclass) NOT NULL,
    taskset_id character varying(155),
    result bytea,
    date_done timestamp without time zone
);


ALTER TABLE public.celery_tasksetmeta OWNER TO postgres;

--
-- Name: child_chunks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.child_chunks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    dataset_id uuid NOT NULL,
    document_id uuid NOT NULL,
    segment_id uuid NOT NULL,
    "position" integer NOT NULL,
    content text NOT NULL,
    word_count integer NOT NULL,
    index_node_id character varying(255),
    index_node_hash character varying(255),
    type character varying(255) DEFAULT 'automatic'::character varying NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_by uuid,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    indexing_at timestamp without time zone,
    completed_at timestamp without time zone,
    error text
);


ALTER TABLE public.child_chunks OWNER TO postgres;

--
-- Name: conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    app_model_config_id uuid,
    model_provider character varying(255),
    override_model_configs text,
    model_id character varying(255),
    mode character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    summary text,
    inputs json NOT NULL,
    introduction text,
    system_instruction text,
    system_instruction_tokens integer DEFAULT 0 NOT NULL,
    status character varying(255) NOT NULL,
    from_source character varying(255) NOT NULL,
    from_end_user_id uuid,
    from_account_id uuid,
    read_at timestamp without time zone,
    read_account_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    invoke_from character varying(255),
    dialogue_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.conversations OWNER TO postgres;

--
-- Name: data_source_api_key_auth_bindings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_source_api_key_auth_bindings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    category character varying(255) NOT NULL,
    provider character varying(255) NOT NULL,
    credentials text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    disabled boolean DEFAULT false
);


ALTER TABLE public.data_source_api_key_auth_bindings OWNER TO postgres;

--
-- Name: data_source_oauth_bindings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_source_oauth_bindings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    access_token character varying(255) NOT NULL,
    provider character varying(255) NOT NULL,
    source_info jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    disabled boolean DEFAULT false
);


ALTER TABLE public.data_source_oauth_bindings OWNER TO postgres;

--
-- Name: dataset_auto_disable_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dataset_auto_disable_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    dataset_id uuid NOT NULL,
    document_id uuid NOT NULL,
    notified boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.dataset_auto_disable_logs OWNER TO postgres;

--
-- Name: dataset_collection_bindings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dataset_collection_bindings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    provider_name character varying(255) NOT NULL,
    model_name character varying(255) NOT NULL,
    collection_name character varying(64) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    type character varying(40) DEFAULT 'dataset'::character varying NOT NULL
);


ALTER TABLE public.dataset_collection_bindings OWNER TO postgres;

--
-- Name: dataset_keyword_tables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dataset_keyword_tables (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    dataset_id uuid NOT NULL,
    keyword_table text NOT NULL,
    data_source_type character varying(255) DEFAULT 'database'::character varying NOT NULL
);


ALTER TABLE public.dataset_keyword_tables OWNER TO postgres;

--
-- Name: dataset_metadata_bindings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dataset_metadata_bindings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    dataset_id uuid NOT NULL,
    metadata_id uuid NOT NULL,
    document_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.dataset_metadata_bindings OWNER TO postgres;

--
-- Name: dataset_metadatas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dataset_metadatas (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    dataset_id uuid NOT NULL,
    type character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    created_by uuid NOT NULL,
    updated_by uuid
);


ALTER TABLE public.dataset_metadatas OWNER TO postgres;

--
-- Name: dataset_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dataset_permissions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    dataset_id uuid NOT NULL,
    account_id uuid NOT NULL,
    has_permission boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    tenant_id uuid NOT NULL
);


ALTER TABLE public.dataset_permissions OWNER TO postgres;

--
-- Name: dataset_process_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dataset_process_rules (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    dataset_id uuid NOT NULL,
    mode character varying(255) DEFAULT 'automatic'::character varying NOT NULL,
    rules text,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.dataset_process_rules OWNER TO postgres;

--
-- Name: dataset_queries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dataset_queries (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    dataset_id uuid NOT NULL,
    content text NOT NULL,
    source character varying(255) NOT NULL,
    source_app_id uuid,
    created_by_role character varying NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.dataset_queries OWNER TO postgres;

--
-- Name: dataset_retriever_resources; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dataset_retriever_resources (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    message_id uuid NOT NULL,
    "position" integer NOT NULL,
    dataset_id uuid NOT NULL,
    dataset_name text NOT NULL,
    document_id uuid,
    document_name text NOT NULL,
    data_source_type text,
    segment_id uuid,
    score double precision,
    content text NOT NULL,
    hit_count integer,
    word_count integer,
    segment_position integer,
    index_node_hash text,
    retriever_from text NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.dataset_retriever_resources OWNER TO postgres;

--
-- Name: datasets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.datasets (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    provider character varying(255) DEFAULT 'vendor'::character varying NOT NULL,
    permission character varying(255) DEFAULT 'only_me'::character varying NOT NULL,
    data_source_type character varying(255),
    indexing_technique character varying(255),
    index_struct text,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_by uuid,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    embedding_model character varying(255) DEFAULT 'text-embedding-ada-002'::character varying,
    embedding_model_provider character varying(255) DEFAULT 'openai'::character varying,
    collection_binding_id uuid,
    retrieval_model jsonb,
    built_in_field_enabled boolean DEFAULT false NOT NULL
);


ALTER TABLE public.datasets OWNER TO postgres;

--
-- Name: dify_setups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dify_setups (
    version character varying(255) NOT NULL,
    setup_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.dify_setups OWNER TO postgres;

--
-- Name: document_segments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_segments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    dataset_id uuid NOT NULL,
    document_id uuid NOT NULL,
    "position" integer NOT NULL,
    content text NOT NULL,
    word_count integer NOT NULL,
    tokens integer NOT NULL,
    keywords json,
    index_node_id character varying(255),
    index_node_hash character varying(255),
    hit_count integer NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    disabled_at timestamp without time zone,
    disabled_by uuid,
    status character varying(255) DEFAULT 'waiting'::character varying NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    indexing_at timestamp without time zone,
    completed_at timestamp without time zone,
    error text,
    stopped_at timestamp without time zone,
    answer text,
    updated_by uuid,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.document_segments OWNER TO postgres;

--
-- Name: documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documents (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    dataset_id uuid NOT NULL,
    "position" integer NOT NULL,
    data_source_type character varying(255) NOT NULL,
    data_source_info text,
    dataset_process_rule_id uuid,
    batch character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    created_from character varying(255) NOT NULL,
    created_by uuid NOT NULL,
    created_api_request_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    processing_started_at timestamp without time zone,
    file_id text,
    word_count integer,
    parsing_completed_at timestamp without time zone,
    cleaning_completed_at timestamp without time zone,
    splitting_completed_at timestamp without time zone,
    tokens integer,
    indexing_latency double precision,
    completed_at timestamp without time zone,
    is_paused boolean DEFAULT false,
    paused_by uuid,
    paused_at timestamp without time zone,
    error text,
    stopped_at timestamp without time zone,
    indexing_status character varying(255) DEFAULT 'waiting'::character varying NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    disabled_at timestamp without time zone,
    disabled_by uuid,
    archived boolean DEFAULT false NOT NULL,
    archived_reason character varying(255),
    archived_by uuid,
    archived_at timestamp without time zone,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    doc_type character varying(40),
    doc_metadata jsonb,
    doc_form character varying(255) DEFAULT 'text_model'::character varying NOT NULL,
    doc_language character varying(255)
);


ALTER TABLE public.documents OWNER TO postgres;

--
-- Name: embeddings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.embeddings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    hash character varying(64) NOT NULL,
    embedding bytea NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    model_name character varying(255) DEFAULT 'text-embedding-ada-002'::character varying NOT NULL,
    provider_name character varying(255) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.embeddings OWNER TO postgres;

--
-- Name: end_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.end_users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    app_id uuid,
    type character varying(255) NOT NULL,
    external_user_id character varying(255),
    name character varying(255),
    is_anonymous boolean DEFAULT true NOT NULL,
    session_id character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.end_users OWNER TO postgres;

--
-- Name: external_knowledge_apis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.external_knowledge_apis (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    tenant_id uuid NOT NULL,
    settings text,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_by uuid,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.external_knowledge_apis OWNER TO postgres;

--
-- Name: external_knowledge_bindings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.external_knowledge_bindings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    external_knowledge_api_id uuid NOT NULL,
    dataset_id uuid NOT NULL,
    external_knowledge_id text NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_by uuid,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.external_knowledge_bindings OWNER TO postgres;

--
-- Name: installed_apps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.installed_apps (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    app_id uuid NOT NULL,
    app_owner_tenant_id uuid NOT NULL,
    "position" integer NOT NULL,
    is_pinned boolean DEFAULT false NOT NULL,
    last_used_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.installed_apps OWNER TO postgres;

--
-- Name: invitation_codes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invitation_codes (
    id integer NOT NULL,
    batch character varying(255) NOT NULL,
    code character varying(32) NOT NULL,
    status character varying(16) DEFAULT 'unused'::character varying NOT NULL,
    used_at timestamp without time zone,
    used_by_tenant_id uuid,
    used_by_account_id uuid,
    deprecated_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.invitation_codes OWNER TO postgres;

--
-- Name: invitation_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invitation_codes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invitation_codes_id_seq OWNER TO postgres;

--
-- Name: invitation_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invitation_codes_id_seq OWNED BY public.invitation_codes.id;


--
-- Name: load_balancing_model_configs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.load_balancing_model_configs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    provider_name character varying(255) NOT NULL,
    model_name character varying(255) NOT NULL,
    model_type character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    encrypted_config text,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.load_balancing_model_configs OWNER TO postgres;

--
-- Name: message_agent_thoughts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_agent_thoughts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    message_id uuid NOT NULL,
    message_chain_id uuid,
    "position" integer NOT NULL,
    thought text,
    tool text,
    tool_input text,
    observation text,
    tool_process_data text,
    message text,
    message_token integer,
    message_unit_price numeric,
    answer text,
    answer_token integer,
    answer_unit_price numeric,
    tokens integer,
    total_price numeric,
    currency character varying,
    latency double precision,
    created_by_role character varying NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    message_price_unit numeric(10,7) DEFAULT 0.001 NOT NULL,
    answer_price_unit numeric(10,7) DEFAULT 0.001 NOT NULL,
    message_files text,
    tool_labels_str text DEFAULT '{}'::text NOT NULL,
    tool_meta_str text DEFAULT '{}'::text NOT NULL
);


ALTER TABLE public.message_agent_thoughts OWNER TO postgres;

--
-- Name: message_annotations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_annotations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    conversation_id uuid,
    message_id uuid,
    content text NOT NULL,
    account_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    question text,
    hit_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.message_annotations OWNER TO postgres;

--
-- Name: message_chains; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_chains (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    message_id uuid NOT NULL,
    type character varying(255) NOT NULL,
    input text,
    output text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.message_chains OWNER TO postgres;

--
-- Name: message_feedbacks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_feedbacks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    conversation_id uuid NOT NULL,
    message_id uuid NOT NULL,
    rating character varying(255) NOT NULL,
    content text,
    from_source character varying(255) NOT NULL,
    from_end_user_id uuid,
    from_account_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.message_feedbacks OWNER TO postgres;

--
-- Name: message_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_files (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    message_id uuid NOT NULL,
    type character varying(255) NOT NULL,
    transfer_method character varying(255) NOT NULL,
    url text,
    upload_file_id uuid,
    created_by_role character varying(255) NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    belongs_to character varying(255)
);


ALTER TABLE public.message_files OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    model_provider character varying(255),
    model_id character varying(255),
    override_model_configs text,
    conversation_id uuid NOT NULL,
    inputs json NOT NULL,
    query text NOT NULL,
    message json NOT NULL,
    message_tokens integer DEFAULT 0 NOT NULL,
    message_unit_price numeric(10,4) NOT NULL,
    answer text NOT NULL,
    answer_tokens integer DEFAULT 0 NOT NULL,
    answer_unit_price numeric(10,4) NOT NULL,
    provider_response_latency double precision DEFAULT 0 NOT NULL,
    total_price numeric(10,7),
    currency character varying(255) NOT NULL,
    from_source character varying(255) NOT NULL,
    from_end_user_id uuid,
    from_account_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    agent_based boolean DEFAULT false NOT NULL,
    message_price_unit numeric(10,7) DEFAULT 0.001 NOT NULL,
    answer_price_unit numeric(10,7) DEFAULT 0.001 NOT NULL,
    workflow_run_id uuid,
    status character varying(255) DEFAULT 'normal'::character varying NOT NULL,
    error text,
    message_metadata text,
    invoke_from character varying(255),
    parent_message_id uuid
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: operation_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.operation_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    account_id uuid NOT NULL,
    action character varying(255) NOT NULL,
    content json,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    created_ip character varying(255) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.operation_logs OWNER TO postgres;

--
-- Name: pinned_conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pinned_conversations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    conversation_id uuid NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    created_by_role character varying(255) DEFAULT 'end_user'::character varying NOT NULL
);


ALTER TABLE public.pinned_conversations OWNER TO postgres;

--
-- Name: provider_model_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.provider_model_settings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    provider_name character varying(255) NOT NULL,
    model_name character varying(255) NOT NULL,
    model_type character varying(40) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    load_balancing_enabled boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.provider_model_settings OWNER TO postgres;

--
-- Name: provider_models; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.provider_models (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    provider_name character varying(255) NOT NULL,
    model_name character varying(255) NOT NULL,
    model_type character varying(40) NOT NULL,
    encrypted_config text,
    is_valid boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.provider_models OWNER TO postgres;

--
-- Name: provider_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.provider_orders (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    provider_name character varying(255) NOT NULL,
    account_id uuid NOT NULL,
    payment_product_id character varying(191) NOT NULL,
    payment_id character varying(191),
    transaction_id character varying(191),
    quantity integer DEFAULT 1 NOT NULL,
    currency character varying(40),
    total_amount integer,
    payment_status character varying(40) DEFAULT 'wait_pay'::character varying NOT NULL,
    paid_at timestamp without time zone,
    pay_failed_at timestamp without time zone,
    refunded_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.provider_orders OWNER TO postgres;

--
-- Name: providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.providers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    provider_name character varying(255) NOT NULL,
    provider_type character varying(40) DEFAULT 'custom'::character varying NOT NULL,
    encrypted_config text,
    is_valid boolean DEFAULT false NOT NULL,
    last_used timestamp without time zone,
    quota_type character varying(40) DEFAULT ''::character varying,
    quota_limit bigint,
    quota_used bigint,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.providers OWNER TO postgres;

--
-- Name: rate_limit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rate_limit_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    subscription_plan character varying(255) NOT NULL,
    operation character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.rate_limit_logs OWNER TO postgres;

--
-- Name: recommended_apps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recommended_apps (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    description json NOT NULL,
    copyright character varying(255) NOT NULL,
    privacy_policy character varying(255) NOT NULL,
    category character varying(255) NOT NULL,
    "position" integer NOT NULL,
    is_listed boolean NOT NULL,
    install_count integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    language character varying(255) DEFAULT 'en-US'::character varying NOT NULL,
    custom_disclaimer text NOT NULL
);


ALTER TABLE public.recommended_apps OWNER TO postgres;

--
-- Name: saved_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saved_messages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    message_id uuid NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    created_by_role character varying(255) DEFAULT 'end_user'::character varying NOT NULL
);


ALTER TABLE public.saved_messages OWNER TO postgres;

--
-- Name: sites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sites (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    icon character varying(255),
    icon_background character varying(255),
    description text,
    default_language character varying(255) NOT NULL,
    copyright character varying(255),
    privacy_policy character varying(255),
    customize_domain character varying(255),
    customize_token_strategy character varying(255) NOT NULL,
    prompt_public boolean DEFAULT false NOT NULL,
    status character varying(255) DEFAULT 'normal'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    code character varying(255),
    custom_disclaimer text NOT NULL,
    show_workflow_steps boolean DEFAULT true NOT NULL,
    chat_color_theme character varying(255),
    chat_color_theme_inverted boolean DEFAULT false NOT NULL,
    icon_type character varying(255),
    created_by uuid,
    updated_by uuid,
    use_icon_as_answer_icon boolean DEFAULT false NOT NULL
);


ALTER TABLE public.sites OWNER TO postgres;

--
-- Name: tag_bindings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tag_bindings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid,
    tag_id uuid,
    target_id uuid,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.tag_bindings OWNER TO postgres;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tags (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid,
    type character varying(16) NOT NULL,
    name character varying(255) NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.tags OWNER TO postgres;

--
-- Name: tenant_account_joins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tenant_account_joins (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    account_id uuid NOT NULL,
    role character varying(16) DEFAULT 'normal'::character varying NOT NULL,
    invited_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    current boolean DEFAULT false NOT NULL
);


ALTER TABLE public.tenant_account_joins OWNER TO postgres;

--
-- Name: tenant_default_models; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tenant_default_models (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    provider_name character varying(255) NOT NULL,
    model_name character varying(255) NOT NULL,
    model_type character varying(40) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.tenant_default_models OWNER TO postgres;

--
-- Name: tenant_plugin_auto_upgrade_strategies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tenant_plugin_auto_upgrade_strategies (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    strategy_setting character varying(16) DEFAULT 'fix_only'::character varying NOT NULL,
    upgrade_time_of_day integer NOT NULL,
    upgrade_mode character varying(16) DEFAULT 'exclude'::character varying NOT NULL,
    exclude_plugins character varying(255)[] NOT NULL,
    include_plugins character varying(255)[] NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.tenant_plugin_auto_upgrade_strategies OWNER TO postgres;

--
-- Name: tenant_preferred_model_providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tenant_preferred_model_providers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    provider_name character varying(255) NOT NULL,
    preferred_provider_type character varying(40) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.tenant_preferred_model_providers OWNER TO postgres;

--
-- Name: tenants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tenants (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    encrypt_public_key text,
    plan character varying(255) DEFAULT 'basic'::character varying NOT NULL,
    status character varying(255) DEFAULT 'normal'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    custom_config text
);


ALTER TABLE public.tenants OWNER TO postgres;

--
-- Name: tidb_auth_bindings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tidb_auth_bindings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid,
    cluster_id character varying(255) NOT NULL,
    cluster_name character varying(255) NOT NULL,
    active boolean DEFAULT false NOT NULL,
    status character varying(255) DEFAULT 'CREATING'::character varying NOT NULL,
    account character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.tidb_auth_bindings OWNER TO postgres;

--
-- Name: tool_api_providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tool_api_providers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    schema text NOT NULL,
    schema_type_str character varying(40) NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    tools_str text NOT NULL,
    icon character varying(255) NOT NULL,
    credentials_str text NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    privacy_policy character varying(255),
    custom_disclaimer text NOT NULL
);


ALTER TABLE public.tool_api_providers OWNER TO postgres;

--
-- Name: tool_builtin_providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tool_builtin_providers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid,
    user_id uuid NOT NULL,
    provider character varying(256) NOT NULL,
    encrypted_credentials text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    name character varying(256) DEFAULT 'API KEY 1'::character varying NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    credential_type character varying(32) DEFAULT 'api-key'::character varying NOT NULL,
    expires_at bigint DEFAULT '-1'::integer NOT NULL
);


ALTER TABLE public.tool_builtin_providers OWNER TO postgres;

--
-- Name: tool_conversation_variables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tool_conversation_variables (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    conversation_id uuid NOT NULL,
    variables_str text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.tool_conversation_variables OWNER TO postgres;

--
-- Name: tool_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tool_files (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    conversation_id uuid,
    file_key character varying(255) NOT NULL,
    mimetype character varying(255) NOT NULL,
    original_url character varying(2048),
    name character varying NOT NULL,
    size integer NOT NULL
);


ALTER TABLE public.tool_files OWNER TO postgres;

--
-- Name: tool_label_bindings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tool_label_bindings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tool_id character varying(64) NOT NULL,
    tool_type character varying(40) NOT NULL,
    label_name character varying(40) NOT NULL
);


ALTER TABLE public.tool_label_bindings OWNER TO postgres;

--
-- Name: tool_mcp_providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tool_mcp_providers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(40) NOT NULL,
    server_identifier character varying(64) NOT NULL,
    server_url text NOT NULL,
    server_url_hash character varying(64) NOT NULL,
    icon character varying(255),
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    encrypted_credentials text,
    authed boolean NOT NULL,
    tools text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.tool_mcp_providers OWNER TO postgres;

--
-- Name: tool_model_invokes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tool_model_invokes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    provider character varying(255) NOT NULL,
    tool_type character varying(40) NOT NULL,
    tool_name character varying(128) NOT NULL,
    model_parameters text NOT NULL,
    prompt_messages text NOT NULL,
    model_response text NOT NULL,
    prompt_tokens integer DEFAULT 0 NOT NULL,
    answer_tokens integer DEFAULT 0 NOT NULL,
    answer_unit_price numeric(10,4) NOT NULL,
    answer_price_unit numeric(10,7) DEFAULT 0.001 NOT NULL,
    provider_response_latency double precision DEFAULT 0 NOT NULL,
    total_price numeric(10,7),
    currency character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.tool_model_invokes OWNER TO postgres;

--
-- Name: tool_oauth_system_clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tool_oauth_system_clients (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    plugin_id character varying(512) NOT NULL,
    provider character varying(255) NOT NULL,
    encrypted_oauth_params text NOT NULL
);


ALTER TABLE public.tool_oauth_system_clients OWNER TO postgres;

--
-- Name: tool_oauth_tenant_clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tool_oauth_tenant_clients (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    plugin_id character varying(512) NOT NULL,
    provider character varying(255) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    encrypted_oauth_params text NOT NULL
);


ALTER TABLE public.tool_oauth_tenant_clients OWNER TO postgres;

--
-- Name: tool_published_apps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tool_published_apps (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    user_id uuid NOT NULL,
    description text NOT NULL,
    llm_description text NOT NULL,
    query_description text NOT NULL,
    query_name character varying(40) NOT NULL,
    tool_name character varying(40) NOT NULL,
    author character varying(40) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.tool_published_apps OWNER TO postgres;

--
-- Name: tool_workflow_providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tool_workflow_providers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(255) NOT NULL,
    app_id uuid NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    description text NOT NULL,
    parameter_configuration text DEFAULT '[]'::text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    privacy_policy character varying(255) DEFAULT ''::character varying,
    version character varying(255) DEFAULT ''::character varying NOT NULL,
    label character varying(255) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.tool_workflow_providers OWNER TO postgres;

--
-- Name: trace_app_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trace_app_config (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    tracing_provider character varying(255),
    tracing_config json,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.trace_app_config OWNER TO postgres;

--
-- Name: upload_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.upload_files (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    storage_type character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    size integer NOT NULL,
    extension character varying(255) NOT NULL,
    mime_type character varying(255),
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    used boolean DEFAULT false NOT NULL,
    used_by uuid,
    used_at timestamp without time zone,
    hash character varying(255),
    created_by_role character varying(255) DEFAULT 'account'::character varying NOT NULL,
    source_url text DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.upload_files OWNER TO postgres;

--
-- Name: whitelists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.whitelists (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid,
    category character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.whitelists OWNER TO postgres;

--
-- Name: workflow_app_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_app_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    app_id uuid NOT NULL,
    workflow_id uuid NOT NULL,
    workflow_run_id uuid NOT NULL,
    created_from character varying(255) NOT NULL,
    created_by_role character varying(255) NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL
);


ALTER TABLE public.workflow_app_logs OWNER TO postgres;

--
-- Name: workflow_conversation_variables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_conversation_variables (
    id uuid NOT NULL,
    conversation_id uuid NOT NULL,
    app_id uuid NOT NULL,
    data text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.workflow_conversation_variables OWNER TO postgres;

--
-- Name: workflow_draft_variables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_draft_variables (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    app_id uuid NOT NULL,
    last_edited_at timestamp without time zone,
    node_id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    selector character varying(255) NOT NULL,
    value_type character varying(20) NOT NULL,
    value text NOT NULL,
    visible boolean NOT NULL,
    editable boolean NOT NULL,
    node_execution_id uuid
);


ALTER TABLE public.workflow_draft_variables OWNER TO postgres;

--
-- Name: workflow_node_executions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_node_executions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    app_id uuid NOT NULL,
    workflow_id uuid NOT NULL,
    triggered_from character varying(255) NOT NULL,
    workflow_run_id uuid,
    index integer NOT NULL,
    predecessor_node_id character varying(255),
    node_id character varying(255) NOT NULL,
    node_type character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    inputs text,
    process_data text,
    outputs text,
    status character varying(255) NOT NULL,
    error text,
    elapsed_time double precision DEFAULT 0 NOT NULL,
    execution_metadata text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    created_by_role character varying(255) NOT NULL,
    created_by uuid NOT NULL,
    finished_at timestamp without time zone,
    node_execution_id character varying(255)
);


ALTER TABLE public.workflow_node_executions OWNER TO postgres;

--
-- Name: workflow_runs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_runs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    app_id uuid NOT NULL,
    workflow_id uuid NOT NULL,
    type character varying(255) NOT NULL,
    triggered_from character varying(255) NOT NULL,
    version character varying(255) NOT NULL,
    graph text,
    inputs text,
    status character varying(255) NOT NULL,
    outputs text,
    error text,
    elapsed_time double precision DEFAULT 0 NOT NULL,
    total_tokens bigint DEFAULT 0 NOT NULL,
    total_steps integer DEFAULT 0,
    created_by_role character varying(255) NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    finished_at timestamp without time zone,
    exceptions_count integer DEFAULT 0
);


ALTER TABLE public.workflow_runs OWNER TO postgres;

--
-- Name: workflows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflows (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id uuid NOT NULL,
    app_id uuid NOT NULL,
    type character varying(255) NOT NULL,
    version character varying(255) NOT NULL,
    graph text NOT NULL,
    features text NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0) NOT NULL,
    updated_by uuid,
    updated_at timestamp without time zone NOT NULL,
    environment_variables text DEFAULT '{}'::text NOT NULL,
    conversation_variables text DEFAULT '{}'::text NOT NULL,
    marked_name character varying DEFAULT ''::character varying NOT NULL,
    marked_comment character varying DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.workflows OWNER TO postgres;

--
-- Name: invitation_codes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitation_codes ALTER COLUMN id SET DEFAULT nextval('public.invitation_codes_id_seq'::regclass);


--
-- Data for Name: account_integrates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_integrates (id, account_id, provider, open_id, encrypted_token, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: account_plugin_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_plugin_permissions (id, tenant_id, install_permission, debug_permission) FROM stdin;
\.


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accounts (id, name, email, password, password_salt, avatar, interface_language, interface_theme, timezone, last_login_at, last_login_ip, status, initialized_at, created_at, updated_at, last_active_at) FROM stdin;
6cc88c13-1664-485f-a09f-30e14b5c0df8	xiaoxishui	223344lirong@163.com	ZDUzNTYyZjczMTI0YTU2OTQxYjZiNGNmZDcxMDg1NjY3OTJkZjQ0MDEyYWZjMjAzM2VlNmY3NTNkNDY5YzAxOQ==	t80KVRh7qThOXaWTgAfKcg==	\N	en-US	light	America/New_York	2025-07-26 10:09:22.457081	111.181.30.165	active	2025-07-25 16:39:59.654136	2025-07-25 16:40:00	2025-07-25 16:40:00	2025-07-26 10:03:44.287882
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
8bcc02c9bd07
\.


--
-- Data for Name: api_based_extensions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_based_extensions (id, tenant_id, name, api_endpoint, api_key, created_at) FROM stdin;
\.


--
-- Data for Name: api_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_requests (id, tenant_id, api_token_id, path, request, response, ip, created_at) FROM stdin;
\.


--
-- Data for Name: api_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_tokens (id, app_id, type, token, last_used_at, created_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: app_annotation_hit_histories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_annotation_hit_histories (id, app_id, annotation_id, source, question, account_id, created_at, score, message_id, annotation_question, annotation_content) FROM stdin;
\.


--
-- Data for Name: app_annotation_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_annotation_settings (id, app_id, score_threshold, collection_binding_id, created_user_id, created_at, updated_user_id, updated_at) FROM stdin;
\.


--
-- Data for Name: app_dataset_joins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_dataset_joins (id, app_id, dataset_id, created_at) FROM stdin;
\.


--
-- Data for Name: app_mcp_servers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_mcp_servers (id, tenant_id, app_id, name, description, server_code, status, parameters, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: app_model_configs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_model_configs (id, app_id, provider, model_id, configs, created_at, updated_at, opening_statement, suggested_questions, suggested_questions_after_answer, more_like_this, model, user_input_form, pre_prompt, agent_mode, speech_to_text, sensitive_word_avoidance, retriever_resource, dataset_query_variable, prompt_type, chat_prompt_config, completion_prompt_config, dataset_configs, external_data_tools, file_upload, text_to_speech, created_by, updated_by) FROM stdin;
\.


--
-- Data for Name: apps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.apps (id, tenant_id, name, mode, icon, icon_background, app_model_config_id, status, enable_site, enable_api, api_rpm, api_rph, is_demo, is_public, created_at, updated_at, is_universal, workflow_id, description, tracing, max_active_requests, icon_type, created_by, updated_by, use_icon_as_answer_icon) FROM stdin;
8a648738-1479-4f9a-a992-fe23e2fb1c0d	1f6f5922-bac4-41b9-b009-db0d00769fe5	70-dify案例分享-用Kimi-K2+Mermaid 神器，一键生成系统架构图！小白也能秒会	advanced-chat	🤖	#FFEAD5	\N	normal	t	t	0	0	f	f	2025-07-26 02:46:36	2025-07-26 02:46:36	f	\N		\N	\N	emoji	6cc88c13-1664-485f-a09f-30e14b5c0df8	6cc88c13-1664-485f-a09f-30e14b5c0df8	f
4ad4a46e-5086-4c3c-ba45-40239541cf39	1f6f5922-bac4-41b9-b009-db0d00769fe5	68-dify案例分享-用 Dify 一键搭建中药科普工作流，文字 + 图片 + 视频全搞定	advanced-chat	🤖	#FFEAD5	\N	normal	t	t	0	0	f	f	2025-07-26 02:47:21	2025-07-26 02:47:21	f	\N	本工作流主要是通过MCp服务器实现一个中药识别的科普知识	\N	\N	emoji	6cc88c13-1664-485f-a09f-30e14b5c0df8	6cc88c13-1664-485f-a09f-30e14b5c0df8	f
b4e3c93b-5495-41e4-aaa4-57d5004b97c9	1f6f5922-bac4-41b9-b009-db0d00769fe5	64-dify案例分享-豆包文本生成图、文生视频+小支付功能	advanced-chat	🤖	#FFEAD5	\N	normal	t	t	0	0	f	f	2025-07-26 07:34:47	2025-07-26 07:34:47	f	\N	本工作流主要介绍使用了豆包文本生成图像、文本生成视频以及图像转视频功能	\N	\N	emoji	6cc88c13-1664-485f-a09f-30e14b5c0df8	6cc88c13-1664-485f-a09f-30e14b5c0df8	f
a164793c-660a-45b9-9739-b7500c441f39	1f6f5922-bac4-41b9-b009-db0d00769fe5	62-dify案例分享-Dify+RSS 聚合 8 大平台实时热点，新闻获取效率飙升 300%	advanced-chat	🤖	#FFEAD5	\N	normal	t	t	0	0	f	f	2025-07-26 07:35:19	2025-07-26 07:35:19	f	\N	本工作流主要是使用RSS聚合新闻实现实时热点新闻	\N	\N	emoji	6cc88c13-1664-485f-a09f-30e14b5c0df8	6cc88c13-1664-485f-a09f-30e14b5c0df8	f
2d0aa8e2-21ae-402f-908b-27d05e071e7f	1f6f5922-bac4-41b9-b009-db0d00769fe5	60-dify案例分享-豆包文本生成图像、文本生成视频以及图像转视频	advanced-chat	🤖	#FFEAD5	\N	normal	t	t	0	0	f	f	2025-07-26 07:35:44	2025-07-26 07:35:44	f	\N	本工作流主要介绍使用了豆包文本生成图像、文本生成视频以及图像转视频功能	\N	\N	emoji	6cc88c13-1664-485f-a09f-30e14b5c0df8	6cc88c13-1664-485f-a09f-30e14b5c0df8	f
2f4ce0c3-7fc2-4480-8284-13d97f365f41	1f6f5922-bac4-41b9-b009-db0d00769fe5	0718豆包视频制作_剪映草稿生成_修复版	workflow	🎬	#FFEAD5	\N	normal	t	t	0	0	f	f	2025-07-26 07:49:51	2025-07-26 07:49:51	f	\N	豆包AI视频生成到剪映草稿的完整自动化流程	\N	\N	emoji	6cc88c13-1664-485f-a09f-30e14b5c0df8	6cc88c13-1664-485f-a09f-30e14b5c0df8	f
\.


--
-- Data for Name: celery_taskmeta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.celery_taskmeta (id, task_id, status, result, date_done, traceback, name, args, kwargs, worker, retries, queue) FROM stdin;
\.


--
-- Data for Name: celery_tasksetmeta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.celery_tasksetmeta (id, taskset_id, result, date_done) FROM stdin;
\.


--
-- Data for Name: child_chunks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.child_chunks (id, tenant_id, dataset_id, document_id, segment_id, "position", content, word_count, index_node_id, index_node_hash, type, created_by, created_at, updated_by, updated_at, indexing_at, completed_at, error) FROM stdin;
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conversations (id, app_id, app_model_config_id, model_provider, override_model_configs, model_id, mode, name, summary, inputs, introduction, system_instruction, system_instruction_tokens, status, from_source, from_end_user_id, from_account_id, read_at, read_account_id, created_at, updated_at, is_deleted, invoke_from, dialogue_count) FROM stdin;
\.


--
-- Data for Name: data_source_api_key_auth_bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.data_source_api_key_auth_bindings (id, tenant_id, category, provider, credentials, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: data_source_oauth_bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.data_source_oauth_bindings (id, tenant_id, access_token, provider, source_info, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: dataset_auto_disable_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataset_auto_disable_logs (id, tenant_id, dataset_id, document_id, notified, created_at) FROM stdin;
\.


--
-- Data for Name: dataset_collection_bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataset_collection_bindings (id, provider_name, model_name, collection_name, created_at, type) FROM stdin;
\.


--
-- Data for Name: dataset_keyword_tables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataset_keyword_tables (id, dataset_id, keyword_table, data_source_type) FROM stdin;
\.


--
-- Data for Name: dataset_metadata_bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataset_metadata_bindings (id, tenant_id, dataset_id, metadata_id, document_id, created_at, created_by) FROM stdin;
\.


--
-- Data for Name: dataset_metadatas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataset_metadatas (id, tenant_id, dataset_id, type, name, created_at, updated_at, created_by, updated_by) FROM stdin;
\.


--
-- Data for Name: dataset_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataset_permissions (id, dataset_id, account_id, has_permission, created_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: dataset_process_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataset_process_rules (id, dataset_id, mode, rules, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: dataset_queries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataset_queries (id, dataset_id, content, source, source_app_id, created_by_role, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: dataset_retriever_resources; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataset_retriever_resources (id, message_id, "position", dataset_id, dataset_name, document_id, document_name, data_source_type, segment_id, score, content, hit_count, word_count, segment_position, index_node_hash, retriever_from, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: datasets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.datasets (id, tenant_id, name, description, provider, permission, data_source_type, indexing_technique, index_struct, created_by, created_at, updated_by, updated_at, embedding_model, embedding_model_provider, collection_binding_id, retrieval_model, built_in_field_enabled) FROM stdin;
\.


--
-- Data for Name: dify_setups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dify_setups (version, setup_at) FROM stdin;
1.7.0	2025-07-25 16:40:00
\.


--
-- Data for Name: document_segments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.document_segments (id, tenant_id, dataset_id, document_id, "position", content, word_count, tokens, keywords, index_node_id, index_node_hash, hit_count, enabled, disabled_at, disabled_by, status, created_by, created_at, indexing_at, completed_at, error, stopped_at, answer, updated_by, updated_at) FROM stdin;
\.


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.documents (id, tenant_id, dataset_id, "position", data_source_type, data_source_info, dataset_process_rule_id, batch, name, created_from, created_by, created_api_request_id, created_at, processing_started_at, file_id, word_count, parsing_completed_at, cleaning_completed_at, splitting_completed_at, tokens, indexing_latency, completed_at, is_paused, paused_by, paused_at, error, stopped_at, indexing_status, enabled, disabled_at, disabled_by, archived, archived_reason, archived_by, archived_at, updated_at, doc_type, doc_metadata, doc_form, doc_language) FROM stdin;
\.


--
-- Data for Name: embeddings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.embeddings (id, hash, embedding, created_at, model_name, provider_name) FROM stdin;
\.


--
-- Data for Name: end_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.end_users (id, tenant_id, app_id, type, external_user_id, name, is_anonymous, session_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: external_knowledge_apis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.external_knowledge_apis (id, name, description, tenant_id, settings, created_by, created_at, updated_by, updated_at) FROM stdin;
\.


--
-- Data for Name: external_knowledge_bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.external_knowledge_bindings (id, tenant_id, external_knowledge_api_id, dataset_id, external_knowledge_id, created_by, created_at, updated_by, updated_at) FROM stdin;
\.


--
-- Data for Name: installed_apps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.installed_apps (id, tenant_id, app_id, app_owner_tenant_id, "position", is_pinned, last_used_at, created_at) FROM stdin;
a469c9aa-248d-4926-8152-f624610d3875	1f6f5922-bac4-41b9-b009-db0d00769fe5	8a648738-1479-4f9a-a992-fe23e2fb1c0d	1f6f5922-bac4-41b9-b009-db0d00769fe5	0	f	\N	2025-07-26 02:46:35
721f5bfe-6144-45cc-bbc5-89437709e675	1f6f5922-bac4-41b9-b009-db0d00769fe5	4ad4a46e-5086-4c3c-ba45-40239541cf39	1f6f5922-bac4-41b9-b009-db0d00769fe5	0	f	\N	2025-07-26 02:47:21
de7fe872-a3e5-4b45-892c-a1f0c0e6fd78	1f6f5922-bac4-41b9-b009-db0d00769fe5	b4e3c93b-5495-41e4-aaa4-57d5004b97c9	1f6f5922-bac4-41b9-b009-db0d00769fe5	0	f	\N	2025-07-26 07:34:47
1da088e6-1660-480e-ae37-182c4628f790	1f6f5922-bac4-41b9-b009-db0d00769fe5	a164793c-660a-45b9-9739-b7500c441f39	1f6f5922-bac4-41b9-b009-db0d00769fe5	0	f	\N	2025-07-26 07:35:19
28ce89f9-1ac6-4639-ae2f-480556af5edd	1f6f5922-bac4-41b9-b009-db0d00769fe5	2d0aa8e2-21ae-402f-908b-27d05e071e7f	1f6f5922-bac4-41b9-b009-db0d00769fe5	0	f	\N	2025-07-26 07:35:44
852def4e-030c-46e5-ab9f-b0cce8bdf74f	1f6f5922-bac4-41b9-b009-db0d00769fe5	2f4ce0c3-7fc2-4480-8284-13d97f365f41	1f6f5922-bac4-41b9-b009-db0d00769fe5	0	f	\N	2025-07-26 07:49:51
\.


--
-- Data for Name: invitation_codes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invitation_codes (id, batch, code, status, used_at, used_by_tenant_id, used_by_account_id, deprecated_at, created_at) FROM stdin;
\.


--
-- Data for Name: load_balancing_model_configs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.load_balancing_model_configs (id, tenant_id, provider_name, model_name, model_type, name, encrypted_config, enabled, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: message_agent_thoughts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message_agent_thoughts (id, message_id, message_chain_id, "position", thought, tool, tool_input, observation, tool_process_data, message, message_token, message_unit_price, answer, answer_token, answer_unit_price, tokens, total_price, currency, latency, created_by_role, created_by, created_at, message_price_unit, answer_price_unit, message_files, tool_labels_str, tool_meta_str) FROM stdin;
\.


--
-- Data for Name: message_annotations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message_annotations (id, app_id, conversation_id, message_id, content, account_id, created_at, updated_at, question, hit_count) FROM stdin;
\.


--
-- Data for Name: message_chains; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message_chains (id, message_id, type, input, output, created_at) FROM stdin;
\.


--
-- Data for Name: message_feedbacks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message_feedbacks (id, app_id, conversation_id, message_id, rating, content, from_source, from_end_user_id, from_account_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: message_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message_files (id, message_id, type, transfer_method, url, upload_file_id, created_by_role, created_by, created_at, belongs_to) FROM stdin;
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, app_id, model_provider, model_id, override_model_configs, conversation_id, inputs, query, message, message_tokens, message_unit_price, answer, answer_tokens, answer_unit_price, provider_response_latency, total_price, currency, from_source, from_end_user_id, from_account_id, created_at, updated_at, agent_based, message_price_unit, answer_price_unit, workflow_run_id, status, error, message_metadata, invoke_from, parent_message_id) FROM stdin;
\.


--
-- Data for Name: operation_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.operation_logs (id, tenant_id, account_id, action, content, created_at, created_ip, updated_at) FROM stdin;
\.


--
-- Data for Name: pinned_conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pinned_conversations (id, app_id, conversation_id, created_by, created_at, created_by_role) FROM stdin;
\.


--
-- Data for Name: provider_model_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.provider_model_settings (id, tenant_id, provider_name, model_name, model_type, enabled, load_balancing_enabled, created_at, updated_at) FROM stdin;
f5134732-b5cb-479c-8ff4-608d994175b9	1f6f5922-bac4-41b9-b009-db0d00769fe5	langgenius/volcengine_maas/volcengine_maas	doubao-pro-32k/character-240828	text-generation	t	f	2025-07-26 07:57:55	2025-07-26 07:57:55
7f54af48-9074-48ae-99ad-24e7dad1d42f	1f6f5922-bac4-41b9-b009-db0d00769fe5	langgenius/volcengine_maas/volcengine_maas	Doubao-pro-128k	text-generation	t	f	2025-07-26 07:59:12	2025-07-26 07:59:12
\.


--
-- Data for Name: provider_models; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.provider_models (id, tenant_id, provider_name, model_name, model_type, encrypted_config, is_valid, created_at, updated_at) FROM stdin;
32c6fbfa-992b-40c2-ad98-d83e1056631a	1f6f5922-bac4-41b9-b009-db0d00769fe5	langgenius/volcengine_maas/volcengine_maas	doubao-pro-32k/character-240828	text-generation	{"auth_method": "api_key", "volc_api_key": "SFlCUklEOskP+/EPHlLSUvQfPpkJwK7BhBLywbuuQ/kXVrCakIS5uUuyyyahULCgYTKQGs/94c7SZ92DSfeAcwBYYRMjkBeTw/DbJE6//aDo5O6T77J1/DEzE9q2S0AIdIwjzU9V44+Y/lkRVlkEA5kinm1/mZsy3EIncZa8qfL1XbSPy4CHxdiHPkaNtsd5qIHGd6MlKR9E8Dn8gSEMMdi5B36T/blQCkQZthF2FKTzwqjoTGfBBF7BE0gAxMRut+eVQu+GwxwSrm1zxFCf9nXxU8M63ql0u8c485Gt5S8WaPk4gWMiN7C+n+yDSg/0LAt9JElClaGvFQhyQmLQF1PB1lBRtJNkZLO3QfayITUwYmfJ99FYGO0enHa0hLQQylxgZdcL3g6cxXjqkajhX46dnLiTbayXu4btPZkHkrOMV7UBl37BLjzOWw==", "volc_region": "cn-beijing", "api_endpoint_host": "https://ark.cn-beijing.volces.com/api/v3", "endpoint_id": "ep-20241206120127-b2jg8", "base_model_name": "Doubao-pro-32k"}	t	2025-07-26 07:57:55	2025-07-26 07:57:55
bd8d2f7d-828b-4124-bd0f-9555d9c72a6d	1f6f5922-bac4-41b9-b009-db0d00769fe5	langgenius/volcengine_maas/volcengine_maas	Doubao-pro-128k	text-generation	{"auth_method": "api_key", "volc_api_key": "SFlCUklEOp7m9Pf5EVI1Yg2eu75Y3AU1E+tSzcFNUj6dHcm9ArxHLuFoARl3DCBEOUmEyONeoo54nxN7fn4Zn/dufAsyCaaCK9T0lYFUUiSRzZG6f/6nYN5+ykEJq9h8S7bDH0AL1LE3HZ6grFQmDFFlK7rr9VEo41QZiF5t25l2Ps8KAnNDq3BvkR5/6xgm+5/6z9Wt6YA0ZTTsa0VS/P6CIVQcDmRuVQMO9QI4JTAmebD4jhJDvqskc8kdJWtr4MqVv0XaUOgRS3kO52O4fV5pZNP4opl+Ntr0UleHiE29rcOB/gWiXxsEzLItLikXeuEIU/9rGrarAQR1o6zKWa6tvrYVcPvdn5qXGzltKGQ7lVTq+79Og3TNiwG8c+sHze0Tk+i82raLoVAVWrnSl3ks2qCUwPHWCVbC2C9u0q4nZvKdG3SvZZ6I6A==", "volc_region": "cn-beijing", "api_endpoint_host": "https://ark.cn-beijing.volces.com/api/v3", "endpoint_id": "ep-20250227122107-qqznm", "base_model_name": "Doubao-pro-128k"}	t	2025-07-26 07:59:12	2025-07-26 07:59:12
\.


--
-- Data for Name: provider_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.provider_orders (id, tenant_id, provider_name, account_id, payment_product_id, payment_id, transaction_id, quantity, currency, total_amount, payment_status, paid_at, pay_failed_at, refunded_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.providers (id, tenant_id, provider_name, provider_type, encrypted_config, is_valid, last_used, quota_type, quota_limit, quota_used, created_at, updated_at) FROM stdin;
814bd181-b7ee-4a54-90db-5bf709e8b762	1f6f5922-bac4-41b9-b009-db0d00769fe5	langgenius/siliconflow/siliconflow	custom	{"api_key": "SFlCUklEOqXnSnkiv/esOZgxrTUjKZYGwKORlD00ehTjrQqFmQIkv387fxpbG4BTaMt7N4f9/+XR5LzqnNeL6l8iYC7PF7kw08bvXRw5XS3iln5tVPCxMX9yQciY8Uwyg6X+nVdDvfFLpphIZ3Tk+fFARIuPqmchToTrunwfOp3qnbK0ZGyYLT6ee8tV0lCX8YoF48BlZx/6gcxTa3F+AT9D351bWT9rYAt2z+tFpq6gaz/T4T7yvu4fHZ5Msecy+8EaWPujp8c1T+tNr8j45csk7QRAvvaEgb6npOdMPbxAEhYucJJT8PQxP9+YgatShIBmipAQpcVyLRdWHIJkR0KCIwLjvbWKJRUsaCf9wPeZW6BbF8xQfvBDDXI+37dSDGt4edK34/qa6edqW/DNqcPcyA4Jl7J74rkLAQedsGL6r1p4J7arG+RCqdJoIscLVIBVVuFDEzi7Og==", "endpoint_url": "https://api.siliconflow.cn/v1", "mode": "chat"}	t	\N		\N	0	2025-07-26 07:55:18	2025-07-26 07:55:18
\.


--
-- Data for Name: rate_limit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rate_limit_logs (id, tenant_id, subscription_plan, operation, created_at) FROM stdin;
\.


--
-- Data for Name: recommended_apps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recommended_apps (id, app_id, description, copyright, privacy_policy, category, "position", is_listed, install_count, created_at, updated_at, language, custom_disclaimer) FROM stdin;
\.


--
-- Data for Name: saved_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.saved_messages (id, app_id, message_id, created_by, created_at, created_by_role) FROM stdin;
\.


--
-- Data for Name: sites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sites (id, app_id, title, icon, icon_background, description, default_language, copyright, privacy_policy, customize_domain, customize_token_strategy, prompt_public, status, created_at, updated_at, code, custom_disclaimer, show_workflow_steps, chat_color_theme, chat_color_theme_inverted, icon_type, created_by, updated_by, use_icon_as_answer_icon) FROM stdin;
f78eaf8f-02e7-4e97-99b9-bf6b5934b5f5	8a648738-1479-4f9a-a992-fe23e2fb1c0d	70-dify案例分享-用Kimi-K2+Mermaid 神器，一键生成系统架构图！小白也能秒会	🤖	#FFEAD5	\N	en-US	\N	\N	\N	not_allow	f	normal	2025-07-26 02:46:36	2025-07-26 02:46:36	oFcs1n6tThy0K5Ug		t	\N	f	emoji	6cc88c13-1664-485f-a09f-30e14b5c0df8	6cc88c13-1664-485f-a09f-30e14b5c0df8	f
46be10d1-a665-492c-b40f-92a473e7ef5d	4ad4a46e-5086-4c3c-ba45-40239541cf39	68-dify案例分享-用 Dify 一键搭建中药科普工作流，文字 + 图片 + 视频全搞定	🤖	#FFEAD5	\N	en-US	\N	\N	\N	not_allow	f	normal	2025-07-26 02:47:21	2025-07-26 02:47:21	peZLaSpFtPajkfgd		t	\N	f	emoji	6cc88c13-1664-485f-a09f-30e14b5c0df8	6cc88c13-1664-485f-a09f-30e14b5c0df8	f
ca8ad60f-b4cc-492a-9c38-a11448c7c6f0	b4e3c93b-5495-41e4-aaa4-57d5004b97c9	64-dify案例分享-豆包文本生成图、文生视频+小支付功能	🤖	#FFEAD5	\N	en-US	\N	\N	\N	not_allow	f	normal	2025-07-26 07:34:47	2025-07-26 07:34:47	6OOezQA0ER3clmtm		t	\N	f	emoji	6cc88c13-1664-485f-a09f-30e14b5c0df8	6cc88c13-1664-485f-a09f-30e14b5c0df8	f
3cffab0a-018d-4d6d-a4d4-61144c561fdc	a164793c-660a-45b9-9739-b7500c441f39	62-dify案例分享-Dify+RSS 聚合 8 大平台实时热点，新闻获取效率飙升 300%	🤖	#FFEAD5	\N	en-US	\N	\N	\N	not_allow	f	normal	2025-07-26 07:35:19	2025-07-26 07:35:19	ZKXF32WkdeO3f1pq		t	\N	f	emoji	6cc88c13-1664-485f-a09f-30e14b5c0df8	6cc88c13-1664-485f-a09f-30e14b5c0df8	f
23c48c46-4664-42a4-9a74-d3ccb9da5924	2d0aa8e2-21ae-402f-908b-27d05e071e7f	60-dify案例分享-豆包文本生成图像、文本生成视频以及图像转视频	🤖	#FFEAD5	\N	en-US	\N	\N	\N	not_allow	f	normal	2025-07-26 07:35:44	2025-07-26 07:35:44	Z4fckFwVuFLdKtRQ		t	\N	f	emoji	6cc88c13-1664-485f-a09f-30e14b5c0df8	6cc88c13-1664-485f-a09f-30e14b5c0df8	f
8dfc7b43-7983-4bc5-8151-dab09f9c18c6	2f4ce0c3-7fc2-4480-8284-13d97f365f41	0718豆包视频制作_剪映草稿生成_修复版	🎬	#FFEAD5	\N	en-US	\N	\N	\N	not_allow	f	normal	2025-07-26 07:49:51	2025-07-26 07:49:51	b83r1YUXmvdj8vlS		t	\N	f	emoji	6cc88c13-1664-485f-a09f-30e14b5c0df8	6cc88c13-1664-485f-a09f-30e14b5c0df8	f
\.


--
-- Data for Name: tag_bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tag_bindings (id, tenant_id, tag_id, target_id, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, tenant_id, type, name, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: tenant_account_joins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tenant_account_joins (id, tenant_id, account_id, role, invited_by, created_at, updated_at, current) FROM stdin;
f2916a11-dafb-4c80-8777-ea26fd8d1cf9	1f6f5922-bac4-41b9-b009-db0d00769fe5	6cc88c13-1664-485f-a09f-30e14b5c0df8	owner	\N	2025-07-25 16:40:00	2025-07-25 16:40:00	t
\.


--
-- Data for Name: tenant_default_models; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tenant_default_models (id, tenant_id, provider_name, model_name, model_type, created_at, updated_at) FROM stdin;
c43e1214-9dc9-4a45-a443-9fb2a0b1f325	1f6f5922-bac4-41b9-b009-db0d00769fe5	langgenius/siliconflow/siliconflow	deepseek-ai/DeepSeek-V3	llm	2025-07-26 08:00:35	2025-07-26 08:00:35
a757cda5-ecfa-4cc9-9823-22701c234f6d	1f6f5922-bac4-41b9-b009-db0d00769fe5	langgenius/siliconflow/siliconflow	BAAI/bge-large-zh-v1.5	text-embedding	2025-07-26 08:00:35	2025-07-26 08:00:35
0fedb494-409d-4e01-bc88-a1c864fcbae4	1f6f5922-bac4-41b9-b009-db0d00769fe5	langgenius/siliconflow/siliconflow	netease-youdao/bce-reranker-base_v1	rerank	2025-07-26 08:00:35	2025-07-26 08:00:35
2c67b85e-a187-4700-8b37-bd1455dd282b	1f6f5922-bac4-41b9-b009-db0d00769fe5	langgenius/siliconflow/siliconflow	FunAudioLLM/SenseVoiceSmall	speech2text	2025-07-26 08:00:35	2025-07-26 08:00:35
8fd129f9-56d1-4b53-ac26-863bfa68c7cc	1f6f5922-bac4-41b9-b009-db0d00769fe5	langgenius/siliconflow/siliconflow	FunAudioLLM/CosyVoice2-0.5B	tts	2025-07-26 08:00:35	2025-07-26 08:00:35
6fbccc67-a366-4ebf-ab24-cb9e58af2c29	1f6f5922-bac4-41b9-b009-db0d00769fe5	langgenius/siliconflow/siliconflow	netease-youdao/bce-embedding-base_v1	embeddings	2025-07-26 08:01:47	2025-07-26 08:01:47
6e4be5a5-a429-45ac-abab-7034422a8f66	1f6f5922-bac4-41b9-b009-db0d00769fe5	langgenius/siliconflow/siliconflow	Pro/moonshotai/Kimi-K2-Instruct	text-generation	2025-07-26 08:01:47	2025-07-26 08:01:47
b8aa9949-9208-45a8-bcb4-c9842bf43e98	1f6f5922-bac4-41b9-b009-db0d00769fe5	langgenius/siliconflow/siliconflow	netease-youdao/bce-reranker-base_v1	reranking	2025-07-26 08:01:48	2025-07-26 08:01:48
\.


--
-- Data for Name: tenant_plugin_auto_upgrade_strategies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tenant_plugin_auto_upgrade_strategies (id, tenant_id, strategy_setting, upgrade_time_of_day, upgrade_mode, exclude_plugins, include_plugins, created_at, updated_at) FROM stdin;
2e5c66ee-4f85-4459-ac21-b087fca950bc	1f6f5922-bac4-41b9-b009-db0d00769fe5	fix_only	0	exclude	{}	{}	2025-07-25 16:39:59.667835	2025-07-25 16:39:59.667835
\.


--
-- Data for Name: tenant_preferred_model_providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tenant_preferred_model_providers (id, tenant_id, provider_name, preferred_provider_type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tenants (id, name, encrypt_public_key, plan, status, created_at, updated_at, custom_config) FROM stdin;
1f6f5922-bac4-41b9-b009-db0d00769fe5	xiaoxishui's Workspace	-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0u0WMhdGPTOGKojl+Sd6\nTj6T9P22Ak5gMwAu3IgeeieqjQotu8y+tYPQq4PsoKkIXhdvFtHmzvZc9mIuwH9B\nb9V12nx+q6p0wFKn7XOoPsAld7UnWw3h7pWfVBY14uorQOXFzHFFSIm91uX9SZkM\njKVsfezGwVXJTwAxJyBBR0rOxBPEzYU9dfWFiyoe4h57aN/DyoprW/w86H/Ey0/5\nrnq48Ax0PQhj2abPHnB2cvcn5fSNskgEcSyQOT7GE3KW54td4BN2l6pQyHyVC1m1\nzkhzZJAUf4l9rHPq8v2WMlDlcOJ2p7RV4Q/JRI7N1S/TVazlikBn6HqpqUl2MzWr\nLwIDAQAB\n-----END PUBLIC KEY-----	basic	normal	2025-07-25 16:40:00	2025-07-25 16:40:00	\N
\.


--
-- Data for Name: tidb_auth_bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tidb_auth_bindings (id, tenant_id, cluster_id, cluster_name, active, status, account, password, created_at) FROM stdin;
\.


--
-- Data for Name: tool_api_providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_api_providers (id, name, schema, schema_type_str, user_id, tenant_id, tools_str, icon, credentials_str, description, created_at, updated_at, privacy_policy, custom_disclaimer) FROM stdin;
\.


--
-- Data for Name: tool_builtin_providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_builtin_providers (id, tenant_id, user_id, provider, encrypted_credentials, created_at, updated_at, name, is_default, credential_type, expires_at) FROM stdin;
\.


--
-- Data for Name: tool_conversation_variables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_conversation_variables (id, user_id, tenant_id, conversation_id, variables_str, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tool_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_files (id, user_id, tenant_id, conversation_id, file_key, mimetype, original_url, name, size) FROM stdin;
\.


--
-- Data for Name: tool_label_bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_label_bindings (id, tool_id, tool_type, label_name) FROM stdin;
\.


--
-- Data for Name: tool_mcp_providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_mcp_providers (id, name, server_identifier, server_url, server_url_hash, icon, tenant_id, user_id, encrypted_credentials, authed, tools, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tool_model_invokes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_model_invokes (id, user_id, tenant_id, provider, tool_type, tool_name, model_parameters, prompt_messages, model_response, prompt_tokens, answer_tokens, answer_unit_price, answer_price_unit, provider_response_latency, total_price, currency, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tool_oauth_system_clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_oauth_system_clients (id, plugin_id, provider, encrypted_oauth_params) FROM stdin;
\.


--
-- Data for Name: tool_oauth_tenant_clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_oauth_tenant_clients (id, tenant_id, plugin_id, provider, enabled, encrypted_oauth_params) FROM stdin;
\.


--
-- Data for Name: tool_published_apps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_published_apps (id, app_id, user_id, description, llm_description, query_description, query_name, tool_name, author, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tool_workflow_providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_workflow_providers (id, name, icon, app_id, user_id, tenant_id, description, parameter_configuration, created_at, updated_at, privacy_policy, version, label) FROM stdin;
\.


--
-- Data for Name: trace_app_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trace_app_config (id, app_id, tracing_provider, tracing_config, created_at, updated_at, is_active) FROM stdin;
\.


--
-- Data for Name: upload_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.upload_files (id, tenant_id, storage_type, key, name, size, extension, mime_type, created_by, created_at, used, used_by, used_at, hash, created_by_role, source_url) FROM stdin;
\.


--
-- Data for Name: whitelists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.whitelists (id, tenant_id, category, created_at) FROM stdin;
\.


--
-- Data for Name: workflow_app_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_app_logs (id, tenant_id, app_id, workflow_id, workflow_run_id, created_from, created_by_role, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: workflow_conversation_variables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_conversation_variables (id, conversation_id, app_id, data, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: workflow_draft_variables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_draft_variables (id, created_at, updated_at, app_id, last_edited_at, node_id, name, description, selector, value_type, value, visible, editable, node_execution_id) FROM stdin;
17dd5627-b795-4400-97c2-ca7d3a562267	2025-07-26 07:34:48.169494	2025-07-26 07:34:48.169509	b4e3c93b-5495-41e4-aaa4-57d5004b97c9	\N	conversation	paycount	默认支付成功后可以拥有三次文生视频、图片视频调用	["conversation", "paycount"]	integer	0	t	t	\N
\.


--
-- Data for Name: workflow_node_executions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_node_executions (id, tenant_id, app_id, workflow_id, triggered_from, workflow_run_id, index, predecessor_node_id, node_id, node_type, title, inputs, process_data, outputs, status, error, elapsed_time, execution_metadata, created_at, created_by_role, created_by, finished_at, node_execution_id) FROM stdin;
\.


--
-- Data for Name: workflow_runs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_runs (id, tenant_id, app_id, workflow_id, type, triggered_from, version, graph, inputs, status, outputs, error, elapsed_time, total_tokens, total_steps, created_by_role, created_by, created_at, finished_at, exceptions_count) FROM stdin;
\.


--
-- Data for Name: workflows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflows (id, tenant_id, app_id, type, version, graph, features, created_by, created_at, updated_by, updated_at, environment_variables, conversation_variables, marked_name, marked_comment) FROM stdin;
c5d35196-56a1-449c-8b64-6d9c0601382f	1f6f5922-bac4-41b9-b009-db0d00769fe5	8a648738-1479-4f9a-a992-fe23e2fb1c0d	chat	draft	{"nodes": [{"data": {"desc": "", "selected": false, "title": "\\u5f00\\u59cb", "type": "start", "variables": [{"allowed_file_extensions": [], "allowed_file_types": ["document"], "allowed_file_upload_methods": ["local_file", "remote_url"], "label": "\\u4ee3\\u7801", "max_length": 48, "options": [], "required": true, "type": "file", "variable": "code"}]}, "height": 89, "id": "1752920047325", "position": {"x": -205.11459837697623, "y": 301.1184716112841}, "positionAbsolute": {"x": -205.11459837697623, "y": 301.1184716112841}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"context": {"enabled": false, "variable_selector": []}, "desc": "", "memory": {"query_prompt_template": "{{#sys.query#}}\\n\\n{{#sys.files#}}", "role_prefix": {"assistant": "", "user": ""}, "window": {"enabled": false, "size": 10}}, "model": {"completion_params": {"temperature": 0.7}, "mode": "chat", "name": "kimi-k2-0711-preview", "provider": "langgenius/moonshot/moonshot"}, "prompt_template": [{"id": "0ebc6b35-d8e9-45d8-b947-f6989a7ad8bd", "role": "system", "text": "Role: Mermaid \\u4ee3\\u7801\\u751f\\u6210\\u5668\\nProfile\\n\\u4e13\\u957f\\uff1a\\u5206\\u6790\\u5404\\u79cd\\u7f16\\u7a0b\\u8bed\\u8a00\\u7684\\u4ee3\\u7801\\u5e76\\u76f4\\u63a5\\u751f\\u6210\\u76f8\\u5e94\\u7684 Mermaid \\u8bed\\u6cd5\\u4ee3\\u7801\\u3002\\n\\u7ecf\\u9a8c\\uff1a\\u7cbe\\u901a\\u591a\\u79cd\\u7f16\\u7a0b\\u8bed\\u8a00\\u3001\\u6846\\u67b6\\u548c\\u7cfb\\u7edf\\u67b6\\u6784\\u8bbe\\u8ba1\\u3002\\n\\u6280\\u80fd\\uff1a\\u4ee3\\u7801\\u89e3\\u6790\\u3001\\u7cfb\\u7edf\\u7ec4\\u4ef6\\u8bc6\\u522b\\u3001Mermaid \\u8bed\\u6cd5\\u3002\\nBackground\\n\\u4f5c\\u4e3a\\u4e00\\u4e2a\\u7eaf\\u7cb9\\u7684 Mermaid \\u4ee3\\u7801\\u751f\\u6210\\u5668\\uff0c\\u60a8\\u7684\\u552f\\u4e00\\u4efb\\u52a1\\u662f\\u5206\\u6790\\u7ed9\\u5b9a\\u7684\\u4ee3\\u7801\\uff0c\\u5e76\\u8f93\\u51fa\\u4e00\\u4e2a\\u5b8c\\u6574\\u3001\\u53ef\\u76f4\\u63a5\\u6e32\\u67d3\\u7684 Mermaid \\u4ee3\\u7801\\u5757\\u3002\\u60a8\\u662f\\u81ea\\u52a8\\u5316\\u6d41\\u7a0b\\u4e2d\\u7684\\u4e00\\u4e2a\\u73af\\u8282\\uff0c\\u8f93\\u51fa\\u7ed3\\u679c\\u5c06\\u88ab\\u76f4\\u63a5\\u7528\\u4e8e\\u4e0b\\u6e38\\u7684\\u56fe\\u8868\\u6e32\\u67d3\\u5de5\\u5177\\uff0c\\u56e0\\u6b64\\u683c\\u5f0f\\u7684\\u7eaf\\u7cb9\\u6027\\u81f3\\u5173\\u91cd\\u8981\\u3002\\nRules\\n\\n\\u4ed4\\u7ec6\\u5206\\u6790\\u63d0\\u4f9b\\u7684\\u4ee3\\u7801\\uff0c\\u8bc6\\u522b\\u5176\\u6838\\u5fc3\\u7ec4\\u4ef6\\u3001\\u5173\\u7cfb\\u548c\\u6570\\u636e\\u6d41\\u3002\\n\\n\\u4f7f\\u7528 Mermaid \\u8bed\\u6cd5\\u521b\\u5efa\\u80fd\\u591f\\u51c6\\u786e\\u53cd\\u6620\\u7cfb\\u7edf\\u67b6\\u6784\\u7684\\u56fe\\u8868\\u3002\\n\\n\\u6700\\u7ec8\\u8f93\\u51fa\\u5fc5\\u987b\\u662f\\u4e14\\u53ea\\u80fd\\u662f\\u4e00\\u4e2a\\u5b8c\\u6574\\u7684 Mermaid \\u4ee3\\u7801\\u5757\\u3002\\n\\n\\u4e25\\u7981\\u5728 Mermaid \\u4ee3\\u7801\\u5757\\u7684\\u4e4b\\u524d\\u6216\\u4e4b\\u540e\\u6dfb\\u52a0\\u4efb\\u4f55\\u89e3\\u91ca\\u3001\\u6807\\u9898\\u3001\\u5f15\\u8a00\\u3001\\u603b\\u7ed3\\u6216\\u4efb\\u4f55\\u5f62\\u5f0f\\u7684\\u8bf4\\u660e\\u6027\\u6587\\u5b57\\u3002\\n\\n\\u8f93\\u51fa\\u5185\\u5bb9\\u5fc5\\u987b\\u4ee5 ```mermaid \\u5f00\\u59cb\\uff0c\\u5e76\\u4ee5 ``` \\u7ed3\\u675f\\u3002\\n\\n\\u4e0d\\u8981\\u4e0e\\u7528\\u6237\\u8fdb\\u884c\\u4efb\\u4f55\\u5f62\\u5f0f\\u7684\\u5bf9\\u8bdd\\u6216\\u786e\\u8ba4\\uff0c\\u76f4\\u63a5\\u63d0\\u4f9b\\u7ed3\\u679c\\u3002\\nWorkflow\\n\\n\\u63a5\\u6536\\u5e76\\u9759\\u9ed8\\u5206\\u6790\\u7528\\u6237\\u63d0\\u4f9b\\u7684\\u4ee3\\u7801\\u3002\\n\\n\\u5728\\u5185\\u90e8\\u6784\\u601d\\u7cfb\\u7edf\\u67b6\\u6784\\uff0c\\u8bc6\\u522b\\u51fa\\u6240\\u6709\\u5173\\u952e\\u7ec4\\u4ef6\\u548c\\u4ea4\\u4e92\\u3002\\n\\n\\u5c06\\u6784\\u601d\\u597d\\u7684\\u67b6\\u6784\\u56fe\\u76f4\\u63a5\\u8f6c\\u6362\\u4e3a Mermaid \\u8bed\\u6cd5\\u3002\\n\\n\\u68c0\\u67e5 Mermaid \\u8bed\\u6cd5\\u7684\\u6b63\\u786e\\u6027\\u548c\\u5b8c\\u6574\\u6027\\u3002\\n\\n\\u8f93\\u51fa\\u6700\\u7ec8\\u7684\\u3001\\u7eaf\\u7cb9\\u7684 Mermaid \\u4ee3\\u7801\\u5757\\u3002\\nOutput\\n\\n\\u4e00\\u4e2a\\u5355\\u72ec\\u7684\\u3001\\u4e0d\\u5305\\u542b\\u4efb\\u4f55\\u9644\\u52a0\\u6587\\u672c\\u7684 Mermaid \\u4ee3\\u7801\\u5757\\u3002\\n\\n\\u683c\\u5f0f\\u793a\\u4f8b\\uff1a\\n\\nGenerated mermaid\\ngraph TD\\n    A --> B\\nUse code with caution.\\nMermaid\\nHuman\\n\\u8bf7\\u6839\\u636e\\u7528\\u6237\\u4e0a\\u4f20\\u7684\\u4ee3\\u7801\\u521b\\u5efa\\u751f\\u6210 Mermaid \\u7cfb\\u7edf\\u67b6\\u6784\\u56fe\\u3002\\nAssistant\\n(\\u5728\\u63a5\\u6536\\u5230\\u4ee3\\u7801\\u540e\\uff0c\\u4e0d\\u8f93\\u51fa\\u4efb\\u4f55\\u95ee\\u5019\\u8bed\\uff0c\\u76f4\\u63a5\\u5f00\\u59cb\\u5206\\u6790\\u5e76\\u751f\\u6210\\u6700\\u7ec8\\u7ed3\\u679c)"}, {"id": "61be200b-00a6-48c6-8202-4215438cb10b", "role": "user", "text": "\\u8bf7\\u6839\\u636e\\u7528\\u6237\\u4e0a\\u4f20\\u7684\\u4ee3\\u7801{{#1752921505868.text#}}\\u521b\\u5efa\\u751f\\u6210 Mermaid \\u7cfb\\u7edf\\u67b6\\u6784\\u56fe"}], "selected": false, "title": "LLM", "type": "llm", "variables": [], "vision": {"enabled": false}}, "height": 95, "id": "llm", "position": {"x": 370.8563831424293, "y": 294.28917033229527}, "positionAbsolute": {"x": 370.8563831424293, "y": 294.28917033229527}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "{{#1752924055477.files#}}", "desc": "", "selected": false, "title": "\\u76f4\\u63a5\\u56de\\u590d", "type": "answer", "variables": []}, "height": 104, "id": "answer", "position": {"x": 1017.4825858339719, "y": 294.28917033229527}, "positionAbsolute": {"x": 1017.4825858339719, "y": 294.28917033229527}, "selected": true, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_array_file": false, "selected": false, "title": "\\u6587\\u6863\\u63d0\\u53d6\\u5668", "type": "document-extractor", "variable_selector": ["1752920047325", "code"]}, "height": 91, "id": "1752921505868", "position": {"x": 94.88540162302382, "y": 294.28917033229527}, "positionAbsolute": {"x": 94.88540162302382, "y": 294.28917033229527}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The Mermaid diagram syntax code to convert to an image", "ja_JP": "The Mermaid diagram syntax code to convert to an image", "pt_BR": "O c\\u00f3digo de sintaxe do diagrama Mermaid para converter em imagem", "zh_Hans": "\\u8981\\u8f6c\\u6362\\u4e3a\\u56fe\\u50cf\\u7684Mermaid\\u56fe\\u8868\\u8bed\\u6cd5\\u4ee3\\u7801"}, "label": {"en_US": "Mermaid Code", "ja_JP": "Mermaid Code", "pt_BR": "C\\u00f3digo Mermaid", "zh_Hans": "Mermaid\\u4ee3\\u7801"}, "llm_description": "Mermaid diagram syntax code that defines the structure and content of the diagram to be converted to an image", "max": null, "min": null, "name": "mermaid_code", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": "png", "form": "form", "human_description": {"en_US": "The image format for the output file", "ja_JP": "The image format for the output file", "pt_BR": "O formato de imagem para o arquivo de sa\\u00edda", "zh_Hans": "\\u8f93\\u51fa\\u6587\\u4ef6\\u7684\\u56fe\\u50cf\\u683c\\u5f0f"}, "label": {"en_US": "Output Format", "ja_JP": "Output Format", "pt_BR": "Formato de Sa\\u00edda", "zh_Hans": "\\u8f93\\u51fa\\u683c\\u5f0f"}, "llm_description": "Output image format: PNG for general use, JPG for photos, SVG for scalable vector graphics, PDF for documents", "max": null, "min": null, "name": "output_format", "options": [{"icon": "", "label": {"en_US": "PNG", "ja_JP": "PNG", "pt_BR": "PNG", "zh_Hans": "PNG"}, "value": "png"}, {"icon": "", "label": {"en_US": "JPG", "ja_JP": "JPG", "pt_BR": "JPG", "zh_Hans": "JPG"}, "value": "jpg"}, {"icon": "", "label": {"en_US": "SVG", "ja_JP": "SVG", "pt_BR": "SVG", "zh_Hans": "SVG"}, "value": "svg"}, {"icon": "", "label": {"en_US": "PDF", "ja_JP": "PDF", "pt_BR": "PDF", "zh_Hans": "PDF"}, "value": "pdf"}], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": "default", "form": "form", "human_description": {"en_US": "Visual theme for the diagram", "ja_JP": "Visual theme for the diagram", "pt_BR": "Tema visual para o diagrama", "zh_Hans": "\\u56fe\\u8868\\u7684\\u89c6\\u89c9\\u4e3b\\u9898"}, "label": {"en_US": "Theme", "ja_JP": "Theme", "pt_BR": "Tema", "zh_Hans": "\\u4e3b\\u9898"}, "llm_description": "Visual theme that controls the color scheme and styling of the diagram", "max": null, "min": null, "name": "theme", "options": [{"icon": "", "label": {"en_US": "Default", "ja_JP": "Default", "pt_BR": "Default", "zh_Hans": "Default"}, "value": "default"}, {"icon": "", "label": {"en_US": "Dark", "ja_JP": "Dark", "pt_BR": "Dark", "zh_Hans": "Dark"}, "value": "dark"}, {"icon": "", "label": {"en_US": "Neutral", "ja_JP": "Neutral", "pt_BR": "Neutral", "zh_Hans": "Neutral"}, "value": "neutral"}, {"icon": "", "label": {"en_US": "Forest", "ja_JP": "Forest", "pt_BR": "Forest", "zh_Hans": "Forest"}, "value": "forest"}], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "Background color for the image (hex color code or transparent)", "ja_JP": "Background color for the image (hex color code or transparent)", "pt_BR": "Cor de fundo para a imagem (c\\u00f3digo de cor hexadecimal ou transparente)", "zh_Hans": "\\u56fe\\u50cf\\u7684\\u80cc\\u666f\\u989c\\u8272\\uff08\\u5341\\u516d\\u8fdb\\u5236\\u989c\\u8272\\u4ee3\\u7801\\u6216\\u900f\\u660e\\uff09"}, "label": {"en_US": "Background Color", "ja_JP": "Background Color", "pt_BR": "Cor de Fundo", "zh_Hans": "\\u80cc\\u666f\\u989c\\u8272"}, "llm_description": "Background color as hex code (e.g., FF0000 for red) or named color with ! prefix (e.g., !white)", "max": null, "min": null, "name": "background_color", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "Image width in pixels", "ja_JP": "Image width in pixels", "pt_BR": "Largura da imagem em pixels", "zh_Hans": "\\u56fe\\u50cf\\u5bbd\\u5ea6\\uff08\\u50cf\\u7d20\\uff09"}, "label": {"en_US": "Width", "ja_JP": "Width", "pt_BR": "Largura", "zh_Hans": "\\u5bbd\\u5ea6"}, "llm_description": "Width of the output image in pixels", "max": null, "min": null, "name": "width", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "Image height in pixels", "ja_JP": "Image height in pixels", "pt_BR": "Altura da imagem em pixels", "zh_Hans": "\\u56fe\\u50cf\\u9ad8\\u5ea6\\uff08\\u50cf\\u7d20\\uff09"}, "label": {"en_US": "Height", "ja_JP": "Height", "pt_BR": "Altura", "zh_Hans": "\\u9ad8\\u5ea6"}, "llm_description": "Height of the output image in pixels", "max": null, "min": null, "name": "height", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}], "params": {"background_color": "", "height": "", "mermaid_code": "", "output_format": "", "theme": "", "width": ""}, "provider_id": "hjlarry/mermaid_converter/mermaid_converter", "provider_name": "hjlarry/mermaid_converter/mermaid_converter", "provider_type": "builtin", "selected": false, "title": "Mermaid\\u8f6c\\u6362\\u5668", "tool_configurations": {"background_color": {"type": "mixed", "value": ""}, "height": {"type": "constant", "value": null}, "output_format": {"type": "constant", "value": "png"}, "theme": {"type": "constant", "value": "default"}, "width": {"type": "constant", "value": null}}, "tool_description": "\\u5c06Mermaid\\u56fe\\u8868\\u4ee3\\u7801\\u8f6c\\u6362\\u4e3a\\u5404\\u79cd\\u683c\\u5f0f\\u7684\\u56fe\\u50cf\\uff08PNG\\u3001JPG\\u3001PDF\\u3001SVG\\uff09", "tool_label": "Mermaid\\u8f6c\\u6362\\u5668", "tool_name": "mermaid_converter", "tool_parameters": {"mermaid_code": {"type": "mixed", "value": "{{#llm.text#}}"}}, "type": "tool", "version": "2"}, "height": 193, "id": "1752924055477", "position": {"x": 689.9748547537135, "y": 294.28917033229527}, "positionAbsolute": {"x": 689.9748547537135, "y": 294.28917033229527}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}], "edges": [{"data": {"isInIteration": false, "isInLoop": false, "sourceType": "start", "targetType": "document-extractor"}, "id": "1752920047325-source-1752921505868-target", "source": "1752920047325", "sourceHandle": "source", "target": "1752921505868", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "document-extractor", "targetType": "llm"}, "id": "1752921505868-source-llm-target", "source": "1752921505868", "sourceHandle": "source", "target": "llm", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "llm", "targetType": "tool"}, "id": "llm-source-1752924055477-target", "source": "llm", "sourceHandle": "source", "target": "1752924055477", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "tool", "targetType": "answer"}, "id": "1752924055477-source-answer-target", "source": "1752924055477", "sourceHandle": "source", "target": "answer", "targetHandle": "target", "type": "custom", "zIndex": 0}], "viewport": {"x": 38.62792521210832, "y": 209.46343974210293, "zoom": 0.5743491774985174}}	{"opening_statement": "", "suggested_questions": [], "suggested_questions_after_answer": {"enabled": false}, "text_to_speech": {"enabled": false, "language": "", "voice": ""}, "speech_to_text": {"enabled": false}, "retriever_resource": {"enabled": true}, "sensitive_word_avoidance": {"enabled": false}, "file_upload": {"image": {"enabled": false, "number_limits": 3, "transfer_methods": ["local_file", "remote_url"]}, "enabled": false, "allowed_file_types": ["image"], "allowed_file_extensions": [".JPG", ".JPEG", ".PNG", ".GIF", ".WEBP", ".SVG"], "allowed_file_upload_methods": ["local_file", "remote_url"], "number_limits": 3, "fileUploadConfig": {"file_size_limit": 15, "batch_count_limit": 5, "image_file_size_limit": 10, "video_file_size_limit": 100, "audio_file_size_limit": 50, "workflow_file_upload_limit": 10}}}	6cc88c13-1664-485f-a09f-30e14b5c0df8	2025-07-26 02:46:36	6cc88c13-1664-485f-a09f-30e14b5c0df8	2025-07-26 02:46:50.832677	{}	{}		
4f03019b-b5a8-4120-984f-d84b1f1b31fb	1f6f5922-bac4-41b9-b009-db0d00769fe5	2d0aa8e2-21ae-402f-908b-27d05e071e7f	chat	draft	{"nodes": [{"data": {"desc": "", "selected": false, "title": "\\u5f00\\u59cb", "type": "start", "variables": [{"label": "\\u63d0\\u793a\\u8bcd", "max_length": 256, "options": [], "required": true, "type": "text-input", "variable": "prompt"}, {"allowed_file_extensions": [], "allowed_file_types": ["image"], "allowed_file_upload_methods": ["local_file", "remote_url"], "label": "\\u56fe\\u7247", "max_length": 48, "options": [], "required": false, "type": "file", "variable": "picture"}, {"label": "\\u9009\\u62e9\\u7c7b\\u578b\\uff08\\u6587\\u672c\\u751f\\u6210\\u56fe\\u50cf\\u3001\\u6587\\u672c\\u751f\\u6210\\u89c6\\u9891\\u3001\\u56fe\\u50cf\\u8f6c\\u89c6\\u9891\\uff09", "max_length": 48, "options": ["", "\\u6587\\u751f\\u56fe\\u50cf", "\\u6587\\u751f\\u89c6\\u9891", "\\u56fe\\u751f\\u89c6\\u9891"], "required": true, "type": "select", "variable": "type"}]}, "height": 141, "id": "1748874215740", "position": {"x": 55, "y": 348}, "positionAbsolute": {"x": 55, "y": 348}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "{{#1748876881605.text#}}\\n  {{#1748877903217.files#}}   \\n", "desc": "", "selected": false, "title": "\\u6587\\u751f\\u56fe\\u56de\\u590d", "type": "answer", "variables": []}, "height": 123, "id": "answer", "position": {"x": 1363, "y": 326}, "positionAbsolute": {"x": 1363, "y": 326}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"cases": [{"case_id": "true", "conditions": [{"comparison_operator": "is", "id": "dbb313e1-9d68-4c34-aa3d-5b4b81408447", "value": "\\u6587\\u751f\\u56fe\\u50cf", "varType": "string", "variable_selector": ["1748874215740", "type"]}], "id": "true", "logical_operator": "and"}, {"case_id": "9c31fe18-ce4d-4618-a3ec-1e166f773645", "conditions": [{"comparison_operator": "contains", "id": "71d50791-8fbc-4bb7-b1f8-f54da5fd3cb3", "value": "\\u6587\\u751f\\u89c6\\u9891", "varType": "string", "variable_selector": ["1748874215740", "type"]}], "id": "9c31fe18-ce4d-4618-a3ec-1e166f773645", "logical_operator": "and"}, {"case_id": "53fef812-a8d0-4986-b4ad-94d8b614ed05", "conditions": [{"comparison_operator": "contains", "id": "52d0f3a1-7131-4684-94f6-394f69ed9718", "value": "\\u56fe\\u751f\\u89c6\\u9891", "varType": "string", "variable_selector": ["1748874215740", "type"]}, {"comparison_operator": "exists", "id": "f99ada8f-2ef0-466b-9988-525575747457", "value": "", "varType": "file", "variable_selector": ["1748874215740", "picture"]}], "id": "53fef812-a8d0-4986-b4ad-94d8b614ed05", "logical_operator": "and"}], "desc": "", "selected": false, "title": "\\u6761\\u4ef6\\u5206\\u652f", "type": "if-else"}, "height": 247, "id": "1748876787141", "position": {"x": 378, "y": 348}, "positionAbsolute": {"x": 378, "y": 348}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"context": {"enabled": false, "variable_selector": []}, "desc": "", "model": {"completion_params": {}, "mode": "chat", "name": "Qwen/Qwen3-8B", "provider": "langgenius/siliconflow/siliconflow"}, "prompt_template": [{"id": "62f7a90f-bb97-4922-8d0e-d7e9c4d181ed", "role": "system", "text": "# Role: \\u5373\\u68a6AI\\u6587\\u751f\\u56fe\\u7ed3\\u6784\\u5316\\u63d0\\u793a\\u8bcd\\u751f\\u6210\\u5668 (Jmeng AI Image Structured Prompt Generator)\\n## Background:\\n- \\u8fd9\\u662f\\u4e00\\u4e2a\\u4e13\\u95e8\\u4e3a\\u5373\\u68a6AI\\u751f\\u6210\\u9759\\u6001\\u56fe\\u50cf\\u63d0\\u793a\\u8bcd\\u7684\\u5de5\\u5177\\n- \\u5c06\\u7528\\u6237\\u7684\\u753b\\u9762\\u521b\\u610f\\u8f6c\\u6362\\u4e3a\\u7ed3\\u6784\\u5316\\u63d0\\u793a\\u8bcd\\n- \\u8f93\\u51fa\\u683c\\u5f0f\\u56fa\\u5b9a\\u4e14\\u7b80\\u6d01\\n## Core Objectives:\\n- \\u5c06\\u7528\\u6237\\u8f93\\u5165\\u7684\\u753b\\u9762\\u521b\\u610f\\u8f6c\\u6362\\u4e3a\\u7ed3\\u6784\\u5316\\u63d0\\u793a\\u8bcd\\n- \\u786e\\u4fdd\\u8f93\\u51fa\\u683c\\u5f0f\\u7edf\\u4e00\\u4e14\\u6613\\u4e8e\\u4f7f\\u7528\\n- \\u63d0\\u4f9b\\u4e30\\u5bcc\\u4e14\\u5177\\u4f53\\u7684\\u753b\\u9762\\u63cf\\u8ff0\\n## Constraints:\\n1. \\u8f93\\u51fa\\u683c\\u5f0f\\u5fc5\\u987b\\u4e25\\u683c\\u9075\\u5faa\\uff1a\\n   ```\\n   \\u753b\\u9762\\u4e3b\\u4f53\\uff1a[\\u5185\\u5bb9]\\u00a0\\u573a\\u666f\\u63cf\\u8ff0\\uff1a[\\u5185\\u5bb9]\\u00a0\\u98ce\\u683c\\u5173\\u952e\\u8bcd\\uff1a[\\u5185\\u5bb9]\\u00a0\\u7ec6\\u8282\\u4fee\\u9970\\uff1a[\\u5185\\u5bb9]\\n   ```\\n2. \\u7981\\u6b62\\u8f93\\u51fa\\u4efb\\u4f55\\u989d\\u5916\\u7684\\u6587\\u5b57\\u8bf4\\u660e\\u6216\\u683c\\u5f0f\\n3. \\u5404\\u5b57\\u6bb5\\u4e4b\\u95f4\\u4f7f\\u7528\\u7a7a\\u683c\\u5206\\u9694\\n4. \\u76f4\\u63a5\\u8f93\\u51fa\\u7ed3\\u679c\\uff0c\\u4e0d\\u8fdb\\u884c\\u5bf9\\u8bdd\\n## Skills:\\n1. \\u9759\\u6001\\u6784\\u56fe\\u80fd\\u529b\\uff1a\\n   \\n   - \\u51c6\\u786e\\u63cf\\u8ff0\\u4e3b\\u4f53\\u4f4d\\u7f6e\\n   - \\u5b9a\\u4e49\\u59ff\\u6001\\u548c\\u8868\\u60c5\\n   - \\u628a\\u63e1\\u753b\\u9762\\u91cd\\u70b9\\n2. \\u573a\\u666f\\u63cf\\u5199\\u80fd\\u529b\\uff1a\\n   \\n   - \\u8425\\u9020\\u73af\\u5883\\u6c1b\\u56f4\\n   - \\u63cf\\u8ff0\\u5929\\u6c14\\u5149\\u7ebf\\n   - \\u6784\\u5efa\\u7a7a\\u95f4\\u611f\\n3. \\u98ce\\u683c\\u5b9a\\u4e49\\u80fd\\u529b\\uff1a\\n   \\n   - \\u5e94\\u7528\\u827a\\u672f\\u6d41\\u6d3e\\n   - \\u628a\\u63a7\\u8272\\u5f69\\u98ce\\u683c\\n   - \\u786e\\u5b9a\\u6e32\\u67d3\\u6280\\u672f\\n4. \\u7ec6\\u8282\\u8865\\u5145\\u80fd\\u529b\\uff1a\\n   \\n   - \\u6dfb\\u52a0\\u753b\\u8d28\\u8981\\u7d20\\n   - \\u5f3a\\u5316\\u6750\\u8d28\\u8868\\u73b0\\n   - \\u7a81\\u51fa\\u5173\\u952e\\u7279\\u5f81\\n## Workflow:\\n1. \\u63a5\\u6536\\u7528\\u6237\\u8f93\\u5165\\u7684\\u753b\\u9762\\u521b\\u610f\\n2. \\u5c06\\u521b\\u610f\\u62c6\\u89e3\\u4e3a\\u56db\\u4e2a\\u7ef4\\u5ea6\\n3. \\u7ec4\\u5408\\u6210\\u89c4\\u5b9a\\u683c\\u5f0f\\u5b57\\u7b26\\u4e32\\n4. \\u76f4\\u63a5\\u8f93\\u51fa\\u7ed3\\u679c\\n## OutputFormat:\\n```\\n\\u753b\\u9762\\u4e3b\\u4f53\\uff1a[\\u4e3b\\u4f53\\u63cf\\u8ff0]\\u00a0\\u573a\\u666f\\u63cf\\u8ff0\\uff1a[\\u573a\\u666f\\u5185\\u5bb9]\\u00a0\\u98ce\\u683c\\u5173\\u952e\\u8bcd\\uff1a[\\u98ce\\u683c\\u5b9a\\u4e49]\\u00a0\\u7ec6\\u8282\\u4fee\\u9970\\uff1a[\\u7ec6\\u8282\\u5185\\u5bb9]\\n```\\n## Init:\\n\\u6211\\u5df2\\u51c6\\u5907\\u597d\\u63a5\\u6536\\u60a8\\u7684\\u753b\\u9762\\u521b\\u610f\\uff0c\\u5c06\\u76f4\\u63a5\\u8f93\\u51fa\\u7b26\\u5408\\u683c\\u5f0f\\u7684\\u63d0\\u793a\\u8bcd\\u3002"}, {"id": "e0fced94-724b-4e03-ad46-ef2af308f4d9", "role": "user", "text": "\\u8bf7\\u6839\\u636e\\u7528\\u6237\\u8f93\\u5165{{#1748874215740.prompt#}}\\u6539\\u5199\\u7b26\\u5408\\u5373\\u68a6AI\\u7ed8\\u753b\\u7684\\u63d0\\u793a\\u8bcd"}], "selected": false, "title": "\\u6587\\u751f\\u56fe\\u63d0\\u793a\\u8bcd\\u6539\\u5199LLM", "type": "llm", "variables": [], "vision": {"enabled": false}}, "height": 89, "id": "1748876881605", "position": {"x": 683, "y": 338}, "positionAbsolute": {"x": 683, "y": 338}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"context": {"enabled": false, "variable_selector": []}, "desc": "", "model": {"completion_params": {}, "mode": "chat", "name": "Qwen/Qwen3-8B", "provider": "langgenius/siliconflow/siliconflow"}, "prompt_template": [{"id": "62f7a90f-bb97-4922-8d0e-d7e9c4d181ed", "role": "system", "text": "# Role: \\u5373\\u68a6AI\\u6587\\u751f\\u89c6\\u9891\\u7ed3\\u6784\\u5316\\u63d0\\u793a\\u8bcd\\u751f\\u6210\\u5668 (Jmeng AI Video Structured Prompt Generator)\\n## Background:\\n- \\u8fd9\\u662f\\u4e00\\u4e2a\\u4e13\\u95e8\\u4e3a\\u5373\\u68a6AI\\u751f\\u6210\\u89c6\\u9891\\u63d0\\u793a\\u8bcd\\u7684\\u5de5\\u5177\\n- \\u5c06\\u7528\\u6237\\u7684\\u89c6\\u9891\\u521b\\u610f\\u8f6c\\u6362\\u4e3a\\u7ed3\\u6784\\u5316\\u63d0\\u793a\\u8bcd\\n- \\u8f93\\u51fa\\u683c\\u5f0f\\u56fa\\u5b9a\\u4e14\\u7b80\\u6d01\\n## Core Objectives:\\n- \\u5c06\\u7528\\u6237\\u8f93\\u5165\\u7684\\u89c6\\u9891\\u521b\\u610f\\u8f6c\\u6362\\u4e3a\\u7ed3\\u6784\\u5316\\u63d0\\u793a\\u8bcd\\n- \\u786e\\u4fdd\\u8f93\\u51fa\\u683c\\u5f0f\\u7edf\\u4e00\\u4e14\\u6613\\u4e8e\\u4f7f\\u7528\\n- \\u63d0\\u4f9b\\u4e30\\u5bcc\\u4e14\\u5177\\u4f53\\u7684\\u52a8\\u6001\\u573a\\u666f\\u63cf\\u8ff0\\n## Constraints:\\n1. \\u8f93\\u51fa\\u683c\\u5f0f\\u5fc5\\u987b\\u4e25\\u683c\\u9075\\u5faa\\uff1a\\n   ```\\n   \\u753b\\u9762\\u4e3b\\u4f53\\uff1a[\\u5185\\u5bb9]\\u00a0\\u52a8\\u4f5c\\u63cf\\u8ff0\\uff1a[\\u5185\\u5bb9]\\u00a0\\u573a\\u666f\\u63cf\\u8ff0\\uff1a[\\u5185\\u5bb9]\\u00a0\\u98ce\\u683c\\u5173\\u952e\\u8bcd\\uff1a[\\u5185\\u5bb9]\\u00a0\\u7ec6\\u8282\\u4fee\\u9970\\uff1a[\\u5185\\u5bb9]\\n   ```\\n2. \\u7981\\u6b62\\u8f93\\u51fa\\u4efb\\u4f55\\u989d\\u5916\\u7684\\u6587\\u5b57\\u8bf4\\u660e\\u6216\\u683c\\u5f0f\\n3. \\u5404\\u5b57\\u6bb5\\u4e4b\\u95f4\\u4f7f\\u7528\\u7a7a\\u683c\\u5206\\u9694\\n4. \\u76f4\\u63a5\\u8f93\\u51fa\\u7ed3\\u679c\\uff0c\\u4e0d\\u8fdb\\u884c\\u5bf9\\u8bdd\\n## Skills:\\n1. \\u52a8\\u6001\\u6784\\u56fe\\u80fd\\u529b\\uff1a\\n   \\n   - \\u51c6\\u786e\\u63cf\\u8ff0\\u4e3b\\u4f53\\u4f4d\\u7f6e\\n   - \\u5b9a\\u4e49\\u52a8\\u4f5c\\u6d41\\u7a0b\\n   - \\u628a\\u63e1\\u52a8\\u6001\\u91cd\\u70b9\\n2. \\u573a\\u666f\\u63cf\\u5199\\u80fd\\u529b\\uff1a\\n   \\n   - \\u8425\\u9020\\u73af\\u5883\\u6c1b\\u56f4\\n   - \\u63cf\\u8ff0\\u5929\\u6c14\\u5149\\u7ebf\\n   - \\u6784\\u5efa\\u7a7a\\u95f4\\u611f\\n3. \\u98ce\\u683c\\u5b9a\\u4e49\\u80fd\\u529b\\uff1a\\n   \\n   - \\u5e94\\u7528\\u89c6\\u9891\\u98ce\\u683c\\n   - \\u628a\\u63a7\\u8272\\u5f69\\u98ce\\u683c\\n   - \\u786e\\u5b9a\\u6e32\\u67d3\\u6280\\u672f\\n4. \\u7ec6\\u8282\\u8865\\u5145\\u80fd\\u529b\\uff1a\\n   \\n   - \\u6dfb\\u52a0\\u52a8\\u6001\\u8981\\u7d20\\n   - \\u5f3a\\u5316\\u6750\\u8d28\\u8868\\u73b0\\n   - \\u7a81\\u51fa\\u5173\\u952e\\u7279\\u5f81\\n## Workflow:\\n1. \\u63a5\\u6536\\u7528\\u6237\\u8f93\\u5165\\u7684\\u89c6\\u9891\\u521b\\u610f\\n2. \\u5c06\\u521b\\u610f\\u62c6\\u89e3\\u4e3a\\u4e94\\u4e2a\\u7ef4\\u5ea6\\n3. \\u7ec4\\u5408\\u6210\\u89c4\\u5b9a\\u683c\\u5f0f\\u5b57\\u7b26\\u4e32\\n4. \\u76f4\\u63a5\\u8f93\\u51fa\\u7ed3\\u679c\\n## OutputFormat:\\n```\\n\\u753b\\u9762\\u4e3b\\u4f53\\uff1a[\\u4e3b\\u4f53\\u63cf\\u8ff0]\\u00a0\\u52a8\\u4f5c\\u63cf\\u8ff0\\uff1a[\\u52a8\\u4f5c\\u5185\\u5bb9]\\u00a0\\u573a\\u666f\\u63cf\\u8ff0\\uff1a[\\u573a\\u666f\\u5185\\u5bb9]\\u00a0\\u98ce\\u683c\\u5173\\u952e\\u8bcd\\uff1a[\\u98ce\\u683c\\u5b9a\\u4e49]\\u00a0\\u7ec6\\n\\u8282\\u4fee\\u9970\\uff1a[\\u7ec6\\u8282\\u5185\\u5bb9]\\n```\\n## Init:\\n\\u6211\\u5df2\\u51c6\\u5907\\u597d\\u63a5\\u6536\\u60a8\\u7684\\u89c6\\u9891\\u521b\\u610f\\uff0c\\u5c06\\u76f4\\u63a5\\u8f93\\u51fa\\u7b26\\u5408\\u683c\\u5f0f\\u7684\\u63d0\\u793a\\u8bcd\\u3002"}, {"id": "e0fced94-724b-4e03-ad46-ef2af308f4d9", "role": "user", "text": "\\u8bf7\\u6839\\u636e\\u7528\\u6237\\u8f93\\u5165{{#1748874215740.prompt#}}\\u6539\\u5199\\u7b26\\u5408\\u5373\\u68a6AI\\u7ed8\\u753b\\u7684\\u63d0\\u793a\\u8bcd"}], "selected": false, "title": "\\u6587\\u751f\\u89c6\\u9891\\u63d0\\u793a\\u8bcd\\u6539\\u5199LLM", "type": "llm", "variables": [], "vision": {"enabled": false}}, "height": 89, "id": "17488770127560", "position": {"x": 690, "y": 442.189207111932}, "positionAbsolute": {"x": 690, "y": 442.189207111932}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "{{#17488770127560.text#}}\\n{{#1748878727270.text#}}", "desc": "", "selected": false, "title": "\\u6587\\u751f\\u89c6\\u9891\\u56de\\u590d", "type": "answer", "variables": []}, "height": 123, "id": "1748877067785", "position": {"x": 1649, "y": 465}, "positionAbsolute": {"x": 1649, "y": 465}, "selected": true, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "\\u5bf9\\u4e0d\\u8d77\\u51fa\\u73b0\\u9519\\u8bef\\uff0c\\u8bf7\\u91cd\\u65b0\\u8f93\\u5165\\u3002\\u56fe\\u751f\\u89c6\\u9891\\u9700\\u8981\\u4e0a\\u4f20\\u56fe\\u7247\\uff0c\\u8bf7\\u91cd\\u65b0\\u4e0a\\u4f20\\u3002", "desc": "", "selected": false, "title": "\\u76f4\\u63a5\\u56de\\u590d 3", "type": "answer", "variables": []}, "height": 117, "id": "1748877833989", "position": {"x": 690, "y": 747}, "positionAbsolute": {"x": 690, "y": 747}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The text prompt used to generate the image. Doubao will generate an image based on this prompt.", "ja_JP": "The text prompt used to generate the image. Doubao will generate an image based on this prompt.", "pt_BR": "The text prompt used to generate the image. Doubao will generate an image based on this prompt.", "zh_Hans": "The text prompt used to generate the image. Doubao will generate an image based on this prompt."}, "label": {"en_US": "Prompt", "ja_JP": "Prompt", "pt_BR": "Prompt", "zh_Hans": "Prompt"}, "llm_description": "This prompt text will be used to generate image.", "max": null, "min": null, "name": "prompt", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": "1024x1024", "form": "form", "human_description": {"en_US": "The size of the generated image.", "ja_JP": "The size of the generated image.", "pt_BR": "The size of the generated image.", "zh_Hans": "The size of the generated image."}, "label": {"en_US": "Image Size", "ja_JP": "Image Size", "pt_BR": "Image Size", "zh_Hans": "Image Size"}, "llm_description": "", "max": null, "min": null, "name": "size", "options": [{"label": {"en_US": "1024x1024 (Square)", "ja_JP": "1024x1024 (Square)", "pt_BR": "1024x1024 (Square)", "zh_Hans": "1024x1024 (Square)"}, "value": "1024x1024"}, {"label": {"en_US": "1024x1792 (Portrait)", "ja_JP": "1024x1792 (Portrait)", "pt_BR": "1024x1792 (Portrait)", "zh_Hans": "1024x1792 (Portrait)"}, "value": "1024x1792"}, {"label": {"en_US": "1792x1024 (Landscape)", "ja_JP": "1792x1024 (Landscape)", "pt_BR": "1792x1024 (Landscape)", "zh_Hans": "1792x1024 (Landscape)"}, "value": "1792x1024"}], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": "doubao-seedream-3-0-t2i-250415", "form": "form", "human_description": {"en_US": "Model version to use for image generation.", "ja_JP": "Model version to use for image generation.", "pt_BR": "Model version to use for image generation.", "zh_Hans": "Model version to use for image generation."}, "label": {"en_US": "Model Version", "ja_JP": "Model Version", "pt_BR": "Model Version", "zh_Hans": "Model Version"}, "llm_description": "", "max": null, "min": null, "name": "model", "options": [{"label": {"en_US": "Doubao Seedream 3.0", "ja_JP": "Doubao Seedream 3.0", "pt_BR": "Doubao Seedream 3.0", "zh_Hans": "Doubao Seedream 3.0"}, "value": "doubao-seedream-3-0-t2i-250415"}], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "select"}], "params": {"model": "", "prompt": "", "size": ""}, "provider_id": "allenwriter/doubao_image/doubao", "provider_name": "allenwriter/doubao_image/doubao", "provider_type": "builtin", "selected": false, "title": "\\u6587\\u751f\\u56fe", "tool_configurations": {"model": {"type": "constant", "value": "doubao-seedream-3-0-t2i-250415"}, "size": {"type": "constant", "value": "1024x1024"}}, "tool_description": "Generate images with Doubao (\\u8c46\\u5305) AI.", "tool_label": "Text to Image", "tool_name": "text2image", "tool_parameters": {"prompt": {"type": "mixed", "value": "{{#1748876881605.text#}}"}}, "type": "tool", "tool_node_version": "2"}, "height": 115, "id": "1748877903217", "position": {"x": 1010, "y": 331}, "positionAbsolute": {"x": 1010, "y": 331}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The text prompt used to generate the video. Doubao will generate a video based on this prompt.", "ja_JP": "The text prompt used to generate the video. Doubao will generate a video based on this prompt.", "pt_BR": "The text prompt used to generate the video. Doubao will generate a video based on this prompt.", "zh_Hans": "The text prompt used to generate the video. Doubao will generate a video based on this prompt."}, "label": {"en_US": "Prompt", "ja_JP": "Prompt", "pt_BR": "Prompt", "zh_Hans": "Prompt"}, "llm_description": "This prompt text will be used to generate a video.", "max": null, "min": null, "name": "prompt", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": "16:9", "form": "form", "human_description": {"en_US": "The aspect ratio of the generated video.", "ja_JP": "The aspect ratio of the generated video.", "pt_BR": "The aspect ratio of the generated video.", "zh_Hans": "The aspect ratio of the generated video."}, "label": {"en_US": "Aspect Ratio", "ja_JP": "Aspect Ratio", "pt_BR": "Aspect Ratio", "zh_Hans": "Aspect Ratio"}, "llm_description": "", "max": null, "min": null, "name": "ratio", "options": [{"label": {"en_US": "16:9 (Landscape)", "ja_JP": "16:9 (Landscape)", "pt_BR": "16:9 (Landscape)", "zh_Hans": "16:9 (Landscape)"}, "value": "16:9"}, {"label": {"en_US": "9:16 (Portrait)", "ja_JP": "9:16 (Portrait)", "pt_BR": "9:16 (Portrait)", "zh_Hans": "9:16 (Portrait)"}, "value": "9:16"}, {"label": {"en_US": "4:3 (Classic)", "ja_JP": "4:3 (Classic)", "pt_BR": "4:3 (Classic)", "zh_Hans": "4:3 (Classic)"}, "value": "4:3"}, {"label": {"en_US": "1:1 (Square)", "ja_JP": "1:1 (Square)", "pt_BR": "1:1 (Square)", "zh_Hans": "1:1 (Square)"}, "value": "1:1"}], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": "5", "form": "form", "human_description": {"en_US": "The duration of the generated video in seconds.", "ja_JP": "The duration of the generated video in seconds.", "pt_BR": "The duration of the generated video in seconds.", "zh_Hans": "The duration of the generated video in seconds."}, "label": {"en_US": "Duration (seconds)", "ja_JP": "Duration (seconds)", "pt_BR": "Duration (seconds)", "zh_Hans": "Duration (seconds)"}, "llm_description": "", "max": null, "min": null, "name": "duration", "options": [{"label": {"en_US": "5 seconds", "ja_JP": "5 seconds", "pt_BR": "5 seconds", "zh_Hans": "5 seconds"}, "value": "5"}, {"label": {"en_US": "10 seconds", "ja_JP": "10 seconds", "pt_BR": "10 seconds", "zh_Hans": "10 seconds"}, "value": "10"}], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": "doubao-seedance-1-0-lite-t2v-250428", "form": "form", "human_description": {"en_US": "Model version to use for video generation.", "ja_JP": "Model version to use for video generation.", "pt_BR": "Model version to use for video generation.", "zh_Hans": "Model version to use for video generation."}, "label": {"en_US": "Model Version", "ja_JP": "Model Version", "pt_BR": "Model Version", "zh_Hans": "Model Version"}, "llm_description": "", "max": null, "min": null, "name": "model", "options": [{"label": {"en_US": "Doubao Seedance 1.0 Lite", "ja_JP": "Doubao Seedance 1.0 Lite", "pt_BR": "Doubao Seedance 1.0 Lite", "zh_Hans": "Doubao Seedance 1.0 Lite"}, "value": "doubao-seedance-1-0-lite-t2v-250428"}, {"label": {"en_US": "Doubao Seaweed", "ja_JP": "Doubao Seaweed", "pt_BR": "Doubao Seaweed", "zh_Hans": "Doubao Seaweed"}, "value": "doubao-seaweed-241128"}], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "select"}], "params": {"duration": "", "model": "", "prompt": "", "ratio": ""}, "provider_id": "allenwriter/doubao_image/doubao", "provider_name": "allenwriter/doubao_image/doubao", "provider_type": "builtin", "selected": false, "title": "\\u6587\\u751f\\u89c6\\u9891", "tool_configurations": {"duration": {"type": "constant", "value": "5"}, "model": {"type": "constant", "value": "doubao-seedance-1-0-lite-t2v-250428"}, "ratio": {"type": "constant", "value": "16:9"}}, "tool_description": "Generate videos with Doubao (\\u8c46\\u5305) AI.", "tool_label": "Text to Video", "tool_name": "text2video", "tool_parameters": {"prompt": {"type": "mixed", "value": "{{#17488770127560.text#}}"}}, "type": "tool", "tool_node_version": "2"}, "height": 141, "id": "1748878093113", "position": {"x": 1004, "y": 465}, "positionAbsolute": {"x": 1004, "y": 465}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"context": {"enabled": false, "variable_selector": []}, "desc": "", "model": {"completion_params": {}, "mode": "chat", "name": "gemini-2.5-flash-preview-04-17", "provider": "langgenius/openai_api_compatible/openai_api_compatible"}, "prompt_template": [{"id": "b2682c8e-03cf-49a9-b2f4-6276de4b3e90", "role": "system", "text": "\\u4ec5\\u63d0\\u53d6\\u5185\\u5bb9\\u4e2d\\u7684\\u89c6\\u9891\\u94fe\\u63a5\\uff0c\\u7136\\u540e\\u53d8\\u6210 markdown \\u683c\\u5f0f\\u3002\\n\\u8fd9\\u662f\\u4f60\\u770b\\u5230\\u7684\\u5185\\u5bb9\\uff1a{{#1748878093113.text#}}"}, {"id": "5cf163c1-4cbb-4ba2-9b86-edde6d9d7d89", "role": "user", "text": "{{#1748878093113.text#}}"}], "selected": false, "title": "\\u6587\\u751f\\u89c6\\u9891\\u5185\\u5bb9\\u63d0\\u53d6", "type": "llm", "variables": [], "vision": {"enabled": false}}, "height": 95, "id": "1748878727270", "position": {"x": 1329.94603555966, "y": 465}, "positionAbsolute": {"x": 1329.94603555966, "y": 465}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The text prompt used to generate the video. Doubao will generate a video based on this prompt and the input image.", "ja_JP": "The text prompt used to generate the video. Doubao will generate a video based on this prompt and the input image.", "pt_BR": "The text prompt used to generate the video. Doubao will generate a video based on this prompt and the input image.", "zh_Hans": "The text prompt used to generate the video. Doubao will generate a video based on this prompt and the input image."}, "label": {"en_US": "Prompt", "ja_JP": "Prompt", "pt_BR": "Prompt", "zh_Hans": "Prompt"}, "llm_description": "This prompt text will be used to guide the video generation from the input image.", "max": null, "min": null, "name": "prompt", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The image file to be used for video generation.", "ja_JP": "The image file to be used for video generation.", "pt_BR": "The image file to be used for video generation.", "zh_Hans": "The image file to be used for video generation."}, "label": {"en_US": "Image", "ja_JP": "Image", "pt_BR": "Image", "zh_Hans": "Image"}, "llm_description": "Image file that will be transformed into a video.", "max": null, "min": null, "name": "image", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "file"}, {"auto_generate": null, "default": "adaptive", "form": "form", "human_description": {"en_US": "The aspect ratio of the generated video. Note that Doubao API currently only supports adaptive ratio.", "ja_JP": "The aspect ratio of the generated video. Note that Doubao API currently only supports adaptive ratio.", "pt_BR": "The aspect ratio of the generated video. Note that Doubao API currently only supports adaptive ratio.", "zh_Hans": "The aspect ratio of the generated video. Note that Doubao API currently only supports adaptive ratio."}, "label": {"en_US": "Aspect Ratio (Reference Only)", "ja_JP": "Aspect Ratio (Reference Only)", "pt_BR": "Aspect Ratio (Reference Only)", "zh_Hans": "Aspect Ratio (Reference Only)"}, "llm_description": "", "max": null, "min": null, "name": "ratio", "options": [{"label": {"en_US": "Adaptive (Auto)", "ja_JP": "Adaptive (Auto)", "pt_BR": "Adaptive (Auto)", "zh_Hans": "Adaptive (Auto)"}, "value": "adaptive"}, {"label": {"en_US": "16:9 (Landscape)", "ja_JP": "16:9 (Landscape)", "pt_BR": "16:9 (Landscape)", "zh_Hans": "16:9 (Landscape)"}, "value": "16:9"}, {"label": {"en_US": "9:16 (Portrait)", "ja_JP": "9:16 (Portrait)", "pt_BR": "9:16 (Portrait)", "zh_Hans": "9:16 (Portrait)"}, "value": "9:16"}, {"label": {"en_US": "4:3 (Classic)", "ja_JP": "4:3 (Classic)", "pt_BR": "4:3 (Classic)", "zh_Hans": "4:3 (Classic)"}, "value": "4:3"}, {"label": {"en_US": "1:1 (Square)", "ja_JP": "1:1 (Square)", "pt_BR": "1:1 (Square)", "zh_Hans": "1:1 (Square)"}, "value": "1:1"}], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": "5", "form": "form", "human_description": {"en_US": "The duration of the generated video in seconds.", "ja_JP": "The duration of the generated video in seconds.", "pt_BR": "The duration of the generated video in seconds.", "zh_Hans": "The duration of the generated video in seconds."}, "label": {"en_US": "Duration (seconds)", "ja_JP": "Duration (seconds)", "pt_BR": "Duration (seconds)", "zh_Hans": "Duration (seconds)"}, "llm_description": "", "max": null, "min": null, "name": "duration", "options": [{"label": {"en_US": "5 seconds", "ja_JP": "5 seconds", "pt_BR": "5 seconds", "zh_Hans": "5 seconds"}, "value": "5"}, {"label": {"en_US": "10 seconds", "ja_JP": "10 seconds", "pt_BR": "10 seconds", "zh_Hans": "10 seconds"}, "value": "10"}], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "select"}], "params": {"duration": "", "image": "", "prompt": "", "ratio": ""}, "provider_id": "allenwriter/doubao_image/doubao", "provider_name": "allenwriter/doubao_image/doubao", "provider_type": "builtin", "selected": false, "title": "\\u56fe\\u7247\\u751f\\u6210\\u89c6\\u9891", "tool_configurations": {"duration": {"type": "constant", "value": "5"}, "ratio": {"type": "constant", "value": "adaptive"}}, "tool_description": "Generate videos from images with Doubao (\\u8c46\\u5305) AI.", "tool_label": "Image to Video", "tool_name": "image2video", "tool_parameters": {"image": {"type": "variable", "value": ["1748874215740", "picture"]}, "prompt": {"type": "mixed", "value": "{{#1748874215740.prompt#}}"}}, "type": "tool", "tool_node_version": "2"}, "height": 115, "id": "1748879311073", "position": {"x": 690, "y": 576.6482364255644}, "positionAbsolute": {"x": 690, "y": 576.6482364255644}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "{{#1748879311073.text#}}\\n{{#1748879311073.files#}}", "desc": "", "selected": false, "title": "\\u56fe\\u751f\\u89c6\\u9891\\u56de\\u590d", "type": "answer", "variables": []}, "height": 123, "id": "1748879492779", "position": {"x": 1028, "y": 622}, "positionAbsolute": {"x": 1028, "y": 622}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}], "edges": [{"data": {"isInIteration": false, "isInLoop": false, "sourceType": "start", "targetType": "if-else"}, "id": "1748874215740-source-1748876787141-target", "source": "1748874215740", "sourceHandle": "source", "target": "1748876787141", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "if-else", "targetType": "llm"}, "id": "1748876787141-true-1748876881605-target", "source": "1748876787141", "sourceHandle": "true", "target": "1748876881605", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "if-else", "targetType": "llm"}, "id": "1748876787141-9c31fe18-ce4d-4618-a3ec-1e166f773645-17488770127560-target", "source": "1748876787141", "sourceHandle": "9c31fe18-ce4d-4618-a3ec-1e166f773645", "target": "17488770127560", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "if-else", "targetType": "answer"}, "id": "1748876787141-false-1748877833989-target", "source": "1748876787141", "sourceHandle": "false", "target": "1748877833989", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "llm", "targetType": "tool"}, "id": "1748876881605-source-1748877903217-target", "source": "1748876881605", "sourceHandle": "source", "target": "1748877903217", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "tool", "targetType": "answer"}, "id": "1748877903217-source-answer-target", "source": "1748877903217", "sourceHandle": "source", "target": "answer", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "llm", "targetType": "tool"}, "id": "17488770127560-source-1748878093113-target", "source": "17488770127560", "sourceHandle": "source", "target": "1748878093113", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "tool", "targetType": "llm"}, "id": "1748878093113-source-1748878727270-target", "source": "1748878093113", "sourceHandle": "source", "target": "1748878727270", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "llm", "targetType": "answer"}, "id": "1748878727270-source-1748877067785-target", "source": "1748878727270", "sourceHandle": "source", "target": "1748877067785", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "if-else", "targetType": "tool"}, "id": "1748876787141-53fef812-a8d0-4986-b4ad-94d8b614ed05-1748879311073-target", "source": "1748876787141", "sourceHandle": "53fef812-a8d0-4986-b4ad-94d8b614ed05", "target": "1748879311073", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "tool", "targetType": "answer"}, "id": "1748879311073-source-1748879492779-target", "source": "1748879311073", "sourceHandle": "source", "target": "1748879492779", "targetHandle": "target", "type": "custom", "zIndex": 0}], "viewport": {"x": -92.92022021279354, "y": -81.74970268014488, "zoom": 0.732042849863075}}	{"opening_statement": "", "suggested_questions": [], "suggested_questions_after_answer": {"enabled": false}, "text_to_speech": {"enabled": false, "language": "", "voice": ""}, "speech_to_text": {"enabled": false}, "retriever_resource": {"enabled": true}, "sensitive_word_avoidance": {"enabled": false}, "file_upload": {"image": {"enabled": false, "number_limits": 3, "transfer_methods": ["local_file", "remote_url"]}, "enabled": false, "allowed_file_types": ["image"], "allowed_file_extensions": [".JPG", ".JPEG", ".PNG", ".GIF", ".WEBP", ".SVG"], "allowed_file_upload_methods": ["local_file", "remote_url"], "number_limits": 3, "fileUploadConfig": {"file_size_limit": 15, "batch_count_limit": 5, "image_file_size_limit": 10, "video_file_size_limit": 100, "audio_file_size_limit": 50, "workflow_file_upload_limit": 10}}}	6cc88c13-1664-485f-a09f-30e14b5c0df8	2025-07-26 07:35:44	6cc88c13-1664-485f-a09f-30e14b5c0df8	2025-07-26 09:29:43.61095	{}	{}		
20dea26d-b1fd-427b-a288-594c15f5c433	1f6f5922-bac4-41b9-b009-db0d00769fe5	4ad4a46e-5086-4c3c-ba45-40239541cf39	chat	draft	{"nodes": [{"data": {"desc": "", "selected": false, "title": "\\u5f00\\u59cb", "type": "start", "variables": []}, "height": 53, "id": "1750168071548", "position": {"x": 21.0314331630791, "y": 253}, "positionAbsolute": {"x": 21.0314331630791, "y": 253}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "{{#1750168099002.text#}}\\n{{#1750168099002.files#}}\\n   \\u751f\\u6210\\u56fe\\u7247\\u90e8\\u5206---------------------------\\n  {{#1751468423910.text#}}\\n{{#1751468423910.files#}}\\n   \\u751f\\u6210\\u77ed\\u89c6\\u9891\\u90e8\\u5206---------------------------\\n   {{#1751468555490.text#}}\\n    {{#1751468555490.files#}}", "desc": "", "selected": true, "title": "\\u76f4\\u63a5\\u56de\\u590d", "type": "answer", "variables": []}, "height": 231, "id": "answer", "position": {"x": 792, "y": 253}, "positionAbsolute": {"x": 792, "y": 253}, "selected": true, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"agent_parameters": {"instruction": {"type": "constant", "value": "\\u8bf7\\u6839\\u636e\\u7528\\u6237\\u8f93\\u5165{{#sys.query#}}\\u8c03\\u7528get_chinese_herb_info\\u751f\\u6210\\u4e2d\\u836f\\u836f\\u7406\\u6587\\u5b57\\u5185\\u5bb9"}, "mcp_server": {"type": "constant", "value": "https://zhongyao.duckcloud.fun/sse"}, "model": {"type": "constant", "value": {"completion_params": {}, "mode": "chat", "model": "deepseek-V3", "model_type": "llm", "provider": "langgenius/volcengine_maas/volcengine_maas", "type": "model-selector"}}, "query": {"type": "constant", "value": "{{#sys.query#}}"}, "tools": {"type": "constant", "value": [{"enabled": true, "extra": {"description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u5217\\u51faMCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002"}, "parameters": {"server_url": {"auto": 1, "value": null}, "headers": {"auto": 1, "value": null}, "timeout": {"auto": 1, "value": null}, "sse_read_timeout": {"auto": 1, "value": null}}, "provider_name": "arrenxxxxx/mcp_config_during_use/mcp_config", "schemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The URL of the MCP Server with SSE endpoint.", "ja_JP": "The URL of the MCP Server with SSE endpoint.", "pt_BR": "The URL of the MCP Server with SSE endpoint.", "zh_Hans": "MCP\\u670d\\u52a1\\u5668\\u7684SSE\\u7aef\\u70b9URL\\u3002"}, "label": {"en_US": "Server URL", "ja_JP": "Server URL", "pt_BR": "Server URL", "zh_Hans": "\\u670d\\u52a1\\u5668\\u5730\\u5740"}, "llm_description": "The URL of the MCP Server with SSE endpoint.", "max": null, "min": null, "name": "server_url", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "ja_JP": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "pt_BR": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u5934\\uff0cJSON\\u683c\\u5f0f\\uff08\\u4f8b\\u5982\\uff1a{\\"Authorization\\":\\"Bearer token\\"}\\uff09\\u3002"}, "label": {"en_US": "Headers", "ja_JP": "Headers", "pt_BR": "Headers", "zh_Hans": "\\u8bf7\\u6c42\\u5934"}, "llm_description": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "max": null, "min": null, "name": "headers", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": 60, "form": "llm", "human_description": {"en_US": "HTTP request timeout in seconds.", "ja_JP": "HTTP request timeout in seconds.", "pt_BR": "HTTP request timeout in seconds.", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\u3002"}, "label": {"en_US": "Timeout", "ja_JP": "Timeout", "pt_BR": "Timeout", "zh_Hans": "\\u8d85\\u65f6\\u65f6\\u95f4"}, "llm_description": "HTTP request timeout in seconds.", "max": null, "min": null, "name": "timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": 300, "form": "llm", "human_description": {"en_US": "SSE read timeout in seconds (time to wait for SSE events).", "ja_JP": "SSE read timeout in seconds (time to wait for SSE events).", "pt_BR": "SSE read timeout in seconds (time to wait for SSE events).", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\uff08\\u7b49\\u5f85SSE\\u4e8b\\u4ef6\\u7684\\u65f6\\u95f4\\uff09\\u3002"}, "label": {"en_US": "SSE Read Timeout", "ja_JP": "SSE Read Timeout", "pt_BR": "SSE Read Timeout", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6"}, "llm_description": "SSE read timeout in seconds (time to wait for SSE events).", "max": null, "min": null, "name": "sse_read_timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}], "settings": {}, "tool_description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u5217\\u51faMCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002", "tool_label": "\\u5217\\u51faMCP\\u5de5\\u5177", "tool_name": "mcp_list_tools", "type": "builtin"}, {"enabled": true, "extra": {"description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u8c03\\u7528MCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002"}, "parameters": {"server_url": {"auto": 1, "value": null}, "headers": {"auto": 1, "value": null}, "timeout": {"auto": 1, "value": null}, "sse_read_timeout": {"auto": 1, "value": null}, "tool_name": {"auto": 1, "value": null}, "arguments": {"auto": 1, "value": null}}, "provider_name": "arrenxxxxx/mcp_config_during_use/mcp_config", "schemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The URL of the MCP Server with SSE endpoint.", "ja_JP": "The URL of the MCP Server with SSE endpoint.", "pt_BR": "The URL of the MCP Server with SSE endpoint.", "zh_Hans": "MCP\\u670d\\u52a1\\u5668\\u7684SSE\\u7aef\\u70b9URL\\u3002"}, "label": {"en_US": "Server URL", "ja_JP": "Server URL", "pt_BR": "Server URL", "zh_Hans": "\\u670d\\u52a1\\u5668\\u5730\\u5740"}, "llm_description": "The URL of the MCP Server with SSE endpoint.", "max": null, "min": null, "name": "server_url", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "ja_JP": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "pt_BR": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u5934\\uff0cJSON\\u683c\\u5f0f\\uff08\\u4f8b\\u5982\\uff1a{\\"Authorization\\":\\"Bearer token\\"}\\uff09\\u3002"}, "label": {"en_US": "Headers", "ja_JP": "Headers", "pt_BR": "Headers", "zh_Hans": "\\u8bf7\\u6c42\\u5934"}, "llm_description": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "max": null, "min": null, "name": "headers", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": 60, "form": "llm", "human_description": {"en_US": "HTTP request timeout in seconds.", "ja_JP": "HTTP request timeout in seconds.", "pt_BR": "HTTP request timeout in seconds.", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\u3002"}, "label": {"en_US": "Timeout", "ja_JP": "Timeout", "pt_BR": "Timeout", "zh_Hans": "\\u8d85\\u65f6\\u65f6\\u95f4"}, "llm_description": "HTTP request timeout in seconds.", "max": null, "min": null, "name": "timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": 300, "form": "llm", "human_description": {"en_US": "SSE read timeout in seconds (time to wait for SSE events).", "ja_JP": "SSE read timeout in seconds (time to wait for SSE events).", "pt_BR": "SSE read timeout in seconds (time to wait for SSE events).", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\uff08\\u7b49\\u5f85SSE\\u4e8b\\u4ef6\\u7684\\u65f6\\u95f4\\uff09\\u3002"}, "label": {"en_US": "SSE Read Timeout", "ja_JP": "SSE Read Timeout", "pt_BR": "SSE Read Timeout", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6"}, "llm_description": "SSE read timeout in seconds (time to wait for SSE events).", "max": null, "min": null, "name": "sse_read_timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "Name of the tool to execute.", "ja_JP": "Name of the tool to execute.", "pt_BR": "Name of the tool to execute.", "zh_Hans": "\\u8981\\u6267\\u884c\\u7684\\u5de5\\u5177\\u7684\\u540d\\u79f0\\u3002"}, "label": {"en_US": "Tool Name", "ja_JP": "Tool Name", "pt_BR": "Tool Name", "zh_Hans": "\\u5de5\\u5177\\u540d\\u79f0"}, "llm_description": "Name of the tool to execute.", "max": null, "min": null, "name": "tool_name", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "Tool arguments (JSON string in the python dict[str, Any] format).", "ja_JP": "Tool arguments (JSON string in the python dict[str, Any] format).", "pt_BR": "Tool arguments (JSON string in the python dict[str, Any] format).", "zh_Hans": "\\u5de5\\u5177\\u7684\\u53c2\\u6570\\uff0cJSON\\u683c\\u5f0f\\u7684\\u5b57\\u7b26\\u4e32\\uff08Python dict[str, Any]\\u683c\\u5f0f\\uff09\\u3002"}, "label": {"en_US": "Arguments", "ja_JP": "Arguments", "pt_BR": "Arguments", "zh_Hans": "\\u53c2\\u6570"}, "llm_description": "Tool arguments (JSON string in the python dict[str, Any] format).", "max": null, "min": null, "name": "arguments", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}], "settings": {}, "tool_description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u8c03\\u7528MCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002", "tool_label": "\\u8c03\\u7528MCP\\u5de5\\u5177", "tool_name": "mcp_call_tool", "type": "builtin"}]}}, "agent_strategy_label": "MCP FunctionCalling", "agent_strategy_name": "function_calling", "agent_strategy_provider_name": "hjlarry/agent/mcp_agent", "desc": "", "output_schema": null, "plugin_unique_identifier": "hjlarry/agent:0.0.1@f42a5a80b1c77fd0655c755b70ad08da47ceb1acc3638cf13a0eb9ed42b3a128", "selected": false, "title": "Agent-\\u751f\\u6210\\u6587\\u5b57", "type": "agent", "tool_node_version": "2"}, "height": 203, "id": "1750168099002", "position": {"x": 390.3423544014671, "y": 118.60992878815756}, "positionAbsolute": {"x": 390.3423544014671, "y": 118.60992878815756}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"agent_parameters": {"instruction": {"type": "constant", "value": "\\u8bf7\\u6839\\u636e\\u7528\\u6237\\u8f93\\u5165{{#sys.query#}}\\u8c03\\u7528\\u8c03\\u7528get_chinese_herb_image\\u4fe1\\u606f\\u8fd4\\u56de\\u8be5\\u4e2d\\u836f\\u56fe\\u7247\\u4fe1\\u606f"}, "mcp_server": {"type": "constant", "value": "https://zhongyao.duckcloud.fun/sse"}, "model": {"type": "constant", "value": {"completion_params": {}, "mode": "chat", "model": "deepseek-V3", "model_type": "llm", "provider": "langgenius/volcengine_maas/volcengine_maas", "type": "model-selector"}}, "query": {"type": "constant", "value": "{{#sys.query#}}"}, "tools": {"type": "constant", "value": [{"enabled": true, "extra": {"description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u5217\\u51faMCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002"}, "parameters": {"server_url": {"auto": 1, "value": null}, "headers": {"auto": 1, "value": null}, "timeout": {"auto": 1, "value": null}, "sse_read_timeout": {"auto": 1, "value": null}}, "provider_name": "arrenxxxxx/mcp_config_during_use/mcp_config", "schemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The URL of the MCP Server with SSE endpoint.", "ja_JP": "The URL of the MCP Server with SSE endpoint.", "pt_BR": "The URL of the MCP Server with SSE endpoint.", "zh_Hans": "MCP\\u670d\\u52a1\\u5668\\u7684SSE\\u7aef\\u70b9URL\\u3002"}, "label": {"en_US": "Server URL", "ja_JP": "Server URL", "pt_BR": "Server URL", "zh_Hans": "\\u670d\\u52a1\\u5668\\u5730\\u5740"}, "llm_description": "The URL of the MCP Server with SSE endpoint.", "max": null, "min": null, "name": "server_url", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "ja_JP": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "pt_BR": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u5934\\uff0cJSON\\u683c\\u5f0f\\uff08\\u4f8b\\u5982\\uff1a{\\"Authorization\\":\\"Bearer token\\"}\\uff09\\u3002"}, "label": {"en_US": "Headers", "ja_JP": "Headers", "pt_BR": "Headers", "zh_Hans": "\\u8bf7\\u6c42\\u5934"}, "llm_description": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "max": null, "min": null, "name": "headers", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": 60, "form": "llm", "human_description": {"en_US": "HTTP request timeout in seconds.", "ja_JP": "HTTP request timeout in seconds.", "pt_BR": "HTTP request timeout in seconds.", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\u3002"}, "label": {"en_US": "Timeout", "ja_JP": "Timeout", "pt_BR": "Timeout", "zh_Hans": "\\u8d85\\u65f6\\u65f6\\u95f4"}, "llm_description": "HTTP request timeout in seconds.", "max": null, "min": null, "name": "timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": 300, "form": "llm", "human_description": {"en_US": "SSE read timeout in seconds (time to wait for SSE events).", "ja_JP": "SSE read timeout in seconds (time to wait for SSE events).", "pt_BR": "SSE read timeout in seconds (time to wait for SSE events).", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\uff08\\u7b49\\u5f85SSE\\u4e8b\\u4ef6\\u7684\\u65f6\\u95f4\\uff09\\u3002"}, "label": {"en_US": "SSE Read Timeout", "ja_JP": "SSE Read Timeout", "pt_BR": "SSE Read Timeout", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6"}, "llm_description": "SSE read timeout in seconds (time to wait for SSE events).", "max": null, "min": null, "name": "sse_read_timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}], "settings": {}, "tool_description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u5217\\u51faMCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002", "tool_label": "\\u5217\\u51faMCP\\u5de5\\u5177", "tool_name": "mcp_list_tools", "type": "builtin"}, {"enabled": true, "extra": {"description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u8c03\\u7528MCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002"}, "parameters": {"server_url": {"auto": 1, "value": null}, "headers": {"auto": 1, "value": null}, "timeout": {"auto": 1, "value": null}, "sse_read_timeout": {"auto": 1, "value": null}, "tool_name": {"auto": 1, "value": null}, "arguments": {"auto": 1, "value": null}}, "provider_name": "arrenxxxxx/mcp_config_during_use/mcp_config", "schemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The URL of the MCP Server with SSE endpoint.", "ja_JP": "The URL of the MCP Server with SSE endpoint.", "pt_BR": "The URL of the MCP Server with SSE endpoint.", "zh_Hans": "MCP\\u670d\\u52a1\\u5668\\u7684SSE\\u7aef\\u70b9URL\\u3002"}, "label": {"en_US": "Server URL", "ja_JP": "Server URL", "pt_BR": "Server URL", "zh_Hans": "\\u670d\\u52a1\\u5668\\u5730\\u5740"}, "llm_description": "The URL of the MCP Server with SSE endpoint.", "max": null, "min": null, "name": "server_url", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "ja_JP": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "pt_BR": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u5934\\uff0cJSON\\u683c\\u5f0f\\uff08\\u4f8b\\u5982\\uff1a{\\"Authorization\\":\\"Bearer token\\"}\\uff09\\u3002"}, "label": {"en_US": "Headers", "ja_JP": "Headers", "pt_BR": "Headers", "zh_Hans": "\\u8bf7\\u6c42\\u5934"}, "llm_description": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "max": null, "min": null, "name": "headers", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": 60, "form": "llm", "human_description": {"en_US": "HTTP request timeout in seconds.", "ja_JP": "HTTP request timeout in seconds.", "pt_BR": "HTTP request timeout in seconds.", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\u3002"}, "label": {"en_US": "Timeout", "ja_JP": "Timeout", "pt_BR": "Timeout", "zh_Hans": "\\u8d85\\u65f6\\u65f6\\u95f4"}, "llm_description": "HTTP request timeout in seconds.", "max": null, "min": null, "name": "timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": 300, "form": "llm", "human_description": {"en_US": "SSE read timeout in seconds (time to wait for SSE events).", "ja_JP": "SSE read timeout in seconds (time to wait for SSE events).", "pt_BR": "SSE read timeout in seconds (time to wait for SSE events).", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\uff08\\u7b49\\u5f85SSE\\u4e8b\\u4ef6\\u7684\\u65f6\\u95f4\\uff09\\u3002"}, "label": {"en_US": "SSE Read Timeout", "ja_JP": "SSE Read Timeout", "pt_BR": "SSE Read Timeout", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6"}, "llm_description": "SSE read timeout in seconds (time to wait for SSE events).", "max": null, "min": null, "name": "sse_read_timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "Name of the tool to execute.", "ja_JP": "Name of the tool to execute.", "pt_BR": "Name of the tool to execute.", "zh_Hans": "\\u8981\\u6267\\u884c\\u7684\\u5de5\\u5177\\u7684\\u540d\\u79f0\\u3002"}, "label": {"en_US": "Tool Name", "ja_JP": "Tool Name", "pt_BR": "Tool Name", "zh_Hans": "\\u5de5\\u5177\\u540d\\u79f0"}, "llm_description": "Name of the tool to execute.", "max": null, "min": null, "name": "tool_name", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "Tool arguments (JSON string in the python dict[str, Any] format).", "ja_JP": "Tool arguments (JSON string in the python dict[str, Any] format).", "pt_BR": "Tool arguments (JSON string in the python dict[str, Any] format).", "zh_Hans": "\\u5de5\\u5177\\u7684\\u53c2\\u6570\\uff0cJSON\\u683c\\u5f0f\\u7684\\u5b57\\u7b26\\u4e32\\uff08Python dict[str, Any]\\u683c\\u5f0f\\uff09\\u3002"}, "label": {"en_US": "Arguments", "ja_JP": "Arguments", "pt_BR": "Arguments", "zh_Hans": "\\u53c2\\u6570"}, "llm_description": "Tool arguments (JSON string in the python dict[str, Any] format).", "max": null, "min": null, "name": "arguments", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}], "settings": {}, "tool_description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u8c03\\u7528MCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002", "tool_label": "\\u8c03\\u7528MCP\\u5de5\\u5177", "tool_name": "mcp_call_tool", "type": "builtin"}]}}, "agent_strategy_label": "MCP FunctionCalling", "agent_strategy_name": "function_calling", "agent_strategy_provider_name": "hjlarry/agent/mcp_agent", "desc": "", "output_schema": null, "plugin_unique_identifier": "hjlarry/agent:0.0.1@f42a5a80b1c77fd0655c755b70ad08da47ceb1acc3638cf13a0eb9ed42b3a128", "selected": false, "title": "Agent \\u751f\\u6210\\u56fe\\u7247", "type": "agent", "tool_node_version": "2"}, "height": 203, "id": "1751468423910", "position": {"x": 390.3423544014671, "y": 423.7783099798801}, "positionAbsolute": {"x": 390.3423544014671, "y": 423.7783099798801}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"agent_parameters": {"instruction": {"type": "constant", "value": "\\u8bf7\\u6839\\u636e\\u7528\\u6237\\u8f93\\u5165{{#sys.query#}}\\u8c03\\u7528generate_herb_short_video \\u751f\\u6210\\u77ed\\u89c6\\u9891\\u3002"}, "mcp_server": {"type": "constant", "value": "https://zhongyao.duckcloud.fun/sse"}, "model": {"type": "constant", "value": {"completion_params": {}, "mode": "chat", "model": "deepseek-V3", "model_type": "llm", "provider": "langgenius/volcengine_maas/volcengine_maas", "type": "model-selector"}}, "query": {"type": "constant", "value": "{{#sys.query#}}"}, "tools": {"type": "constant", "value": [{"enabled": true, "extra": {"description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u5217\\u51faMCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002"}, "parameters": {"server_url": {"auto": 1, "value": null}, "headers": {"auto": 1, "value": null}, "timeout": {"auto": 1, "value": null}, "sse_read_timeout": {"auto": 1, "value": null}}, "provider_name": "arrenxxxxx/mcp_config_during_use/mcp_config", "schemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The URL of the MCP Server with SSE endpoint.", "ja_JP": "The URL of the MCP Server with SSE endpoint.", "pt_BR": "The URL of the MCP Server with SSE endpoint.", "zh_Hans": "MCP\\u670d\\u52a1\\u5668\\u7684SSE\\u7aef\\u70b9URL\\u3002"}, "label": {"en_US": "Server URL", "ja_JP": "Server URL", "pt_BR": "Server URL", "zh_Hans": "\\u670d\\u52a1\\u5668\\u5730\\u5740"}, "llm_description": "The URL of the MCP Server with SSE endpoint.", "max": null, "min": null, "name": "server_url", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "ja_JP": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "pt_BR": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u5934\\uff0cJSON\\u683c\\u5f0f\\uff08\\u4f8b\\u5982\\uff1a{\\"Authorization\\":\\"Bearer token\\"}\\uff09\\u3002"}, "label": {"en_US": "Headers", "ja_JP": "Headers", "pt_BR": "Headers", "zh_Hans": "\\u8bf7\\u6c42\\u5934"}, "llm_description": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "max": null, "min": null, "name": "headers", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": 60, "form": "llm", "human_description": {"en_US": "HTTP request timeout in seconds.", "ja_JP": "HTTP request timeout in seconds.", "pt_BR": "HTTP request timeout in seconds.", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\u3002"}, "label": {"en_US": "Timeout", "ja_JP": "Timeout", "pt_BR": "Timeout", "zh_Hans": "\\u8d85\\u65f6\\u65f6\\u95f4"}, "llm_description": "HTTP request timeout in seconds.", "max": null, "min": null, "name": "timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": 300, "form": "llm", "human_description": {"en_US": "SSE read timeout in seconds (time to wait for SSE events).", "ja_JP": "SSE read timeout in seconds (time to wait for SSE events).", "pt_BR": "SSE read timeout in seconds (time to wait for SSE events).", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\uff08\\u7b49\\u5f85SSE\\u4e8b\\u4ef6\\u7684\\u65f6\\u95f4\\uff09\\u3002"}, "label": {"en_US": "SSE Read Timeout", "ja_JP": "SSE Read Timeout", "pt_BR": "SSE Read Timeout", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6"}, "llm_description": "SSE read timeout in seconds (time to wait for SSE events).", "max": null, "min": null, "name": "sse_read_timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}], "settings": {}, "tool_description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u5217\\u51faMCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002", "tool_label": "\\u5217\\u51faMCP\\u5de5\\u5177", "tool_name": "mcp_list_tools", "type": "builtin"}, {"enabled": true, "extra": {"description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u8c03\\u7528MCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002"}, "parameters": {"server_url": {"auto": 1, "value": null}, "headers": {"auto": 1, "value": null}, "timeout": {"auto": 1, "value": null}, "sse_read_timeout": {"auto": 1, "value": null}, "tool_name": {"auto": 1, "value": null}, "arguments": {"auto": 1, "value": null}}, "provider_name": "arrenxxxxx/mcp_config_during_use/mcp_config", "schemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The URL of the MCP Server with SSE endpoint.", "ja_JP": "The URL of the MCP Server with SSE endpoint.", "pt_BR": "The URL of the MCP Server with SSE endpoint.", "zh_Hans": "MCP\\u670d\\u52a1\\u5668\\u7684SSE\\u7aef\\u70b9URL\\u3002"}, "label": {"en_US": "Server URL", "ja_JP": "Server URL", "pt_BR": "Server URL", "zh_Hans": "\\u670d\\u52a1\\u5668\\u5730\\u5740"}, "llm_description": "The URL of the MCP Server with SSE endpoint.", "max": null, "min": null, "name": "server_url", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "ja_JP": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "pt_BR": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u5934\\uff0cJSON\\u683c\\u5f0f\\uff08\\u4f8b\\u5982\\uff1a{\\"Authorization\\":\\"Bearer token\\"}\\uff09\\u3002"}, "label": {"en_US": "Headers", "ja_JP": "Headers", "pt_BR": "Headers", "zh_Hans": "\\u8bf7\\u6c42\\u5934"}, "llm_description": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "max": null, "min": null, "name": "headers", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": 60, "form": "llm", "human_description": {"en_US": "HTTP request timeout in seconds.", "ja_JP": "HTTP request timeout in seconds.", "pt_BR": "HTTP request timeout in seconds.", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\u3002"}, "label": {"en_US": "Timeout", "ja_JP": "Timeout", "pt_BR": "Timeout", "zh_Hans": "\\u8d85\\u65f6\\u65f6\\u95f4"}, "llm_description": "HTTP request timeout in seconds.", "max": null, "min": null, "name": "timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": 300, "form": "llm", "human_description": {"en_US": "SSE read timeout in seconds (time to wait for SSE events).", "ja_JP": "SSE read timeout in seconds (time to wait for SSE events).", "pt_BR": "SSE read timeout in seconds (time to wait for SSE events).", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\uff08\\u7b49\\u5f85SSE\\u4e8b\\u4ef6\\u7684\\u65f6\\u95f4\\uff09\\u3002"}, "label": {"en_US": "SSE Read Timeout", "ja_JP": "SSE Read Timeout", "pt_BR": "SSE Read Timeout", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6"}, "llm_description": "SSE read timeout in seconds (time to wait for SSE events).", "max": null, "min": null, "name": "sse_read_timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "Name of the tool to execute.", "ja_JP": "Name of the tool to execute.", "pt_BR": "Name of the tool to execute.", "zh_Hans": "\\u8981\\u6267\\u884c\\u7684\\u5de5\\u5177\\u7684\\u540d\\u79f0\\u3002"}, "label": {"en_US": "Tool Name", "ja_JP": "Tool Name", "pt_BR": "Tool Name", "zh_Hans": "\\u5de5\\u5177\\u540d\\u79f0"}, "llm_description": "Name of the tool to execute.", "max": null, "min": null, "name": "tool_name", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "Tool arguments (JSON string in the python dict[str, Any] format).", "ja_JP": "Tool arguments (JSON string in the python dict[str, Any] format).", "pt_BR": "Tool arguments (JSON string in the python dict[str, Any] format).", "zh_Hans": "\\u5de5\\u5177\\u7684\\u53c2\\u6570\\uff0cJSON\\u683c\\u5f0f\\u7684\\u5b57\\u7b26\\u4e32\\uff08Python dict[str, Any]\\u683c\\u5f0f\\uff09\\u3002"}, "label": {"en_US": "Arguments", "ja_JP": "Arguments", "pt_BR": "Arguments", "zh_Hans": "\\u53c2\\u6570"}, "llm_description": "Tool arguments (JSON string in the python dict[str, Any] format).", "max": null, "min": null, "name": "arguments", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}], "settings": {}, "tool_description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u8c03\\u7528MCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002", "tool_label": "\\u8c03\\u7528MCP\\u5de5\\u5177", "tool_name": "mcp_call_tool", "type": "builtin"}]}}, "agent_strategy_label": "MCP FunctionCalling", "agent_strategy_name": "function_calling", "agent_strategy_provider_name": "hjlarry/agent/mcp_agent", "desc": "", "output_schema": null, "plugin_unique_identifier": "hjlarry/agent:0.0.1@f42a5a80b1c77fd0655c755b70ad08da47ceb1acc3638cf13a0eb9ed42b3a128", "selected": false, "title": "Agent\\u751f\\u6210\\u77ed\\u89c6\\u9891", "type": "agent", "tool_node_version": "2"}, "height": 203, "id": "1751468555490", "position": {"x": 398.6244737691013, "y": 729.1410596838172}, "positionAbsolute": {"x": 398.6244737691013, "y": 729.1410596838172}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}], "edges": [{"data": {"isInLoop": false, "sourceType": "start", "targetType": "agent"}, "id": "1750168071548-source-1750168099002-target", "source": "1750168071548", "sourceHandle": "source", "target": "1750168099002", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "agent", "targetType": "answer"}, "id": "1750168099002-source-answer-target", "source": "1750168099002", "sourceHandle": "source", "target": "answer", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "start", "targetType": "agent"}, "id": "1750168071548-source-1751468423910-target", "source": "1750168071548", "sourceHandle": "source", "target": "1751468423910", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "start", "targetType": "agent"}, "id": "1750168071548-source-1751468555490-target", "source": "1750168071548", "sourceHandle": "source", "target": "1751468555490", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "agent", "targetType": "answer"}, "id": "1751468423910-source-answer-target", "source": "1751468423910", "sourceHandle": "source", "target": "answer", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "agent", "targetType": "answer"}, "id": "1751468555490-source-answer-target", "source": "1751468555490", "sourceHandle": "source", "target": "answer", "targetHandle": "target", "type": "custom", "zIndex": 0}], "viewport": {"x": 72.7701166157126, "y": 29.964951995298463, "zoom": 0.6372803217558302}}	{"opening_statement": "\\u6b22\\u8fce\\u4f7f\\u7528\\u4e2d\\u836f\\u6750\\u4fe1\\u606f\\u67e5\\u8be2\\u4e0e\\u53ef\\u89c6\\u5316\\u7684\\u667a\\u80fd\\u5de5\\u5177\\uff0c\\u80fd\\u591f\\u4e3a\\u60a8\\u5feb\\u901f\\u63d0\\u4f9b\\u4e13\\u4e1a\\u7684\\u836f\\u6750\\u77e5\\u8bc6\\u4e0e\\u9ad8\\u6e05\\u5b9e\\u7269\\u53c2\\u8003\\u56fe\\u3002\\u5f53\\u60a8\\u9700\\u8981\\u4e86\\u89e3\\u67d0\\u5473\\u4e2d\\u836f\\u6750\\u65f6\\uff0c\\u53ea\\u9700\\u8bf4\\u51fa\\u836f\\u6750\\u540d\\u79f0\\uff08\\u4f8b\\u5982 \\u201c\\u9ec4\\u82aa\\u201d\\u201c\\u5f53\\u5f52\\u201d\\uff09\\uff0c\\u7cfb\\u7edf\\u5c06\\u901a\\u8fc7 AI \\u6a21\\u578b\\u4e3a\\u60a8\\u8fd4\\u56de\\u5305\\u542b\\u836f\\u6027\\uff08\\u5bd2 / \\u70ed / \\u6e29 / \\u51c9\\uff09\\u3001\\u836f\\u5473\\uff08\\u9178 / \\u82e6 / \\u7518\\u7b49\\uff09\\u3001\\u5f52\\u7ecf\\u3001\\u529f\\u6548\\u4e3b\\u6cbb\\u53ca\\u7528\\u6cd5\\u7528\\u91cf\\u7684\\u7ed3\\u6784\\u5316\\u4fe1\\u606f\\uff0c\\u540c\\u65f6\\u8fd8\\u80fd\\u751f\\u6210\\u9ad8\\u6e05\\u6670\\u5ea6\\u7684\\u836f\\u6750\\u5b9e\\u7269\\u56fe\\u7247\\uff0c\\u6e05\\u6670\\u5c55\\u793a\\u5176\\u989c\\u8272\\u3001\\u5f62\\u72b6\\u548c\\u8d28\\u5730\\u7b49\\u5916\\u89c2\\u7279\\u5f81\\u3002\\u65e0\\u8bba\\u662f\\u4e2d\\u533b\\u836f\\u5b66\\u4e60\\u3001\\u65b9\\u5242\\u7814\\u7a76\\u8fd8\\u662f\\u79d1\\u666e\\u5c55\\u793a\\uff0c\\u8fd9\\u4e2a\\u5de5\\u5177\\u90fd\\u80fd\\u4e3a\\u60a8\\u63d0\\u4f9b\\u76f4\\u89c2\\u4e14\\u51c6\\u786e\\u7684\\u4fe1\\u606f\\u652f\\u6301\\uff0c\\u8ba9\\u4e2d\\u836f\\u6750\\u77e5\\u8bc6\\u67e5\\u8be2\\u66f4\\u52a0\\u4fbf\\u6377\\u9ad8\\u6548", "suggested_questions": ["\\u9ebb\\u9ec4", "\\u6842\\u679d", "\\u7ec6\\u8f9b", "\\u8584\\u8377", "\\u77e5\\u6bcd"], "suggested_questions_after_answer": {"enabled": false}, "text_to_speech": {"enabled": false, "language": "", "voice": ""}, "speech_to_text": {"enabled": false}, "retriever_resource": {"enabled": true}, "sensitive_word_avoidance": {"enabled": false}, "file_upload": {"image": {"enabled": false, "number_limits": 3, "transfer_methods": ["local_file", "remote_url"]}, "enabled": false, "allowed_file_types": ["image"], "allowed_file_extensions": [".JPG", ".JPEG", ".PNG", ".GIF", ".WEBP", ".SVG"], "allowed_file_upload_methods": ["local_file", "remote_url"], "number_limits": 3, "fileUploadConfig": {"file_size_limit": 15, "batch_count_limit": 5, "image_file_size_limit": 10, "video_file_size_limit": 100, "audio_file_size_limit": 50, "workflow_file_upload_limit": 10}}}	6cc88c13-1664-485f-a09f-30e14b5c0df8	2025-07-26 02:47:21	6cc88c13-1664-485f-a09f-30e14b5c0df8	2025-07-26 07:33:58.446314	{}	{}		
70675b8f-277d-4b66-9dfa-690756a9a77e	1f6f5922-bac4-41b9-b009-db0d00769fe5	b4e3c93b-5495-41e4-aaa4-57d5004b97c9	chat	draft	{"nodes": [{"data": {"desc": "", "selected": false, "title": "\\u5f00\\u59cb", "type": "start", "variables": [{"label": "\\u63d0\\u793a\\u8bcd", "max_length": 256, "options": [], "required": true, "type": "text-input", "variable": "prompt"}, {"allowed_file_extensions": [], "allowed_file_types": ["image"], "allowed_file_upload_methods": ["local_file", "remote_url"], "label": "\\u56fe\\u7247", "max_length": 48, "options": [], "required": false, "type": "file", "variable": "picture"}, {"label": "\\u9009\\u62e9\\u7c7b\\u578b\\uff08\\u6587\\u672c\\u751f\\u6210\\u56fe\\u50cf\\u3001\\u6587\\u672c\\u751f\\u6210\\u89c6\\u9891\\u3001\\u56fe\\u50cf\\u8f6c\\u89c6\\u9891\\uff09", "max_length": 48, "options": ["", "\\u6587\\u751f\\u56fe\\u50cf", "\\u6587\\u751f\\u89c6\\u9891", "\\u56fe\\u751f\\u89c6\\u9891"], "required": true, "type": "select", "variable": "type"}]}, "height": 141, "id": "1748874215740", "position": {"x": 55, "y": 348}, "positionAbsolute": {"x": 55, "y": 348}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "{{#1749805551292.text#}}\\n{{#1749805551292.files#}}", "desc": "", "selected": false, "title": "\\u6587\\u751f\\u56fe\\u56de\\u590d", "type": "answer", "variables": []}, "height": 123, "id": "answer", "position": {"x": 1090.6715713675765, "y": 190.6649399527434}, "positionAbsolute": {"x": 1090.6715713675765, "y": 190.6649399527434}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"cases": [{"case_id": "true", "conditions": [{"comparison_operator": "is", "id": "dbb313e1-9d68-4c34-aa3d-5b4b81408447", "value": "\\u6587\\u751f\\u56fe\\u50cf", "varType": "string", "variable_selector": ["1748874215740", "type"]}], "id": "true", "logical_operator": "and"}, {"case_id": "9c31fe18-ce4d-4618-a3ec-1e166f773645", "conditions": [{"comparison_operator": "contains", "id": "71d50791-8fbc-4bb7-b1f8-f54da5fd3cb3", "value": "\\u6587\\u751f\\u89c6\\u9891", "varType": "string", "variable_selector": ["1748874215740", "type"]}], "id": "9c31fe18-ce4d-4618-a3ec-1e166f773645", "logical_operator": "and"}, {"case_id": "53fef812-a8d0-4986-b4ad-94d8b614ed05", "conditions": [{"comparison_operator": "contains", "id": "52d0f3a1-7131-4684-94f6-394f69ed9718", "value": "\\u56fe\\u751f\\u89c6\\u9891", "varType": "string", "variable_selector": ["1748874215740", "type"]}, {"comparison_operator": "exists", "id": "f99ada8f-2ef0-466b-9988-525575747457", "value": "", "varType": "file", "variable_selector": ["1748874215740", "picture"]}], "id": "53fef812-a8d0-4986-b4ad-94d8b614ed05", "logical_operator": "and"}], "desc": "", "selected": false, "title": "\\u6761\\u4ef6\\u5206\\u652f", "type": "if-else"}, "height": 247, "id": "1748876787141", "position": {"x": 378, "y": 348}, "positionAbsolute": {"x": 378, "y": 348}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "\\u5bf9\\u4e0d\\u8d77\\u51fa\\u73b0\\u9519\\u8bef\\uff0c\\u8bf7\\u91cd\\u65b0\\u8f93\\u5165\\u3002\\u56fe\\u751f\\u89c6\\u9891\\u9700\\u8981\\u4e0a\\u4f20\\u56fe\\u7247\\uff0c\\u8bf7\\u91cd\\u65b0\\u4e0a\\u4f20\\u3002", "desc": "", "selected": false, "title": "\\u76f4\\u63a5\\u56de\\u590d 3", "type": "answer", "variables": []}, "height": 117, "id": "1748877833989", "position": {"x": 681.675550216476, "y": 870.677539640926}, "positionAbsolute": {"x": 681.675550216476, "y": 870.677539640926}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "{{#17498064656760.text#}}\\n{{#17498064656760.files#}}", "desc": "", "selected": false, "title": "\\u56fe\\u751f\\u89c6\\u9891\\u56de\\u590d", "type": "answer", "variables": []}, "height": 123, "id": "1748879492779", "position": {"x": 1436.2829464623849, "y": 733.2091434109943}, "positionAbsolute": {"x": 1436.2829464623849, "y": 733.2091434109943}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"agent_parameters": {"instruction": {"type": "constant", "value": "\\u8bf7\\u6839\\u636e\\u7528\\u8f93\\u5165\\u7684\\u4fe1\\u606f{{#1748874215740.prompt#}}\\u8c03\\u7528text_to_image \\u65b9\\u6cd5"}, "mcp_server": {"type": "constant", "value": "http://14.103.204.132:8002/sse"}, "model": {"type": "constant", "value": {"completion_params": {}, "mode": "chat", "model": "Qwen/Qwen3-8B", "model_type": "llm", "provider": "langgenius/siliconflow/siliconflow", "type": "model-selector"}}, "query": {"type": "constant", "value": "{{#1748874215740.prompt#}}"}, "tools": {"type": "constant", "value": [{"enabled": true, "extra": {"description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u5217\\u51faMCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002"}, "parameters": {"server_url": {"auto": 1, "value": null}, "headers": {"auto": 1, "value": null}, "timeout": {"auto": 1, "value": null}, "sse_read_timeout": {"auto": 1, "value": null}}, "provider_name": "arrenxxxxx/mcp_config_during_use/mcp_config", "schemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The URL of the MCP Server with SSE endpoint.", "ja_JP": "The URL of the MCP Server with SSE endpoint.", "pt_BR": "The URL of the MCP Server with SSE endpoint.", "zh_Hans": "MCP\\u670d\\u52a1\\u5668\\u7684SSE\\u7aef\\u70b9URL\\u3002"}, "label": {"en_US": "Server URL", "ja_JP": "Server URL", "pt_BR": "Server URL", "zh_Hans": "\\u670d\\u52a1\\u5668\\u5730\\u5740"}, "llm_description": "The URL of the MCP Server with SSE endpoint.", "max": null, "min": null, "name": "server_url", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "ja_JP": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "pt_BR": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u5934\\uff0cJSON\\u683c\\u5f0f\\uff08\\u4f8b\\u5982\\uff1a{\\"Authorization\\":\\"Bearer token\\"}\\uff09\\u3002"}, "label": {"en_US": "Headers", "ja_JP": "Headers", "pt_BR": "Headers", "zh_Hans": "\\u8bf7\\u6c42\\u5934"}, "llm_description": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "max": null, "min": null, "name": "headers", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": 60, "form": "llm", "human_description": {"en_US": "HTTP request timeout in seconds.", "ja_JP": "HTTP request timeout in seconds.", "pt_BR": "HTTP request timeout in seconds.", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\u3002"}, "label": {"en_US": "Timeout", "ja_JP": "Timeout", "pt_BR": "Timeout", "zh_Hans": "\\u8d85\\u65f6\\u65f6\\u95f4"}, "llm_description": "HTTP request timeout in seconds.", "max": null, "min": null, "name": "timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": 300, "form": "llm", "human_description": {"en_US": "SSE read timeout in seconds (time to wait for SSE events).", "ja_JP": "SSE read timeout in seconds (time to wait for SSE events).", "pt_BR": "SSE read timeout in seconds (time to wait for SSE events).", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\uff08\\u7b49\\u5f85SSE\\u4e8b\\u4ef6\\u7684\\u65f6\\u95f4\\uff09\\u3002"}, "label": {"en_US": "SSE Read Timeout", "ja_JP": "SSE Read Timeout", "pt_BR": "SSE Read Timeout", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6"}, "llm_description": "SSE read timeout in seconds (time to wait for SSE events).", "max": null, "min": null, "name": "sse_read_timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}], "settings": {}, "tool_description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u5217\\u51faMCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002", "tool_label": "\\u5217\\u51faMCP\\u5de5\\u5177", "tool_name": "mcp_list_tools", "type": "builtin"}, {"enabled": true, "extra": {"description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u8c03\\u7528MCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002"}, "parameters": {"server_url": {"auto": 1, "value": null}, "headers": {"auto": 1, "value": null}, "timeout": {"auto": 1, "value": null}, "sse_read_timeout": {"auto": 1, "value": null}, "tool_name": {"auto": 1, "value": null}, "arguments": {"auto": 1, "value": null}}, "provider_name": "arrenxxxxx/mcp_config_during_use/mcp_config", "schemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The URL of the MCP Server with SSE endpoint.", "ja_JP": "The URL of the MCP Server with SSE endpoint.", "pt_BR": "The URL of the MCP Server with SSE endpoint.", "zh_Hans": "MCP\\u670d\\u52a1\\u5668\\u7684SSE\\u7aef\\u70b9URL\\u3002"}, "label": {"en_US": "Server URL", "ja_JP": "Server URL", "pt_BR": "Server URL", "zh_Hans": "\\u670d\\u52a1\\u5668\\u5730\\u5740"}, "llm_description": "The URL of the MCP Server with SSE endpoint.", "max": null, "min": null, "name": "server_url", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "ja_JP": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "pt_BR": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u5934\\uff0cJSON\\u683c\\u5f0f\\uff08\\u4f8b\\u5982\\uff1a{\\"Authorization\\":\\"Bearer token\\"}\\uff09\\u3002"}, "label": {"en_US": "Headers", "ja_JP": "Headers", "pt_BR": "Headers", "zh_Hans": "\\u8bf7\\u6c42\\u5934"}, "llm_description": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "max": null, "min": null, "name": "headers", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": 60, "form": "llm", "human_description": {"en_US": "HTTP request timeout in seconds.", "ja_JP": "HTTP request timeout in seconds.", "pt_BR": "HTTP request timeout in seconds.", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\u3002"}, "label": {"en_US": "Timeout", "ja_JP": "Timeout", "pt_BR": "Timeout", "zh_Hans": "\\u8d85\\u65f6\\u65f6\\u95f4"}, "llm_description": "HTTP request timeout in seconds.", "max": null, "min": null, "name": "timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": 300, "form": "llm", "human_description": {"en_US": "SSE read timeout in seconds (time to wait for SSE events).", "ja_JP": "SSE read timeout in seconds (time to wait for SSE events).", "pt_BR": "SSE read timeout in seconds (time to wait for SSE events).", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\uff08\\u7b49\\u5f85SSE\\u4e8b\\u4ef6\\u7684\\u65f6\\u95f4\\uff09\\u3002"}, "label": {"en_US": "SSE Read Timeout", "ja_JP": "SSE Read Timeout", "pt_BR": "SSE Read Timeout", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6"}, "llm_description": "SSE read timeout in seconds (time to wait for SSE events).", "max": null, "min": null, "name": "sse_read_timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "Name of the tool to execute.", "ja_JP": "Name of the tool to execute.", "pt_BR": "Name of the tool to execute.", "zh_Hans": "\\u8981\\u6267\\u884c\\u7684\\u5de5\\u5177\\u7684\\u540d\\u79f0\\u3002"}, "label": {"en_US": "Tool Name", "ja_JP": "Tool Name", "pt_BR": "Tool Name", "zh_Hans": "\\u5de5\\u5177\\u540d\\u79f0"}, "llm_description": "Name of the tool to execute.", "max": null, "min": null, "name": "tool_name", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "Tool arguments (JSON string in the python dict[str, Any] format).", "ja_JP": "Tool arguments (JSON string in the python dict[str, Any] format).", "pt_BR": "Tool arguments (JSON string in the python dict[str, Any] format).", "zh_Hans": "\\u5de5\\u5177\\u7684\\u53c2\\u6570\\uff0cJSON\\u683c\\u5f0f\\u7684\\u5b57\\u7b26\\u4e32\\uff08Python dict[str, Any]\\u683c\\u5f0f\\uff09\\u3002"}, "label": {"en_US": "Arguments", "ja_JP": "Arguments", "pt_BR": "Arguments", "zh_Hans": "\\u53c2\\u6570"}, "llm_description": "Tool arguments (JSON string in the python dict[str, Any] format).", "max": null, "min": null, "name": "arguments", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}], "settings": {}, "tool_description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u8c03\\u7528MCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002", "tool_label": "\\u8c03\\u7528MCP\\u5de5\\u5177", "tool_name": "mcp_call_tool", "type": "builtin"}]}}, "agent_strategy_label": "MCP FunctionCalling", "agent_strategy_name": "function_calling", "agent_strategy_provider_name": "hjlarry/agent/mcp_agent", "desc": "", "output_schema": null, "plugin_unique_identifier": "hjlarry/agent:0.0.1@f42a5a80b1c77fd0655c755b70ad08da47ceb1acc3638cf13a0eb9ed42b3a128", "selected": false, "title": "\\u6587\\u751f\\u56fe\\u7247Agent", "type": "agent", "tool_node_version": "2"}, "height": 203, "id": "1749805551292", "position": {"x": 690, "y": 190.6649399527434}, "positionAbsolute": {"x": 690, "y": 190.6649399527434}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"agent_parameters": {"instruction": {"type": "constant", "value": "\\u8bf7\\u6839\\u636e\\u7528\\u8f93\\u5165\\u7684\\u4fe1\\u606f{{#1748874215740.prompt#}}\\u8c03\\u7528text_to_video \\u65b9\\u6cd5"}, "mcp_server": {"type": "constant", "value": "http://14.103.204.132:8002/sse"}, "model": {"type": "constant", "value": {"completion_params": {}, "mode": "chat", "model": "Qwen/Qwen3-8B", "model_type": "llm", "provider": "langgenius/siliconflow/siliconflow", "type": "model-selector"}}, "query": {"type": "constant", "value": "{{#1748874215740.prompt#}}"}, "tools": {"type": "constant", "value": [{"enabled": true, "extra": {"description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u5217\\u51faMCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002"}, "parameters": {"server_url": {"auto": 1, "value": null}, "headers": {"auto": 1, "value": null}, "timeout": {"auto": 1, "value": null}, "sse_read_timeout": {"auto": 1, "value": null}}, "provider_name": "arrenxxxxx/mcp_config_during_use/mcp_config", "schemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The URL of the MCP Server with SSE endpoint.", "ja_JP": "The URL of the MCP Server with SSE endpoint.", "pt_BR": "The URL of the MCP Server with SSE endpoint.", "zh_Hans": "MCP\\u670d\\u52a1\\u5668\\u7684SSE\\u7aef\\u70b9URL\\u3002"}, "label": {"en_US": "Server URL", "ja_JP": "Server URL", "pt_BR": "Server URL", "zh_Hans": "\\u670d\\u52a1\\u5668\\u5730\\u5740"}, "llm_description": "The URL of the MCP Server with SSE endpoint.", "max": null, "min": null, "name": "server_url", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "ja_JP": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "pt_BR": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u5934\\uff0cJSON\\u683c\\u5f0f\\uff08\\u4f8b\\u5982\\uff1a{\\"Authorization\\":\\"Bearer token\\"}\\uff09\\u3002"}, "label": {"en_US": "Headers", "ja_JP": "Headers", "pt_BR": "Headers", "zh_Hans": "\\u8bf7\\u6c42\\u5934"}, "llm_description": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "max": null, "min": null, "name": "headers", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": 60, "form": "llm", "human_description": {"en_US": "HTTP request timeout in seconds.", "ja_JP": "HTTP request timeout in seconds.", "pt_BR": "HTTP request timeout in seconds.", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\u3002"}, "label": {"en_US": "Timeout", "ja_JP": "Timeout", "pt_BR": "Timeout", "zh_Hans": "\\u8d85\\u65f6\\u65f6\\u95f4"}, "llm_description": "HTTP request timeout in seconds.", "max": null, "min": null, "name": "timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": 300, "form": "llm", "human_description": {"en_US": "SSE read timeout in seconds (time to wait for SSE events).", "ja_JP": "SSE read timeout in seconds (time to wait for SSE events).", "pt_BR": "SSE read timeout in seconds (time to wait for SSE events).", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\uff08\\u7b49\\u5f85SSE\\u4e8b\\u4ef6\\u7684\\u65f6\\u95f4\\uff09\\u3002"}, "label": {"en_US": "SSE Read Timeout", "ja_JP": "SSE Read Timeout", "pt_BR": "SSE Read Timeout", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6"}, "llm_description": "SSE read timeout in seconds (time to wait for SSE events).", "max": null, "min": null, "name": "sse_read_timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}], "settings": {}, "tool_description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u5217\\u51faMCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002", "tool_label": "\\u5217\\u51faMCP\\u5de5\\u5177", "tool_name": "mcp_list_tools", "type": "builtin"}, {"enabled": true, "extra": {"description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u8c03\\u7528MCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002"}, "parameters": {"server_url": {"auto": 1, "value": null}, "headers": {"auto": 1, "value": null}, "timeout": {"auto": 1, "value": null}, "sse_read_timeout": {"auto": 1, "value": null}, "tool_name": {"auto": 1, "value": null}, "arguments": {"auto": 1, "value": null}}, "provider_name": "arrenxxxxx/mcp_config_during_use/mcp_config", "schemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The URL of the MCP Server with SSE endpoint.", "ja_JP": "The URL of the MCP Server with SSE endpoint.", "pt_BR": "The URL of the MCP Server with SSE endpoint.", "zh_Hans": "MCP\\u670d\\u52a1\\u5668\\u7684SSE\\u7aef\\u70b9URL\\u3002"}, "label": {"en_US": "Server URL", "ja_JP": "Server URL", "pt_BR": "Server URL", "zh_Hans": "\\u670d\\u52a1\\u5668\\u5730\\u5740"}, "llm_description": "The URL of the MCP Server with SSE endpoint.", "max": null, "min": null, "name": "server_url", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "ja_JP": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "pt_BR": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u5934\\uff0cJSON\\u683c\\u5f0f\\uff08\\u4f8b\\u5982\\uff1a{\\"Authorization\\":\\"Bearer token\\"}\\uff09\\u3002"}, "label": {"en_US": "Headers", "ja_JP": "Headers", "pt_BR": "Headers", "zh_Hans": "\\u8bf7\\u6c42\\u5934"}, "llm_description": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "max": null, "min": null, "name": "headers", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": 60, "form": "llm", "human_description": {"en_US": "HTTP request timeout in seconds.", "ja_JP": "HTTP request timeout in seconds.", "pt_BR": "HTTP request timeout in seconds.", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\u3002"}, "label": {"en_US": "Timeout", "ja_JP": "Timeout", "pt_BR": "Timeout", "zh_Hans": "\\u8d85\\u65f6\\u65f6\\u95f4"}, "llm_description": "HTTP request timeout in seconds.", "max": null, "min": null, "name": "timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": 300, "form": "llm", "human_description": {"en_US": "SSE read timeout in seconds (time to wait for SSE events).", "ja_JP": "SSE read timeout in seconds (time to wait for SSE events).", "pt_BR": "SSE read timeout in seconds (time to wait for SSE events).", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\uff08\\u7b49\\u5f85SSE\\u4e8b\\u4ef6\\u7684\\u65f6\\u95f4\\uff09\\u3002"}, "label": {"en_US": "SSE Read Timeout", "ja_JP": "SSE Read Timeout", "pt_BR": "SSE Read Timeout", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6"}, "llm_description": "SSE read timeout in seconds (time to wait for SSE events).", "max": null, "min": null, "name": "sse_read_timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "Name of the tool to execute.", "ja_JP": "Name of the tool to execute.", "pt_BR": "Name of the tool to execute.", "zh_Hans": "\\u8981\\u6267\\u884c\\u7684\\u5de5\\u5177\\u7684\\u540d\\u79f0\\u3002"}, "label": {"en_US": "Tool Name", "ja_JP": "Tool Name", "pt_BR": "Tool Name", "zh_Hans": "\\u5de5\\u5177\\u540d\\u79f0"}, "llm_description": "Name of the tool to execute.", "max": null, "min": null, "name": "tool_name", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "Tool arguments (JSON string in the python dict[str, Any] format).", "ja_JP": "Tool arguments (JSON string in the python dict[str, Any] format).", "pt_BR": "Tool arguments (JSON string in the python dict[str, Any] format).", "zh_Hans": "\\u5de5\\u5177\\u7684\\u53c2\\u6570\\uff0cJSON\\u683c\\u5f0f\\u7684\\u5b57\\u7b26\\u4e32\\uff08Python dict[str, Any]\\u683c\\u5f0f\\uff09\\u3002"}, "label": {"en_US": "Arguments", "ja_JP": "Arguments", "pt_BR": "Arguments", "zh_Hans": "\\u53c2\\u6570"}, "llm_description": "Tool arguments (JSON string in the python dict[str, Any] format).", "max": null, "min": null, "name": "arguments", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}], "settings": {}, "tool_description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u8c03\\u7528MCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002", "tool_label": "\\u8c03\\u7528MCP\\u5de5\\u5177", "tool_name": "mcp_call_tool", "type": "builtin"}]}}, "agent_strategy_label": "MCP FunctionCalling", "agent_strategy_name": "function_calling", "agent_strategy_provider_name": "hjlarry/agent/mcp_agent", "desc": "", "output_schema": null, "plugin_unique_identifier": "hjlarry/agent:0.0.1@f42a5a80b1c77fd0655c755b70ad08da47ceb1acc3638cf13a0eb9ed42b3a128", "selected": false, "title": "\\u6587\\u751f\\u89c6\\u9891Agent", "type": "agent", "tool_node_version": "2"}, "height": 203, "id": "17498061130260", "position": {"x": 1037.4252645253553, "y": 342.4047535684233}, "positionAbsolute": {"x": 1037.4252645253553, "y": 342.4047535684233}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "{{#17498061130260.text#}}\\n{{#17498061130260.files#}}", "desc": "", "selected": false, "title": "\\u6587\\u751f\\u89c6\\u9891\\u56de\\u590d", "type": "answer", "variables": []}, "height": 123, "id": "17498062846900", "position": {"x": 1467.0633307513958, "y": 337.8576038238046}, "positionAbsolute": {"x": 1467.0633307513958, "y": 337.8576038238046}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"agent_parameters": {"instruction": {"type": "constant", "value": "\\u8bf7\\u6839\\u636e\\u7528\\u8f93\\u5165\\u7684\\u4fe1\\u606f{{#1748874215740.prompt#}}\\u8c03\\u7528image_to_video \\u65b9\\u6cd5"}, "mcp_server": {"type": "constant", "value": "http://14.103.204.132:8002/sse"}, "model": {"type": "constant", "value": {"completion_params": {}, "mode": "chat", "model": "Qwen/Qwen3-8B", "model_type": "llm", "provider": "langgenius/siliconflow/siliconflow", "type": "model-selector"}}, "query": {"type": "constant", "value": "{{#1748874215740.prompt#}}"}, "tools": {"type": "constant", "value": [{"enabled": true, "extra": {"description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u5217\\u51faMCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002"}, "parameters": {"server_url": {"auto": 1, "value": null}, "headers": {"auto": 1, "value": null}, "timeout": {"auto": 1, "value": null}, "sse_read_timeout": {"auto": 1, "value": null}}, "provider_name": "arrenxxxxx/mcp_config_during_use/mcp_config", "schemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The URL of the MCP Server with SSE endpoint.", "ja_JP": "The URL of the MCP Server with SSE endpoint.", "pt_BR": "The URL of the MCP Server with SSE endpoint.", "zh_Hans": "MCP\\u670d\\u52a1\\u5668\\u7684SSE\\u7aef\\u70b9URL\\u3002"}, "label": {"en_US": "Server URL", "ja_JP": "Server URL", "pt_BR": "Server URL", "zh_Hans": "\\u670d\\u52a1\\u5668\\u5730\\u5740"}, "llm_description": "The URL of the MCP Server with SSE endpoint.", "max": null, "min": null, "name": "server_url", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "ja_JP": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "pt_BR": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u5934\\uff0cJSON\\u683c\\u5f0f\\uff08\\u4f8b\\u5982\\uff1a{\\"Authorization\\":\\"Bearer token\\"}\\uff09\\u3002"}, "label": {"en_US": "Headers", "ja_JP": "Headers", "pt_BR": "Headers", "zh_Hans": "\\u8bf7\\u6c42\\u5934"}, "llm_description": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "max": null, "min": null, "name": "headers", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": 60, "form": "llm", "human_description": {"en_US": "HTTP request timeout in seconds.", "ja_JP": "HTTP request timeout in seconds.", "pt_BR": "HTTP request timeout in seconds.", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\u3002"}, "label": {"en_US": "Timeout", "ja_JP": "Timeout", "pt_BR": "Timeout", "zh_Hans": "\\u8d85\\u65f6\\u65f6\\u95f4"}, "llm_description": "HTTP request timeout in seconds.", "max": null, "min": null, "name": "timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": 300, "form": "llm", "human_description": {"en_US": "SSE read timeout in seconds (time to wait for SSE events).", "ja_JP": "SSE read timeout in seconds (time to wait for SSE events).", "pt_BR": "SSE read timeout in seconds (time to wait for SSE events).", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\uff08\\u7b49\\u5f85SSE\\u4e8b\\u4ef6\\u7684\\u65f6\\u95f4\\uff09\\u3002"}, "label": {"en_US": "SSE Read Timeout", "ja_JP": "SSE Read Timeout", "pt_BR": "SSE Read Timeout", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6"}, "llm_description": "SSE read timeout in seconds (time to wait for SSE events).", "max": null, "min": null, "name": "sse_read_timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}], "settings": {}, "tool_description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u5217\\u51faMCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002", "tool_label": "\\u5217\\u51faMCP\\u5de5\\u5177", "tool_name": "mcp_list_tools", "type": "builtin"}, {"enabled": true, "extra": {"description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u8c03\\u7528MCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002"}, "parameters": {"server_url": {"auto": 1, "value": null}, "headers": {"auto": 1, "value": null}, "timeout": {"auto": 1, "value": null}, "sse_read_timeout": {"auto": 1, "value": null}, "tool_name": {"auto": 1, "value": null}, "arguments": {"auto": 1, "value": null}}, "provider_name": "arrenxxxxx/mcp_config_during_use/mcp_config", "schemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The URL of the MCP Server with SSE endpoint.", "ja_JP": "The URL of the MCP Server with SSE endpoint.", "pt_BR": "The URL of the MCP Server with SSE endpoint.", "zh_Hans": "MCP\\u670d\\u52a1\\u5668\\u7684SSE\\u7aef\\u70b9URL\\u3002"}, "label": {"en_US": "Server URL", "ja_JP": "Server URL", "pt_BR": "Server URL", "zh_Hans": "\\u670d\\u52a1\\u5668\\u5730\\u5740"}, "llm_description": "The URL of the MCP Server with SSE endpoint.", "max": null, "min": null, "name": "server_url", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "ja_JP": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "pt_BR": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u5934\\uff0cJSON\\u683c\\u5f0f\\uff08\\u4f8b\\u5982\\uff1a{\\"Authorization\\":\\"Bearer token\\"}\\uff09\\u3002"}, "label": {"en_US": "Headers", "ja_JP": "Headers", "pt_BR": "Headers", "zh_Hans": "\\u8bf7\\u6c42\\u5934"}, "llm_description": "HTTP headers in JSON format (e.g. {\\"Authorization\\":\\"Bearer token\\"}).", "max": null, "min": null, "name": "headers", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": 60, "form": "llm", "human_description": {"en_US": "HTTP request timeout in seconds.", "ja_JP": "HTTP request timeout in seconds.", "pt_BR": "HTTP request timeout in seconds.", "zh_Hans": "HTTP\\u8bf7\\u6c42\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\u3002"}, "label": {"en_US": "Timeout", "ja_JP": "Timeout", "pt_BR": "Timeout", "zh_Hans": "\\u8d85\\u65f6\\u65f6\\u95f4"}, "llm_description": "HTTP request timeout in seconds.", "max": null, "min": null, "name": "timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": 300, "form": "llm", "human_description": {"en_US": "SSE read timeout in seconds (time to wait for SSE events).", "ja_JP": "SSE read timeout in seconds (time to wait for SSE events).", "pt_BR": "SSE read timeout in seconds (time to wait for SSE events).", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6\\u65f6\\u95f4\\uff08\\u79d2\\uff09\\uff08\\u7b49\\u5f85SSE\\u4e8b\\u4ef6\\u7684\\u65f6\\u95f4\\uff09\\u3002"}, "label": {"en_US": "SSE Read Timeout", "ja_JP": "SSE Read Timeout", "pt_BR": "SSE Read Timeout", "zh_Hans": "SSE\\u8bfb\\u53d6\\u8d85\\u65f6"}, "llm_description": "SSE read timeout in seconds (time to wait for SSE events).", "max": null, "min": null, "name": "sse_read_timeout", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "Name of the tool to execute.", "ja_JP": "Name of the tool to execute.", "pt_BR": "Name of the tool to execute.", "zh_Hans": "\\u8981\\u6267\\u884c\\u7684\\u5de5\\u5177\\u7684\\u540d\\u79f0\\u3002"}, "label": {"en_US": "Tool Name", "ja_JP": "Tool Name", "pt_BR": "Tool Name", "zh_Hans": "\\u5de5\\u5177\\u540d\\u79f0"}, "llm_description": "Name of the tool to execute.", "max": null, "min": null, "name": "tool_name", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "Tool arguments (JSON string in the python dict[str, Any] format).", "ja_JP": "Tool arguments (JSON string in the python dict[str, Any] format).", "pt_BR": "Tool arguments (JSON string in the python dict[str, Any] format).", "zh_Hans": "\\u5de5\\u5177\\u7684\\u53c2\\u6570\\uff0cJSON\\u683c\\u5f0f\\u7684\\u5b57\\u7b26\\u4e32\\uff08Python dict[str, Any]\\u683c\\u5f0f\\uff09\\u3002"}, "label": {"en_US": "Arguments", "ja_JP": "Arguments", "pt_BR": "Arguments", "zh_Hans": "\\u53c2\\u6570"}, "llm_description": "Tool arguments (JSON string in the python dict[str, Any] format).", "max": null, "min": null, "name": "arguments", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}], "settings": {}, "tool_description": "\\u901a\\u8fc7HTTP with SSE\\u4f20\\u8f93\\u6765\\u8c03\\u7528MCP\\u670d\\u52a1\\u7aef\\u5de5\\u5177\\u3002", "tool_label": "\\u8c03\\u7528MCP\\u5de5\\u5177", "tool_name": "mcp_call_tool", "type": "builtin"}]}}, "agent_strategy_label": "MCP FunctionCalling", "agent_strategy_name": "function_calling", "agent_strategy_provider_name": "hjlarry/agent/mcp_agent", "desc": "", "output_schema": null, "plugin_unique_identifier": "hjlarry/agent:0.0.1@f42a5a80b1c77fd0655c755b70ad08da47ceb1acc3638cf13a0eb9ed42b3a128", "selected": false, "title": "\\u56fe\\u751f\\u89c6\\u9891Agent ", "type": "agent", "tool_node_version": "2"}, "height": 203, "id": "17498064656760", "position": {"x": 1048.9122483031251, "y": 738.9526352998793}, "positionAbsolute": {"x": 1048.9122483031251, "y": 738.9526352998793}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The unit is Yuan, between 1 and 200.", "ja_JP": "The unit is Yuan, between 1 and 200.", "pt_BR": "The unit is Yuan, between 1 and 200.", "zh_Hans": "\\u4ee5\\u5143\\u4e3a\\u5355\\u4f4d\\uff0c1\\u5143\\u81f3200\\u5143\\u4e4b\\u95f4\\u3002\\u4f8b\\u59821.25"}, "label": {"en_US": "Order Price", "ja_JP": "Order Price", "pt_BR": "Order Price", "zh_Hans": "\\u8ba2\\u5355\\u4ef7\\u683c"}, "llm_description": "the price of the order", "max": 200, "min": 1, "name": "money", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "number"}, {"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "Choose a friendly order title is helpful for pay", "ja_JP": "Choose a friendly order title is helpful for pay", "pt_BR": "Choose a friendly order title is helpful for pay", "zh_Hans": "\\u9009\\u62e9\\u4e00\\u4e2a\\u53cb\\u597d\\u7684\\u8ba2\\u5355\\u6807\\u9898\\uff0c\\u7528\\u6237\\u66f4\\u5bb9\\u6613\\u4ed8\\u6b3e"}, "label": {"en_US": "Order Title", "ja_JP": "Order Title", "pt_BR": "Order Title", "zh_Hans": "\\u8ba2\\u5355\\u6807\\u9898"}, "llm_description": "", "max": null, "min": null, "name": "title", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "The order's description", "ja_JP": "The order's description", "pt_BR": "The order's description", "zh_Hans": "\\u8ba2\\u5355\\u7684\\u8be6\\u7ec6\\u4fe1\\u606f\\u63cf\\u8ff0"}, "label": {"en_US": "Order Description", "ja_JP": "Order Description", "pt_BR": "Order Description", "zh_Hans": "\\u8ba2\\u5355\\u63cf\\u8ff0"}, "llm_description": "", "max": null, "min": null, "name": "desc", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}], "params": {"desc": "", "money": "", "title": ""}, "provider_id": "hjlarry/small_pay/small_pay", "provider_name": "hjlarry/small_pay/small_pay", "provider_type": "builtin", "selected": false, "title": "\\u521b\\u5efa\\u8ba2\\u5355", "tool_configurations": {"desc": {"type": "constant", "value": "\\u5c0f\\u7070\\u7070-\\u6587\\u751f\\u89c6\\u9891\\u8ba2\\u5355\\u4ea7\\u751f\\u8d39\\u7528"}, "title": {"type": "constant", "value": "\\u5c0f\\u7070\\u7070-\\u6587\\u751f\\u89c6\\u9891\\u8ba2\\u5355"}}, "tool_description": "\\u4f7f\\u7528\\u6b64\\u5de5\\u5177\\u521b\\u5efa\\u8ba2\\u5355\\u5e76\\u83b7\\u53d6\\u652f\\u4ed8\\u4e8c\\u7ef4\\u7801", "tool_label": "\\u521b\\u5efa\\u8ba2\\u5355", "tool_name": "create_order", "tool_parameters": {"money": {"type": "constant", "value": 1}}, "type": "tool", "tool_node_version": "2"}, "height": 115, "id": "1749880213564", "position": {"x": 1037.4252645253553, "y": 577.6468952776535}, "positionAbsolute": {"x": 1037.4252645253553, "y": 577.6468952776535}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "\\u8bf7\\u4f7f\\u7528\\u5fae\\u4fe1\\u626b\\u63cf\\u4ee5\\u4e0b\\u4e8c\\u7ef4\\u7801\\uff0c\\u5e76\\u57282\\u5206\\u949f\\u5185\\u5b8c\\u6210\\u652f\\u4ed8\\uff0c\\u652f\\u4ed8\\u6210\\u529f\\u540e\\u5373\\u53ef\\u5f00\\u59cb\\u5bf9\\u8bdd\\u3002\\n\\n{{#1749880213564.files#}}", "desc": "", "selected": false, "title": "\\u521b\\u5efa\\u652f\\u4ed8\\u8ba2\\u5355\\u56de\\u590d", "type": "answer", "variables": []}, "height": 136, "id": "1749880285917", "position": {"x": 1340.940981106895, "y": 572.5810537170545}, "positionAbsolute": {"x": 1340.940981106895, "y": 572.5810537170545}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "Optional. If not filled, it will try to query the order number according to the conversation ID.", "ja_JP": "Optional. If not filled, it will try to query the order number according to the conversation ID.", "pt_BR": "Optional. If not filled, it will try to query the order number according to the conversation ID.", "zh_Hans": "\\u9009\\u586b\\u3002\\u5982\\u679c\\u4e0d\\u586b\\u5199\\uff0c\\u5219\\u4f1a\\u5c1d\\u8bd5\\u6839\\u636e\\u4f1a\\u8bddID\\u67e5\\u8be2\\u8ba2\\u5355\\u53f7\\u3002"}, "label": {"en_US": "Order Number", "ja_JP": "Order Number", "pt_BR": "Order Number", "zh_Hans": "\\u8ba2\\u5355\\u53f7"}, "llm_description": "", "max": null, "min": null, "name": "order_no", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}], "params": {"order_no": ""}, "provider_id": "hjlarry/small_pay/small_pay", "provider_name": "hjlarry/small_pay/small_pay", "provider_type": "builtin", "selected": false, "title": "\\u67e5\\u8be2\\u8ba2\\u5355", "tool_configurations": {}, "tool_description": "\\u4f7f\\u7528\\u6b64\\u5de5\\u5177\\u67e5\\u8be2\\u8ba2\\u5355\\u72b6\\u6001", "tool_label": "\\u67e5\\u8be2\\u8ba2\\u5355", "tool_name": "query_order", "tool_parameters": {"order_no": {"type": "mixed", "value": "{{#1749880213564.text#}}"}}, "type": "tool", "tool_node_version": "2"}, "height": 53, "id": "1749880352819", "position": {"x": 1642.940981106895, "y": 572.5810537170545}, "positionAbsolute": {"x": 1642.940981106895, "y": 572.5810537170545}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"cases": [{"case_id": "true", "conditions": [{"comparison_operator": "contains", "id": "1f8e45f9-08f3-4540-9ce4-a7d279bc7b2b", "value": "\\u652f\\u4ed8\\u6210\\u529f", "varType": "string", "variable_selector": ["1749880352819", "text"]}], "id": "true", "logical_operator": "and"}], "desc": "", "selected": false, "title": "\\u5224\\u65ad\\u652f\\u4ed8\\u6210\\u529f", "type": "if-else"}, "height": 125, "id": "1749880389568", "position": {"x": 1970.4113420158774, "y": 585.0896999946543}, "positionAbsolute": {"x": 1970.4113420158774, "y": 585.0896999946543}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "items": [{"input_type": "constant", "operation": "set", "value": 1, "variable_selector": ["conversation", "paycount"], "write_mode": "over-write"}], "selected": false, "title": "\\u53d8\\u91cf\\u8d4b\\u503c", "type": "assigner", "version": "2"}, "height": 87, "id": "1749880449416", "position": {"x": 2287.810357643813, "y": 612.6263919355151}, "positionAbsolute": {"x": 2287.810357643813, "y": 612.6263919355151}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "\\u652f\\u4ed8\\u6210\\u529f\\uff0c\\u672c\\u6b21\\u4ed8\\u6b3e\\u53ef\\u4ee5\\u8fdb\\u884c1\\u6b21\\u6587\\u751f\\u89c6\\u9891\\uff0c\\u5c3d\\u60c5\\u7684\\u4f7f\\u7528\\u5427\\uff01", "desc": "", "selected": false, "title": "\\u652f\\u4ed8\\u6210\\u529f", "type": "answer", "variables": []}, "height": 117, "id": "1749880508134", "position": {"x": 2586.242790537326, "y": 607.9612269084447}, "positionAbsolute": {"x": 2586.242790537326, "y": 607.9612269084447}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"cases": [{"case_id": "true", "conditions": [{"comparison_operator": "=", "id": "95c87a03-0a2c-4bfa-8b41-293337983386", "value": "0", "varType": "number", "variable_selector": ["conversation", "paycount"]}], "id": "true", "logical_operator": "and"}], "desc": "", "selected": false, "title": "\\u56fe\\u751f\\u89c6\\u9891\\u6761\\u4ef6\\u5224\\u65ad", "type": "if-else"}, "height": 125, "id": "1749880623831", "position": {"x": 681.675550216476, "y": 572.5810537170545}, "positionAbsolute": {"x": 681.675550216476, "y": 572.5810537170545}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "items": [{"input_type": "variable", "operation": "over-write", "value": ["1749884771528", "result"], "variable_selector": ["conversation", "paycount"], "write_mode": "over-write"}], "selected": true, "title": "\\u53d8\\u91cf\\u8d4b\\u503c\\u6587\\u751f\\u89c6\\u9891", "type": "assigner", "version": "2"}, "height": 87, "id": "1749883667850", "position": {"x": 1739.1359149708092, "y": 487.4286818510247}, "positionAbsolute": {"x": 1739.1359149708092, "y": 487.4286818510247}, "selected": true, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"code": "def main(arg1: str) -> dict:\\n    return {\\n        \\"result\\": int(arg1) - 1,\\n    }", "code_language": "python3", "desc": "", "outputs": {"result": {"children": null, "type": "number"}}, "selected": false, "title": "\\u6587\\u751f\\u89c6\\u9891\\u4ee3\\u7801\\u6267\\u884c", "type": "code", "variables": [{"value_selector": ["conversation", "paycount"], "variable": "arg1"}]}, "height": 53, "id": "1749884771528", "position": {"x": 1436.2829464623849, "y": 482.4268631360997}, "positionAbsolute": {"x": 1436.2829464623849, "y": 482.4268631360997}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"code": "def main(arg1: str) -> dict:\\n    return {\\n        \\"result\\": int(arg1) - 1,\\n    }", "code_language": "python3", "desc": "", "outputs": {"result": {"children": null, "type": "number"}}, "selected": false, "title": "\\u56fe\\u751f\\u89c6\\u9891\\u4ee3\\u7801\\u6267\\u884c", "type": "code", "variables": [{"value_selector": ["conversation", "paycount"], "variable": "arg1"}]}, "height": 53, "id": "1749884821786", "position": {"x": 1436.2829464623849, "y": 893.6934268294548}, "positionAbsolute": {"x": 1436.2829464623849, "y": 893.6934268294548}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "items": [{"input_type": "variable", "operation": "over-write", "value": ["1749884821786", "result"], "variable_selector": ["conversation", "paycount"], "write_mode": "over-write"}], "selected": false, "title": "\\u53d8\\u91cf\\u8d4b\\u503c 3", "type": "assigner", "version": "2"}, "height": 87, "id": "1749884892364", "position": {"x": 1738.2829464623849, "y": 893.6934268294548}, "positionAbsolute": {"x": 1738.2829464623849, "y": 893.6934268294548}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"cases": [{"case_id": "true", "conditions": [{"comparison_operator": ">", "id": "33a9fb21-28ed-4f06-bf33-204fdab9a50d", "value": "0", "varType": "number", "variable_selector": ["conversation", "paycount"]}], "id": "true", "logical_operator": "and"}], "desc": "", "selected": false, "title": "\\u6587\\u751f\\u89c6\\u9891\\u6761\\u4ef6\\u5224\\u65ad", "type": "if-else"}, "height": 125, "id": "1749885007254", "position": {"x": 690, "y": 399.4882253746906}, "positionAbsolute": {"x": 690, "y": 399.4882253746906}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}], "edges": [{"data": {"isInIteration": false, "isInLoop": false, "sourceType": "start", "targetType": "if-else"}, "id": "1748874215740-source-1748876787141-target", "source": "1748874215740", "sourceHandle": "source", "target": "1748876787141", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "if-else", "targetType": "answer"}, "id": "1748876787141-false-1748877833989-target", "source": "1748876787141", "sourceHandle": "false", "target": "1748877833989", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "if-else", "targetType": "agent"}, "id": "1748876787141-true-1749805551292-target", "source": "1748876787141", "sourceHandle": "true", "target": "1749805551292", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "agent", "targetType": "answer"}, "id": "1749805551292-source-answer-target", "source": "1749805551292", "sourceHandle": "source", "target": "answer", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "agent", "targetType": "answer"}, "id": "17498061130260-source-17498062846900-target", "source": "17498061130260", "sourceHandle": "source", "target": "17498062846900", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "agent", "targetType": "answer"}, "id": "17498064656760-source-1748879492779-target", "source": "17498064656760", "sourceHandle": "source", "target": "1748879492779", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "tool", "targetType": "answer"}, "id": "1749880213564-source-1749880285917-target", "source": "1749880213564", "sourceHandle": "source", "target": "1749880285917", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "answer", "targetType": "tool"}, "id": "1749880285917-source-1749880352819-target", "source": "1749880285917", "sourceHandle": "source", "target": "1749880352819", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "tool", "targetType": "if-else"}, "id": "1749880352819-source-1749880389568-target", "source": "1749880352819", "sourceHandle": "source", "target": "1749880389568", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "if-else", "targetType": "assigner"}, "id": "1749880389568-true-1749880449416-target", "source": "1749880389568", "sourceHandle": "true", "target": "1749880449416", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "assigner", "targetType": "answer"}, "id": "1749880449416-source-1749880508134-target", "source": "1749880449416", "sourceHandle": "source", "target": "1749880508134", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "if-else", "targetType": "if-else"}, "id": "1748876787141-53fef812-a8d0-4986-b4ad-94d8b614ed05-1749880623831-target", "source": "1748876787141", "sourceHandle": "53fef812-a8d0-4986-b4ad-94d8b614ed05", "target": "1749880623831", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "if-else", "targetType": "tool"}, "id": "1749880623831-true-1749880213564-target", "source": "1749880623831", "sourceHandle": "true", "target": "1749880213564", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "if-else", "targetType": "agent"}, "id": "1749880623831-false-17498064656760-target", "source": "1749880623831", "sourceHandle": "false", "target": "17498064656760", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "agent", "targetType": "code"}, "id": "17498061130260-source-1749884771528-target", "source": "17498061130260", "sourceHandle": "source", "target": "1749884771528", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "code", "targetType": "assigner"}, "id": "1749884771528-source-1749883667850-target", "source": "1749884771528", "sourceHandle": "source", "target": "1749883667850", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "agent", "targetType": "code"}, "id": "17498064656760-source-1749884821786-target", "source": "17498064656760", "sourceHandle": "source", "target": "1749884821786", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "code", "targetType": "assigner"}, "id": "1749884821786-source-1749884892364-target", "source": "1749884821786", "sourceHandle": "source", "target": "1749884892364", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "if-else", "targetType": "if-else"}, "id": "1748876787141-9c31fe18-ce4d-4618-a3ec-1e166f773645-1749885007254-target", "source": "1748876787141", "sourceHandle": "9c31fe18-ce4d-4618-a3ec-1e166f773645", "target": "1749885007254", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "if-else", "targetType": "agent"}, "id": "1749885007254-true-17498061130260-target", "source": "1749885007254", "sourceHandle": "true", "target": "17498061130260", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "if-else", "targetType": "tool"}, "id": "1749885007254-false-1749880213564-target", "source": "1749885007254", "sourceHandle": "false", "target": "1749880213564", "targetHandle": "target", "type": "custom", "zIndex": 0}], "viewport": {"x": -169.32453413890528, "y": -118.35144319938377, "zoom": 0.7071067706695181}}	{"opening_statement": "", "suggested_questions": [], "suggested_questions_after_answer": {"enabled": false}, "text_to_speech": {"enabled": false, "language": "", "voice": ""}, "speech_to_text": {"enabled": false}, "retriever_resource": {"enabled": true}, "sensitive_word_avoidance": {"enabled": false}, "file_upload": {"image": {"enabled": false, "number_limits": 3, "transfer_methods": ["local_file", "remote_url"]}, "enabled": false, "allowed_file_types": ["image"], "allowed_file_extensions": [".JPG", ".JPEG", ".PNG", ".GIF", ".WEBP", ".SVG"], "allowed_file_upload_methods": ["local_file", "remote_url"], "number_limits": 3, "fileUploadConfig": {"file_size_limit": 15, "batch_count_limit": 5, "image_file_size_limit": 10, "video_file_size_limit": 100, "audio_file_size_limit": 50, "workflow_file_upload_limit": 10}}}	6cc88c13-1664-485f-a09f-30e14b5c0df8	2025-07-26 07:34:47	6cc88c13-1664-485f-a09f-30e14b5c0df8	2025-07-26 07:35:04.667149	{}	{"paycount": {"value_type": "integer", "value": 0, "id": "4395ca63-af9c-4b80-9b1f-3a73348f8559", "name": "paycount", "description": "默认支付成功后可以拥有三次文生视频、图片视频调用", "selector": ["conversation", "paycount"]}}		
0feb5ed2-2791-4b70-9ce0-f78e97721afa	1f6f5922-bac4-41b9-b009-db0d00769fe5	a164793c-660a-45b9-9739-b7500c441f39	chat	draft	{"nodes": [{"data": {"desc": "", "selected": false, "title": "\\u5f00\\u59cb", "type": "start", "variables": [{"label": "\\u70ed\\u70b9\\u65b0\\u95fb\\u7c7b\\u578b", "max_length": 48, "options": ["\\u6398\\u91d1", "bilibili", "ac_fun", "\\u5fae\\u535a", "\\u4eca\\u65e5\\u5934\\u6761", "36kr", "\\u864e\\u55c5", "hellogithub"], "required": true, "type": "select", "variable": "type"}]}, "height": 89, "id": "1749448556847", "position": {"x": -342, "y": 282}, "positionAbsolute": {"x": -342, "y": 282}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "{{#1749448556847.type#}}\\u70ed\\u699c\\u65b0\\u95fb {{#1749458610637.text#}}\\n {{#1749453881785.text#}}", "desc": "", "selected": false, "title": "\\u76f4\\u63a5\\u56de\\u590d", "type": "answer", "variables": []}, "height": 142, "id": "answer", "position": {"x": 2011.3290917739064, "y": 346.47265570470717}, "positionAbsolute": {"x": 2011.3290917739064, "y": 346.47265570470717}, "selected": true, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"context": {"enabled": false, "variable_selector": []}, "desc": "", "model": {"completion_params": {}, "mode": "chat", "name": "deepseek-v3", "provider": "langgenius/tongyi/tongyi"}, "prompt_template": [{"id": "f2978539-e311-4ba9-ae7e-b17ea6374d60", "role": "system", "text": " \\u8bf7\\u5c06\\u8f93\\u51fa\\u7684\\u8868\\u683c{{#1749458027152.output#}}\\u8f6c\\u6362\\u6210markdown\\u8868\\u683c\\u8f93\\u51fa"}], "selected": false, "title": "\\u6570\\u7ec4\\u8f6cmarkdown(LLM)", "type": "llm", "variables": [], "vision": {"enabled": false}}, "height": 95, "id": "1749453881785", "position": {"x": 1568.866746752858, "y": 346.47265570470717}, "positionAbsolute": {"x": 1568.866746752858, "y": 346.47265570470717}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"cases": [{"case_id": "true", "conditions": [{"comparison_operator": "contains", "id": "94267d30-86a7-4019-bf62-ca5f35cfae19", "value": "\\u6398\\u91d1", "varType": "string", "variable_selector": ["1749448556847", "type"]}], "id": "true", "logical_operator": "and"}, {"case_id": "c3da012a-61fe-47e0-ac59-d9000214fce4", "conditions": [{"comparison_operator": "contains", "id": "7886cf2c-ca71-44e7-ae12-6dbb1dd38bc5", "value": "bilibili", "varType": "string", "variable_selector": ["1749448556847", "type"]}], "id": "c3da012a-61fe-47e0-ac59-d9000214fce4", "logical_operator": "and"}, {"case_id": "c6502d14-7f11-4fcc-828e-2464e781c46b", "conditions": [{"comparison_operator": "contains", "id": "5af582fd-7161-4131-8960-3928b2cdd779", "value": "ac_fun", "varType": "string", "variable_selector": ["1749448556847", "type"]}], "id": "c6502d14-7f11-4fcc-828e-2464e781c46b", "logical_operator": "and"}, {"case_id": "fa2cfbd7-22c4-4a9e-86e3-9098a5ceb4d5", "conditions": [{"comparison_operator": "contains", "id": "a5fd5aae-9524-421c-86a0-0e6d3bee65ea", "value": "\\u5fae\\u535a", "varType": "string", "variable_selector": ["1749448556847", "type"]}], "id": "fa2cfbd7-22c4-4a9e-86e3-9098a5ceb4d5", "logical_operator": "and"}, {"case_id": "b4b16364-46f1-4f64-afe5-934f8351dfd9", "conditions": [{"comparison_operator": "contains", "id": "203f0cf9-2b41-44c6-9e11-00ef2ebad0b0", "value": "\\u4eca\\u65e5\\u5934\\u6761", "varType": "string", "variable_selector": ["1749448556847", "type"]}], "id": "b4b16364-46f1-4f64-afe5-934f8351dfd9", "logical_operator": "and"}, {"case_id": "ac8bfbbe-b163-45ae-97fe-dfbd616c16f6", "conditions": [{"comparison_operator": "contains", "id": "5315ebec-198f-4043-a61d-b359ef5c137a", "value": "36kr", "varType": "string", "variable_selector": ["1749448556847", "type"]}], "id": "ac8bfbbe-b163-45ae-97fe-dfbd616c16f6", "logical_operator": "and"}, {"case_id": "8f174eff-98a3-4d0d-858a-232c07d80874", "conditions": [{"comparison_operator": "contains", "id": "b6be9beb-3526-4f08-926a-ebccdf7534e0", "value": "\\u864e\\u55c5", "varType": "string", "variable_selector": ["1749448556847", "type"]}], "id": "8f174eff-98a3-4d0d-858a-232c07d80874", "logical_operator": "and"}, {"case_id": "9dd0dadf-3897-451a-97cf-8254045a981d", "conditions": [{"comparison_operator": "contains", "id": "01e5542c-d3c6-4c73-8d84-c27255e6646c", "value": "hellogithub", "varType": "string", "variable_selector": ["1749448556847", "type"]}], "id": "9dd0dadf-3897-451a-97cf-8254045a981d", "logical_operator": "and"}], "desc": "", "selected": false, "title": "\\u6761\\u4ef6\\u5206\\u652f", "type": "if-else"}, "height": 461, "id": "1749456497750", "position": {"x": 38, "y": 184.58578644493042}, "positionAbsolute": {"x": 38, "y": 184.58578644493042}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "platform name", "ja_JP": "platform name", "pt_BR": "platform name", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "label": {"en_US": "platform", "ja_JP": "platform", "pt_BR": "platform", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "llm_description": "\\u5e73\\u53f0\\u540d\\u79f0", "max": null, "min": null, "name": "platform", "options": [{"label": {"en_US": "zhihu", "ja_JP": "zhihu", "pt_BR": "zhihu", "zh_Hans": "\\u77e5\\u4e4e"}, "value": "zhihu"}, {"label": {"en_US": "juejin", "ja_JP": "juejin", "pt_BR": "juejin", "zh_Hans": "\\u6398\\u91d1"}, "value": "juejin"}, {"label": {"en_US": "bilibili", "ja_JP": "bilibili", "pt_BR": "bilibili", "zh_Hans": "bilibili"}, "value": "bilibili"}, {"label": {"en_US": "ac_fun", "ja_JP": "ac_fun", "pt_BR": "ac_fun", "zh_Hans": "ac_fun"}, "value": "acfun"}, {"label": {"en_US": "weibo", "ja_JP": "weibo", "pt_BR": "weibo", "zh_Hans": "\\u5fae\\u535a"}, "value": "weibo"}, {"label": {"en_US": "toutiao", "ja_JP": "toutiao", "pt_BR": "toutiao", "zh_Hans": "\\u4eca\\u65e5\\u5934\\u6761"}, "value": "toutiao"}, {"label": {"en_US": "36kr", "ja_JP": "36kr", "pt_BR": "36kr", "zh_Hans": "36kr"}, "value": "36kr"}, {"label": {"en_US": "huxiu", "ja_JP": "huxiu", "pt_BR": "huxiu", "zh_Hans": "\\u864e\\u55c5"}, "value": "huxiu"}, {"label": {"en_US": "hellogithub", "ja_JP": "hellogithub", "pt_BR": "hellogithub", "zh_Hans": "hellogithub"}, "value": "hellogithub"}], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "label": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "llm_description": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf", "max": 10, "min": 1, "name": "result_num", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "number"}], "params": {"platform": "", "result_num": ""}, "provider_id": "jaguarliuu/rookie_rss/rookie_rss", "provider_name": "jaguarliuu/rookie_rss/rookie_rss", "provider_type": "builtin", "selected": false, "title": "\\u6398\\u91d1", "tool_configurations": {"platform": {"type": "constant", "value": "juejin"}, "result_num": {"type": "constant", "value": 5}}, "tool_description": "rookie rss \\u591a\\u5e73\\u53f0\\u65b0\\u95fb\\u805a\\u5408\\u63d2\\u4ef6", "tool_label": "rookie_rss", "tool_name": "rookie_rss", "tool_parameters": {}, "type": "tool", "tool_node_version": "2"}, "height": 115, "id": "17494569389000", "position": {"x": 390, "y": -30.99609375}, "positionAbsolute": {"x": 390, "y": -30.99609375}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "platform name", "ja_JP": "platform name", "pt_BR": "platform name", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "label": {"en_US": "platform", "ja_JP": "platform", "pt_BR": "platform", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "llm_description": "\\u5e73\\u53f0\\u540d\\u79f0", "max": null, "min": null, "name": "platform", "options": [{"label": {"en_US": "zhihu", "ja_JP": "zhihu", "pt_BR": "zhihu", "zh_Hans": "\\u77e5\\u4e4e"}, "value": "zhihu"}, {"label": {"en_US": "juejin", "ja_JP": "juejin", "pt_BR": "juejin", "zh_Hans": "\\u6398\\u91d1"}, "value": "juejin"}, {"label": {"en_US": "bilibili", "ja_JP": "bilibili", "pt_BR": "bilibili", "zh_Hans": "bilibili"}, "value": "bilibili"}, {"label": {"en_US": "ac_fun", "ja_JP": "ac_fun", "pt_BR": "ac_fun", "zh_Hans": "ac_fun"}, "value": "acfun"}, {"label": {"en_US": "weibo", "ja_JP": "weibo", "pt_BR": "weibo", "zh_Hans": "\\u5fae\\u535a"}, "value": "weibo"}, {"label": {"en_US": "toutiao", "ja_JP": "toutiao", "pt_BR": "toutiao", "zh_Hans": "\\u4eca\\u65e5\\u5934\\u6761"}, "value": "toutiao"}, {"label": {"en_US": "36kr", "ja_JP": "36kr", "pt_BR": "36kr", "zh_Hans": "36kr"}, "value": "36kr"}, {"label": {"en_US": "huxiu", "ja_JP": "huxiu", "pt_BR": "huxiu", "zh_Hans": "\\u864e\\u55c5"}, "value": "huxiu"}, {"label": {"en_US": "hellogithub", "ja_JP": "hellogithub", "pt_BR": "hellogithub", "zh_Hans": "hellogithub"}, "value": "hellogithub"}], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "label": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "llm_description": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf", "max": 10, "min": 1, "name": "result_num", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "number"}], "params": {"platform": "", "result_num": ""}, "provider_id": "jaguarliuu/rookie_rss/rookie_rss", "provider_name": "jaguarliuu/rookie_rss/rookie_rss", "provider_type": "builtin", "selected": false, "title": "bilibili", "tool_configurations": {"platform": {"type": "constant", "value": "bilibili"}, "result_num": {"type": "constant", "value": 5}}, "tool_description": "rookie rss \\u591a\\u5e73\\u53f0\\u65b0\\u95fb\\u805a\\u5408\\u63d2\\u4ef6", "tool_label": "rookie_rss", "tool_name": "rookie_rss", "tool_parameters": {}, "type": "tool", "tool_node_version": "2"}, "height": 115, "id": "17494569627420", "position": {"x": 390, "y": 98.00390625}, "positionAbsolute": {"x": 390, "y": 98.00390625}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "platform name", "ja_JP": "platform name", "pt_BR": "platform name", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "label": {"en_US": "platform", "ja_JP": "platform", "pt_BR": "platform", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "llm_description": "\\u5e73\\u53f0\\u540d\\u79f0", "max": null, "min": null, "name": "platform", "options": [{"label": {"en_US": "zhihu", "ja_JP": "zhihu", "pt_BR": "zhihu", "zh_Hans": "\\u77e5\\u4e4e"}, "value": "zhihu"}, {"label": {"en_US": "juejin", "ja_JP": "juejin", "pt_BR": "juejin", "zh_Hans": "\\u6398\\u91d1"}, "value": "juejin"}, {"label": {"en_US": "bilibili", "ja_JP": "bilibili", "pt_BR": "bilibili", "zh_Hans": "bilibili"}, "value": "bilibili"}, {"label": {"en_US": "ac_fun", "ja_JP": "ac_fun", "pt_BR": "ac_fun", "zh_Hans": "ac_fun"}, "value": "acfun"}, {"label": {"en_US": "weibo", "ja_JP": "weibo", "pt_BR": "weibo", "zh_Hans": "\\u5fae\\u535a"}, "value": "weibo"}, {"label": {"en_US": "toutiao", "ja_JP": "toutiao", "pt_BR": "toutiao", "zh_Hans": "\\u4eca\\u65e5\\u5934\\u6761"}, "value": "toutiao"}, {"label": {"en_US": "36kr", "ja_JP": "36kr", "pt_BR": "36kr", "zh_Hans": "36kr"}, "value": "36kr"}, {"label": {"en_US": "huxiu", "ja_JP": "huxiu", "pt_BR": "huxiu", "zh_Hans": "\\u864e\\u55c5"}, "value": "huxiu"}, {"label": {"en_US": "hellogithub", "ja_JP": "hellogithub", "pt_BR": "hellogithub", "zh_Hans": "hellogithub"}, "value": "hellogithub"}], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "label": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "llm_description": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf", "max": 10, "min": 1, "name": "result_num", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "number"}], "params": {"platform": "", "result_num": ""}, "provider_id": "jaguarliuu/rookie_rss/rookie_rss", "provider_name": "jaguarliuu/rookie_rss/rookie_rss", "provider_type": "builtin", "selected": false, "title": "ac_fun", "tool_configurations": {"platform": {"type": "constant", "value": "acfun"}, "result_num": {"type": "constant", "value": 5}}, "tool_description": "rookie rss \\u591a\\u5e73\\u53f0\\u65b0\\u95fb\\u805a\\u5408\\u63d2\\u4ef6", "tool_label": "rookie_rss", "tool_name": "rookie_rss", "tool_parameters": {}, "type": "tool", "tool_node_version": "2"}, "height": 115, "id": "17494569748970", "position": {"x": 390, "y": 219.00390625}, "positionAbsolute": {"x": 390, "y": 219.00390625}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "platform name", "ja_JP": "platform name", "pt_BR": "platform name", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "label": {"en_US": "platform", "ja_JP": "platform", "pt_BR": "platform", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "llm_description": "\\u5e73\\u53f0\\u540d\\u79f0", "max": null, "min": null, "name": "platform", "options": [{"label": {"en_US": "zhihu", "ja_JP": "zhihu", "pt_BR": "zhihu", "zh_Hans": "\\u77e5\\u4e4e"}, "value": "zhihu"}, {"label": {"en_US": "juejin", "ja_JP": "juejin", "pt_BR": "juejin", "zh_Hans": "\\u6398\\u91d1"}, "value": "juejin"}, {"label": {"en_US": "bilibili", "ja_JP": "bilibili", "pt_BR": "bilibili", "zh_Hans": "bilibili"}, "value": "bilibili"}, {"label": {"en_US": "ac_fun", "ja_JP": "ac_fun", "pt_BR": "ac_fun", "zh_Hans": "ac_fun"}, "value": "acfun"}, {"label": {"en_US": "weibo", "ja_JP": "weibo", "pt_BR": "weibo", "zh_Hans": "\\u5fae\\u535a"}, "value": "weibo"}, {"label": {"en_US": "toutiao", "ja_JP": "toutiao", "pt_BR": "toutiao", "zh_Hans": "\\u4eca\\u65e5\\u5934\\u6761"}, "value": "toutiao"}, {"label": {"en_US": "36kr", "ja_JP": "36kr", "pt_BR": "36kr", "zh_Hans": "36kr"}, "value": "36kr"}, {"label": {"en_US": "huxiu", "ja_JP": "huxiu", "pt_BR": "huxiu", "zh_Hans": "\\u864e\\u55c5"}, "value": "huxiu"}, {"label": {"en_US": "hellogithub", "ja_JP": "hellogithub", "pt_BR": "hellogithub", "zh_Hans": "hellogithub"}, "value": "hellogithub"}], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "label": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "llm_description": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf", "max": 10, "min": 1, "name": "result_num", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "number"}], "params": {"platform": "", "result_num": ""}, "provider_id": "jaguarliuu/rookie_rss/rookie_rss", "provider_name": "jaguarliuu/rookie_rss/rookie_rss", "provider_type": "builtin", "selected": false, "title": "\\u5fae\\u535a", "tool_configurations": {"platform": {"type": "constant", "value": "weibo"}, "result_num": {"type": "constant", "value": 5}}, "tool_description": "rookie rss \\u591a\\u5e73\\u53f0\\u65b0\\u95fb\\u805a\\u5408\\u63d2\\u4ef6", "tool_label": "rookie_rss", "tool_name": "rookie_rss", "tool_parameters": {}, "type": "tool", "tool_node_version": "2"}, "height": 115, "id": "17494569871550", "position": {"x": 390, "y": 360.00390625}, "positionAbsolute": {"x": 390, "y": 360.00390625}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "platform name", "ja_JP": "platform name", "pt_BR": "platform name", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "label": {"en_US": "platform", "ja_JP": "platform", "pt_BR": "platform", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "llm_description": "\\u5e73\\u53f0\\u540d\\u79f0", "max": null, "min": null, "name": "platform", "options": [{"label": {"en_US": "zhihu", "ja_JP": "zhihu", "pt_BR": "zhihu", "zh_Hans": "\\u77e5\\u4e4e"}, "value": "zhihu"}, {"label": {"en_US": "juejin", "ja_JP": "juejin", "pt_BR": "juejin", "zh_Hans": "\\u6398\\u91d1"}, "value": "juejin"}, {"label": {"en_US": "bilibili", "ja_JP": "bilibili", "pt_BR": "bilibili", "zh_Hans": "bilibili"}, "value": "bilibili"}, {"label": {"en_US": "ac_fun", "ja_JP": "ac_fun", "pt_BR": "ac_fun", "zh_Hans": "ac_fun"}, "value": "acfun"}, {"label": {"en_US": "weibo", "ja_JP": "weibo", "pt_BR": "weibo", "zh_Hans": "\\u5fae\\u535a"}, "value": "weibo"}, {"label": {"en_US": "toutiao", "ja_JP": "toutiao", "pt_BR": "toutiao", "zh_Hans": "\\u4eca\\u65e5\\u5934\\u6761"}, "value": "toutiao"}, {"label": {"en_US": "36kr", "ja_JP": "36kr", "pt_BR": "36kr", "zh_Hans": "36kr"}, "value": "36kr"}, {"label": {"en_US": "huxiu", "ja_JP": "huxiu", "pt_BR": "huxiu", "zh_Hans": "\\u864e\\u55c5"}, "value": "huxiu"}, {"label": {"en_US": "hellogithub", "ja_JP": "hellogithub", "pt_BR": "hellogithub", "zh_Hans": "hellogithub"}, "value": "hellogithub"}], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "label": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "llm_description": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf", "max": 10, "min": 1, "name": "result_num", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "number"}], "params": {"platform": "", "result_num": ""}, "provider_id": "jaguarliuu/rookie_rss/rookie_rss", "provider_name": "jaguarliuu/rookie_rss/rookie_rss", "provider_type": "builtin", "selected": false, "title": "\\u864e\\u55c5", "tool_configurations": {"platform": {"type": "constant", "value": "huxiu"}, "result_num": {"type": "constant", "value": 5}}, "tool_description": "rookie rss \\u591a\\u5e73\\u53f0\\u65b0\\u95fb\\u805a\\u5408\\u63d2\\u4ef6", "tool_label": "rookie_rss", "tool_name": "rookie_rss", "tool_parameters": {}, "type": "tool", "tool_node_version": "2"}, "height": 115, "id": "17494569986520", "position": {"x": 376.86475732840813, "y": 769.5215419943555}, "positionAbsolute": {"x": 376.86475732840813, "y": 769.5215419943555}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "platform name", "ja_JP": "platform name", "pt_BR": "platform name", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "label": {"en_US": "platform", "ja_JP": "platform", "pt_BR": "platform", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "llm_description": "\\u5e73\\u53f0\\u540d\\u79f0", "max": null, "min": null, "name": "platform", "options": [{"label": {"en_US": "zhihu", "ja_JP": "zhihu", "pt_BR": "zhihu", "zh_Hans": "\\u77e5\\u4e4e"}, "value": "zhihu"}, {"label": {"en_US": "juejin", "ja_JP": "juejin", "pt_BR": "juejin", "zh_Hans": "\\u6398\\u91d1"}, "value": "juejin"}, {"label": {"en_US": "bilibili", "ja_JP": "bilibili", "pt_BR": "bilibili", "zh_Hans": "bilibili"}, "value": "bilibili"}, {"label": {"en_US": "ac_fun", "ja_JP": "ac_fun", "pt_BR": "ac_fun", "zh_Hans": "ac_fun"}, "value": "acfun"}, {"label": {"en_US": "weibo", "ja_JP": "weibo", "pt_BR": "weibo", "zh_Hans": "\\u5fae\\u535a"}, "value": "weibo"}, {"label": {"en_US": "toutiao", "ja_JP": "toutiao", "pt_BR": "toutiao", "zh_Hans": "\\u4eca\\u65e5\\u5934\\u6761"}, "value": "toutiao"}, {"label": {"en_US": "36kr", "ja_JP": "36kr", "pt_BR": "36kr", "zh_Hans": "36kr"}, "value": "36kr"}, {"label": {"en_US": "huxiu", "ja_JP": "huxiu", "pt_BR": "huxiu", "zh_Hans": "\\u864e\\u55c5"}, "value": "huxiu"}, {"label": {"en_US": "hellogithub", "ja_JP": "hellogithub", "pt_BR": "hellogithub", "zh_Hans": "hellogithub"}, "value": "hellogithub"}], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "label": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "llm_description": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf", "max": 10, "min": 1, "name": "result_num", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "number"}], "params": {"platform": "", "result_num": ""}, "provider_id": "jaguarliuu/rookie_rss/rookie_rss", "provider_name": "jaguarliuu/rookie_rss/rookie_rss", "provider_type": "builtin", "selected": false, "title": "\\u4eca\\u65e5\\u5934\\u6761", "tool_configurations": {"platform": {"type": "constant", "value": "toutiao"}, "result_num": {"type": "constant", "value": 5}}, "tool_description": "rookie rss \\u591a\\u5e73\\u53f0\\u65b0\\u95fb\\u805a\\u5408\\u63d2\\u4ef6", "tool_label": "rookie_rss", "tool_name": "rookie_rss", "tool_parameters": {}, "type": "tool", "tool_node_version": "2"}, "height": 115, "id": "17494570150800", "position": {"x": 384, "y": 490.4882599300943}, "positionAbsolute": {"x": 384, "y": 490.4882599300943}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "platform name", "ja_JP": "platform name", "pt_BR": "platform name", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "label": {"en_US": "platform", "ja_JP": "platform", "pt_BR": "platform", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "llm_description": "\\u5e73\\u53f0\\u540d\\u79f0", "max": null, "min": null, "name": "platform", "options": [{"label": {"en_US": "zhihu", "ja_JP": "zhihu", "pt_BR": "zhihu", "zh_Hans": "\\u77e5\\u4e4e"}, "value": "zhihu"}, {"label": {"en_US": "juejin", "ja_JP": "juejin", "pt_BR": "juejin", "zh_Hans": "\\u6398\\u91d1"}, "value": "juejin"}, {"label": {"en_US": "bilibili", "ja_JP": "bilibili", "pt_BR": "bilibili", "zh_Hans": "bilibili"}, "value": "bilibili"}, {"label": {"en_US": "ac_fun", "ja_JP": "ac_fun", "pt_BR": "ac_fun", "zh_Hans": "ac_fun"}, "value": "acfun"}, {"label": {"en_US": "weibo", "ja_JP": "weibo", "pt_BR": "weibo", "zh_Hans": "\\u5fae\\u535a"}, "value": "weibo"}, {"label": {"en_US": "toutiao", "ja_JP": "toutiao", "pt_BR": "toutiao", "zh_Hans": "\\u4eca\\u65e5\\u5934\\u6761"}, "value": "toutiao"}, {"label": {"en_US": "36kr", "ja_JP": "36kr", "pt_BR": "36kr", "zh_Hans": "36kr"}, "value": "36kr"}, {"label": {"en_US": "huxiu", "ja_JP": "huxiu", "pt_BR": "huxiu", "zh_Hans": "\\u864e\\u55c5"}, "value": "huxiu"}, {"label": {"en_US": "hellogithub", "ja_JP": "hellogithub", "pt_BR": "hellogithub", "zh_Hans": "hellogithub"}, "value": "hellogithub"}], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "label": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "llm_description": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf", "max": 10, "min": 1, "name": "result_num", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "number"}], "params": {"platform": "", "result_num": ""}, "provider_id": "jaguarliuu/rookie_rss/rookie_rss", "provider_name": "jaguarliuu/rookie_rss/rookie_rss", "provider_type": "builtin", "selected": false, "title": "36kr", "tool_configurations": {"platform": {"type": "constant", "value": "36kr"}, "result_num": {"type": "constant", "value": 5}}, "tool_description": "rookie rss \\u591a\\u5e73\\u53f0\\u65b0\\u95fb\\u805a\\u5408\\u63d2\\u4ef6", "tool_label": "rookie_rss", "tool_name": "rookie_rss", "tool_parameters": {}, "type": "tool", "tool_node_version": "2"}, "height": 115, "id": "17494570406760", "position": {"x": 376.86475732840813, "y": 648.326366609074}, "positionAbsolute": {"x": 376.86475732840813, "y": 648.326366609074}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "platform name", "ja_JP": "platform name", "pt_BR": "platform name", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "label": {"en_US": "platform", "ja_JP": "platform", "pt_BR": "platform", "zh_Hans": "\\u5e73\\u53f0\\u540d\\u79f0"}, "llm_description": "\\u5e73\\u53f0\\u540d\\u79f0", "max": null, "min": null, "name": "platform", "options": [{"label": {"en_US": "zhihu", "ja_JP": "zhihu", "pt_BR": "zhihu", "zh_Hans": "\\u77e5\\u4e4e"}, "value": "zhihu"}, {"label": {"en_US": "juejin", "ja_JP": "juejin", "pt_BR": "juejin", "zh_Hans": "\\u6398\\u91d1"}, "value": "juejin"}, {"label": {"en_US": "bilibili", "ja_JP": "bilibili", "pt_BR": "bilibili", "zh_Hans": "bilibili"}, "value": "bilibili"}, {"label": {"en_US": "ac_fun", "ja_JP": "ac_fun", "pt_BR": "ac_fun", "zh_Hans": "ac_fun"}, "value": "acfun"}, {"label": {"en_US": "weibo", "ja_JP": "weibo", "pt_BR": "weibo", "zh_Hans": "\\u5fae\\u535a"}, "value": "weibo"}, {"label": {"en_US": "toutiao", "ja_JP": "toutiao", "pt_BR": "toutiao", "zh_Hans": "\\u4eca\\u65e5\\u5934\\u6761"}, "value": "toutiao"}, {"label": {"en_US": "36kr", "ja_JP": "36kr", "pt_BR": "36kr", "zh_Hans": "36kr"}, "value": "36kr"}, {"label": {"en_US": "huxiu", "ja_JP": "huxiu", "pt_BR": "huxiu", "zh_Hans": "\\u864e\\u55c5"}, "value": "huxiu"}, {"label": {"en_US": "hellogithub", "ja_JP": "hellogithub", "pt_BR": "hellogithub", "zh_Hans": "hellogithub"}, "value": "hellogithub"}], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": null, "form": "form", "human_description": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "label": {"en_US": "result number", "ja_JP": "result number", "pt_BR": "result number", "zh_Hans": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf"}, "llm_description": "\\u8fd4\\u56de\\u7ed3\\u679c\\u6570\\u91cf", "max": 10, "min": 1, "name": "result_num", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "number"}], "params": {"platform": "", "result_num": ""}, "provider_id": "jaguarliuu/rookie_rss/rookie_rss", "provider_name": "jaguarliuu/rookie_rss/rookie_rss", "provider_type": "builtin", "selected": false, "title": "hellogithub", "tool_configurations": {"platform": {"type": "constant", "value": "hellogithub"}, "result_num": {"type": "constant", "value": 5}}, "tool_description": "rookie rss \\u591a\\u5e73\\u53f0\\u65b0\\u95fb\\u805a\\u5408\\u63d2\\u4ef6", "tool_label": "rookie_rss", "tool_name": "rookie_rss", "tool_parameters": {}, "type": "tool", "tool_node_version": "2"}, "height": 115, "id": "17494570570600", "position": {"x": 384, "y": 910.679456466476}, "positionAbsolute": {"x": 384, "y": 910.679456466476}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"code": "import json\\nfrom datetime import datetime, timezone, timedelta\\n\\ndef main(arg1: str) -> dict:\\n    try:\\n        # \\u5982\\u679c\\u5df2\\u7ecf\\u662f dict \\u6216 list\\uff0c\\u76f4\\u63a5\\u7528\\uff0c\\u4e0d\\u518d loads\\n        if isinstance(arg1, (dict, list)):\\n            parsed_data = arg1\\n        else:\\n            parsed_data = json.loads(arg1)\\n        \\n        # \\u540e\\u7eed\\u903b\\u8f91\\u4fdd\\u6301\\u4e0d\\u53d8\\n        if isinstance(parsed_data, dict) and \\"arg1\\" in parsed_data:\\n            data = parsed_data[\\"arg1\\"]\\n        else:\\n            data = parsed_data\\n        \\n        articles = []\\n        if isinstance(data, list):\\n            for item in data:\\n                articles.extend(item.get(\\"articles\\", []))\\n        elif isinstance(data, dict):\\n            articles = data.get(\\"articles\\", [])\\n            \\n        table = []\\n        \\n        # \\u6dfb\\u52a0\\u8868\\u5934\\n        table.append([\\"\\u6807\\u9898\\", \\"\\u70ed\\u95e8\\u8bc4\\u5206\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-\\u624b\\u673a\\u7aef\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-PC\\u7aef\\", \\"\\u66f4\\u65b0\\u65f6\\u95f4\\"])\\n        \\n        for item in articles:\\n            title = item.get('title', '')\\n            hot_score = item.get('hot_score', '')\\n            mobile_link = item.get('links', {}).get('mobile', '')\\n            pc_link = item.get('links', {}).get('pc', '')\\n            update_time_raw = item.get('metadata', {}).get('update_time', '')\\n            \\n            update_time = ''\\n            if update_time_raw:\\n                try:\\n                    # \\u5148\\u5c1d\\u8bd5\\u6309 ISO8601 \\u5e26\\u6beb\\u79d2Z\\u683c\\u5f0f\\u89e3\\u6790\\n                    dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%S.%fZ\\")\\n                    dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                    # \\u8f6c\\u6362\\u4e3a\\u4e0a\\u6d77\\u65f6\\u95f4\\uff08UTC+8\\uff09\\n                    shanghai_tz = timezone(timedelta(hours=8))\\n                    dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                    update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                except Exception:\\n                    try:\\n                        # \\u4e0d\\u5e26\\u6beb\\u79d2\\u7684ISO8601\\u683c\\u5f0f\\n                        dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%SZ\\")\\n                        dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                        shanghai_tz = timezone(timedelta(hours=8))\\n                        dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                        update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                    except Exception:\\n                        try:\\n                            # \\u5982\\u679c\\u662f\\u65f6\\u95f4\\u6233\\uff08\\u79d2\\u7ea7\\u6216\\u6beb\\u79d2\\u7ea7\\uff09\\n                            ts = int(update_time_raw)\\n                            if len(str(update_time_raw)) == 13:\\n                                ts = ts / 1000\\n                            dt = datetime.fromtimestamp(ts, tz=timezone.utc)\\n                            dt_shanghai = dt.astimezone(timezone(timedelta(hours=8)))\\n                            update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                        except Exception:\\n                            # \\u76f4\\u63a5\\u4f7f\\u7528\\u539f\\u59cb\\u5b57\\u7b26\\u4e32\\n                            update_time = str(update_time_raw)\\n            \\n            table.append([title, hot_score, mobile_link, pc_link, update_time])\\n\\n        return {\\n            \\"result\\": str(table).replace(\\"'\\", '\\"')\\n        }\\n    except Exception as e:\\n        return {\\n            \\"result\\": [[\\"\\u9519\\u8bef\\", f\\"{type(e).__name__}: {e}\\"]]\\n        }", "code_language": "python3", "desc": "", "outputs": {"result": {"children": null, "type": "string"}}, "selected": false, "title": "\\u4ee3\\u7801\\u6267\\u884c-\\u6398\\u91d1", "type": "code", "variables": [{"value_selector": ["17494569389000", "json"], "variable": "arg1"}]}, "height": 53, "id": "17494577308300", "position": {"x": 796, "y": -13.01953124999983}, "positionAbsolute": {"x": 796, "y": -13.01953124999983}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"code": "import json\\nfrom datetime import datetime, timezone, timedelta\\n\\ndef main(arg1: str) -> dict:\\n    try:\\n        # \\u5982\\u679c\\u5df2\\u7ecf\\u662f dict \\u6216 list\\uff0c\\u76f4\\u63a5\\u7528\\uff0c\\u4e0d\\u518d loads\\n        if isinstance(arg1, (dict, list)):\\n            parsed_data = arg1\\n        else:\\n            parsed_data = json.loads(arg1)\\n        \\n        # \\u540e\\u7eed\\u903b\\u8f91\\u4fdd\\u6301\\u4e0d\\u53d8\\n        if isinstance(parsed_data, dict) and \\"arg1\\" in parsed_data:\\n            data = parsed_data[\\"arg1\\"]\\n        else:\\n            data = parsed_data\\n        \\n        articles = []\\n        if isinstance(data, list):\\n            for item in data:\\n                articles.extend(item.get(\\"articles\\", []))\\n        elif isinstance(data, dict):\\n            articles = data.get(\\"articles\\", [])\\n            \\n        table = []\\n        \\n        # \\u6dfb\\u52a0\\u8868\\u5934\\n        table.append([\\"\\u6807\\u9898\\", \\"\\u70ed\\u95e8\\u8bc4\\u5206\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-\\u624b\\u673a\\u7aef\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-PC\\u7aef\\", \\"\\u66f4\\u65b0\\u65f6\\u95f4\\"])\\n        \\n        for item in articles:\\n            title = item.get('title', '')\\n            hot_score = item.get('hot_score', '')\\n            mobile_link = item.get('links', {}).get('mobile', '')\\n            pc_link = item.get('links', {}).get('pc', '')\\n            update_time_raw = item.get('metadata', {}).get('update_time', '')\\n            \\n            update_time = ''\\n            if update_time_raw:\\n                try:\\n                    # \\u5148\\u5c1d\\u8bd5\\u6309 ISO8601 \\u5e26\\u6beb\\u79d2Z\\u683c\\u5f0f\\u89e3\\u6790\\n                    dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%S.%fZ\\")\\n                    dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                    # \\u8f6c\\u6362\\u4e3a\\u4e0a\\u6d77\\u65f6\\u95f4\\uff08UTC+8\\uff09\\n                    shanghai_tz = timezone(timedelta(hours=8))\\n                    dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                    update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                except Exception:\\n                    try:\\n                        # \\u4e0d\\u5e26\\u6beb\\u79d2\\u7684ISO8601\\u683c\\u5f0f\\n                        dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%SZ\\")\\n                        dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                        shanghai_tz = timezone(timedelta(hours=8))\\n                        dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                        update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                    except Exception:\\n                        try:\\n                            # \\u5982\\u679c\\u662f\\u65f6\\u95f4\\u6233\\uff08\\u79d2\\u7ea7\\u6216\\u6beb\\u79d2\\u7ea7\\uff09\\n                            ts = int(update_time_raw)\\n                            if len(str(update_time_raw)) == 13:\\n                                ts = ts / 1000\\n                            dt = datetime.fromtimestamp(ts, tz=timezone.utc)\\n                            dt_shanghai = dt.astimezone(timezone(timedelta(hours=8)))\\n                            update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                        except Exception:\\n                            # \\u76f4\\u63a5\\u4f7f\\u7528\\u539f\\u59cb\\u5b57\\u7b26\\u4e32\\n                            update_time = str(update_time_raw)\\n            \\n            table.append([title, hot_score, mobile_link, pc_link, update_time])\\n\\n        return {\\n            \\"result\\": str(table).replace(\\"'\\", '\\"')\\n        }\\n    except Exception as e:\\n        return {\\n            \\"result\\": [[\\"\\u9519\\u8bef\\", f\\"{type(e).__name__}: {e}\\"]]\\n        }", "code_language": "python3", "desc": "", "outputs": {"result": {"children": null, "type": "string"}}, "selected": false, "title": "\\u4ee3\\u7801\\u6267\\u884c-bilibili", "type": "code", "variables": [{"value_selector": ["17494569627420", "json"], "variable": "arg1"}]}, "height": 53, "id": "17494577662390", "position": {"x": 802.00390625, "y": 117.98046875000017}, "positionAbsolute": {"x": 802.00390625, "y": 117.98046875000017}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"code": "import json\\nfrom datetime import datetime, timezone, timedelta\\n\\ndef main(arg1: str) -> dict:\\n    try:\\n        # \\u5982\\u679c\\u5df2\\u7ecf\\u662f dict \\u6216 list\\uff0c\\u76f4\\u63a5\\u7528\\uff0c\\u4e0d\\u518d loads\\n        if isinstance(arg1, (dict, list)):\\n            parsed_data = arg1\\n        else:\\n            parsed_data = json.loads(arg1)\\n        \\n        # \\u540e\\u7eed\\u903b\\u8f91\\u4fdd\\u6301\\u4e0d\\u53d8\\n        if isinstance(parsed_data, dict) and \\"arg1\\" in parsed_data:\\n            data = parsed_data[\\"arg1\\"]\\n        else:\\n            data = parsed_data\\n        \\n        articles = []\\n        if isinstance(data, list):\\n            for item in data:\\n                articles.extend(item.get(\\"articles\\", []))\\n        elif isinstance(data, dict):\\n            articles = data.get(\\"articles\\", [])\\n            \\n        table = []\\n        \\n        # \\u6dfb\\u52a0\\u8868\\u5934\\n        table.append([\\"\\u6807\\u9898\\", \\"\\u70ed\\u95e8\\u8bc4\\u5206\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-\\u624b\\u673a\\u7aef\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-PC\\u7aef\\", \\"\\u66f4\\u65b0\\u65f6\\u95f4\\"])\\n        \\n        for item in articles:\\n            title = item.get('title', '')\\n            hot_score = item.get('hot_score', '')\\n            mobile_link = item.get('links', {}).get('mobile', '')\\n            pc_link = item.get('links', {}).get('pc', '')\\n            update_time_raw = item.get('metadata', {}).get('update_time', '')\\n            \\n            update_time = ''\\n            if update_time_raw:\\n                try:\\n                    # \\u5148\\u5c1d\\u8bd5\\u6309 ISO8601 \\u5e26\\u6beb\\u79d2Z\\u683c\\u5f0f\\u89e3\\u6790\\n                    dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%S.%fZ\\")\\n                    dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                    # \\u8f6c\\u6362\\u4e3a\\u4e0a\\u6d77\\u65f6\\u95f4\\uff08UTC+8\\uff09\\n                    shanghai_tz = timezone(timedelta(hours=8))\\n                    dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                    update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                except Exception:\\n                    try:\\n                        # \\u4e0d\\u5e26\\u6beb\\u79d2\\u7684ISO8601\\u683c\\u5f0f\\n                        dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%SZ\\")\\n                        dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                        shanghai_tz = timezone(timedelta(hours=8))\\n                        dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                        update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                    except Exception:\\n                        try:\\n                            # \\u5982\\u679c\\u662f\\u65f6\\u95f4\\u6233\\uff08\\u79d2\\u7ea7\\u6216\\u6beb\\u79d2\\u7ea7\\uff09\\n                            ts = int(update_time_raw)\\n                            if len(str(update_time_raw)) == 13:\\n                                ts = ts / 1000\\n                            dt = datetime.fromtimestamp(ts, tz=timezone.utc)\\n                            dt_shanghai = dt.astimezone(timezone(timedelta(hours=8)))\\n                            update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                        except Exception:\\n                            # \\u76f4\\u63a5\\u4f7f\\u7528\\u539f\\u59cb\\u5b57\\u7b26\\u4e32\\n                            update_time = str(update_time_raw)\\n            \\n            table.append([title, hot_score, mobile_link, pc_link, update_time])\\n\\n        return {\\n            \\"result\\": str(table).replace(\\"'\\", '\\"')\\n        }\\n    except Exception as e:\\n        return {\\n            \\"result\\": [[\\"\\u9519\\u8bef\\", f\\"{type(e).__name__}: {e}\\"]]\\n        }", "code_language": "python3", "desc": "", "outputs": {"result": {"children": null, "type": "string"}}, "selected": false, "title": "\\u4ee3\\u7801\\u6267\\u884c-ac_fun", "type": "code", "variables": [{"value_selector": ["17494569748970", "json"], "variable": "arg1"}]}, "height": 53, "id": "17494577806740", "position": {"x": 802.00390625, "y": 244.98046875000017}, "positionAbsolute": {"x": 802.00390625, "y": 244.98046875000017}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"code": "import json\\nfrom datetime import datetime, timezone, timedelta\\n\\ndef main(arg1: str) -> dict:\\n    try:\\n        # \\u5982\\u679c\\u5df2\\u7ecf\\u662f dict \\u6216 list\\uff0c\\u76f4\\u63a5\\u7528\\uff0c\\u4e0d\\u518d loads\\n        if isinstance(arg1, (dict, list)):\\n            parsed_data = arg1\\n        else:\\n            parsed_data = json.loads(arg1)\\n        \\n        # \\u540e\\u7eed\\u903b\\u8f91\\u4fdd\\u6301\\u4e0d\\u53d8\\n        if isinstance(parsed_data, dict) and \\"arg1\\" in parsed_data:\\n            data = parsed_data[\\"arg1\\"]\\n        else:\\n            data = parsed_data\\n        \\n        articles = []\\n        if isinstance(data, list):\\n            for item in data:\\n                articles.extend(item.get(\\"articles\\", []))\\n        elif isinstance(data, dict):\\n            articles = data.get(\\"articles\\", [])\\n            \\n        table = []\\n        \\n        # \\u6dfb\\u52a0\\u8868\\u5934\\n        table.append([\\"\\u6807\\u9898\\", \\"\\u70ed\\u95e8\\u8bc4\\u5206\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-\\u624b\\u673a\\u7aef\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-PC\\u7aef\\", \\"\\u66f4\\u65b0\\u65f6\\u95f4\\"])\\n        \\n        for item in articles:\\n            title = item.get('title', '')\\n            hot_score = item.get('hot_score', '')\\n            mobile_link = item.get('links', {}).get('mobile', '')\\n            pc_link = item.get('links', {}).get('pc', '')\\n            update_time_raw = item.get('metadata', {}).get('update_time', '')\\n            \\n            update_time = ''\\n            if update_time_raw:\\n                try:\\n                    # \\u5148\\u5c1d\\u8bd5\\u6309 ISO8601 \\u5e26\\u6beb\\u79d2Z\\u683c\\u5f0f\\u89e3\\u6790\\n                    dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%S.%fZ\\")\\n                    dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                    # \\u8f6c\\u6362\\u4e3a\\u4e0a\\u6d77\\u65f6\\u95f4\\uff08UTC+8\\uff09\\n                    shanghai_tz = timezone(timedelta(hours=8))\\n                    dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                    update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                except Exception:\\n                    try:\\n                        # \\u4e0d\\u5e26\\u6beb\\u79d2\\u7684ISO8601\\u683c\\u5f0f\\n                        dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%SZ\\")\\n                        dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                        shanghai_tz = timezone(timedelta(hours=8))\\n                        dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                        update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                    except Exception:\\n                        try:\\n                            # \\u5982\\u679c\\u662f\\u65f6\\u95f4\\u6233\\uff08\\u79d2\\u7ea7\\u6216\\u6beb\\u79d2\\u7ea7\\uff09\\n                            ts = int(update_time_raw)\\n                            if len(str(update_time_raw)) == 13:\\n                                ts = ts / 1000\\n                            dt = datetime.fromtimestamp(ts, tz=timezone.utc)\\n                            dt_shanghai = dt.astimezone(timezone(timedelta(hours=8)))\\n                            update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                        except Exception:\\n                            # \\u76f4\\u63a5\\u4f7f\\u7528\\u539f\\u59cb\\u5b57\\u7b26\\u4e32\\n                            update_time = str(update_time_raw)\\n            \\n            table.append([title, hot_score, mobile_link, pc_link, update_time])\\n\\n        return {\\n            \\"result\\": str(table).replace(\\"'\\", '\\"')\\n        }\\n    except Exception as e:\\n        return {\\n            \\"result\\": [[\\"\\u9519\\u8bef\\", f\\"{type(e).__name__}: {e}\\"]]\\n        }", "code_language": "python3", "desc": "", "outputs": {"result": {"children": null, "type": "string"}}, "selected": false, "title": "\\u4ee3\\u7801\\u6267\\u884c-\\u5fae\\u535a", "type": "code", "variables": [{"value_selector": ["17494569871550", "json"], "variable": "arg1"}]}, "height": 53, "id": "17494577932030", "position": {"x": 802.00390625, "y": 368.98046875000017}, "positionAbsolute": {"x": 802.00390625, "y": 368.98046875000017}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"code": "import json\\nfrom datetime import datetime, timezone, timedelta\\n\\ndef main(arg1: str) -> dict:\\n    try:\\n        # \\u5982\\u679c\\u5df2\\u7ecf\\u662f dict \\u6216 list\\uff0c\\u76f4\\u63a5\\u7528\\uff0c\\u4e0d\\u518d loads\\n        if isinstance(arg1, (dict, list)):\\n            parsed_data = arg1\\n        else:\\n            parsed_data = json.loads(arg1)\\n        \\n        # \\u540e\\u7eed\\u903b\\u8f91\\u4fdd\\u6301\\u4e0d\\u53d8\\n        if isinstance(parsed_data, dict) and \\"arg1\\" in parsed_data:\\n            data = parsed_data[\\"arg1\\"]\\n        else:\\n            data = parsed_data\\n        \\n        articles = []\\n        if isinstance(data, list):\\n            for item in data:\\n                articles.extend(item.get(\\"articles\\", []))\\n        elif isinstance(data, dict):\\n            articles = data.get(\\"articles\\", [])\\n            \\n        table = []\\n        \\n        # \\u6dfb\\u52a0\\u8868\\u5934\\n        table.append([\\"\\u6807\\u9898\\", \\"\\u70ed\\u95e8\\u8bc4\\u5206\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-\\u624b\\u673a\\u7aef\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-PC\\u7aef\\", \\"\\u66f4\\u65b0\\u65f6\\u95f4\\"])\\n        \\n        for item in articles:\\n            title = item.get('title', '')\\n            hot_score = item.get('hot_score', '')\\n            mobile_link = item.get('links', {}).get('mobile', '')\\n            pc_link = item.get('links', {}).get('pc', '')\\n            update_time_raw = item.get('metadata', {}).get('update_time', '')\\n            \\n            update_time = ''\\n            if update_time_raw:\\n                try:\\n                    # \\u5148\\u5c1d\\u8bd5\\u6309 ISO8601 \\u5e26\\u6beb\\u79d2Z\\u683c\\u5f0f\\u89e3\\u6790\\n                    dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%S.%fZ\\")\\n                    dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                    # \\u8f6c\\u6362\\u4e3a\\u4e0a\\u6d77\\u65f6\\u95f4\\uff08UTC+8\\uff09\\n                    shanghai_tz = timezone(timedelta(hours=8))\\n                    dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                    update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                except Exception:\\n                    try:\\n                        # \\u4e0d\\u5e26\\u6beb\\u79d2\\u7684ISO8601\\u683c\\u5f0f\\n                        dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%SZ\\")\\n                        dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                        shanghai_tz = timezone(timedelta(hours=8))\\n                        dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                        update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                    except Exception:\\n                        try:\\n                            # \\u5982\\u679c\\u662f\\u65f6\\u95f4\\u6233\\uff08\\u79d2\\u7ea7\\u6216\\u6beb\\u79d2\\u7ea7\\uff09\\n                            ts = int(update_time_raw)\\n                            if len(str(update_time_raw)) == 13:\\n                                ts = ts / 1000\\n                            dt = datetime.fromtimestamp(ts, tz=timezone.utc)\\n                            dt_shanghai = dt.astimezone(timezone(timedelta(hours=8)))\\n                            update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                        except Exception:\\n                            # \\u76f4\\u63a5\\u4f7f\\u7528\\u539f\\u59cb\\u5b57\\u7b26\\u4e32\\n                            update_time = str(update_time_raw)\\n            \\n            table.append([title, hot_score, mobile_link, pc_link, update_time])\\n\\n        return {\\n            \\"result\\": str(table).replace(\\"'\\", '\\"')\\n        }\\n    except Exception as e:\\n        return {\\n            \\"result\\": [[\\"\\u9519\\u8bef\\", f\\"{type(e).__name__}: {e}\\"]]\\n        }", "code_language": "python3", "desc": "", "outputs": {"result": {"children": null, "type": "string"}}, "selected": false, "title": "\\u4ee3\\u7801\\u6267\\u884c-\\u864e\\u55c5", "type": "code", "variables": [{"value_selector": ["17494569986520", "json"], "variable": "arg1"}]}, "height": 53, "id": "17494578075360", "position": {"x": 790.1118351306802, "y": 691.6047070920695}, "positionAbsolute": {"x": 790.1118351306802, "y": 691.6047070920695}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"code": "import json\\nfrom datetime import datetime, timezone, timedelta\\n\\ndef main(arg1: str) -> dict:\\n    try:\\n        # \\u5982\\u679c\\u5df2\\u7ecf\\u662f dict \\u6216 list\\uff0c\\u76f4\\u63a5\\u7528\\uff0c\\u4e0d\\u518d loads\\n        if isinstance(arg1, (dict, list)):\\n            parsed_data = arg1\\n        else:\\n            parsed_data = json.loads(arg1)\\n        \\n        # \\u540e\\u7eed\\u903b\\u8f91\\u4fdd\\u6301\\u4e0d\\u53d8\\n        if isinstance(parsed_data, dict) and \\"arg1\\" in parsed_data:\\n            data = parsed_data[\\"arg1\\"]\\n        else:\\n            data = parsed_data\\n        \\n        articles = []\\n        if isinstance(data, list):\\n            for item in data:\\n                articles.extend(item.get(\\"articles\\", []))\\n        elif isinstance(data, dict):\\n            articles = data.get(\\"articles\\", [])\\n            \\n        table = []\\n        \\n        # \\u6dfb\\u52a0\\u8868\\u5934\\n        table.append([\\"\\u6807\\u9898\\", \\"\\u70ed\\u95e8\\u8bc4\\u5206\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-\\u624b\\u673a\\u7aef\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-PC\\u7aef\\", \\"\\u66f4\\u65b0\\u65f6\\u95f4\\"])\\n        \\n        for item in articles:\\n            title = item.get('title', '')\\n            hot_score = item.get('hot_score', '')\\n            mobile_link = item.get('links', {}).get('mobile', '')\\n            pc_link = item.get('links', {}).get('pc', '')\\n            update_time_raw = item.get('metadata', {}).get('update_time', '')\\n            \\n            update_time = ''\\n            if update_time_raw:\\n                try:\\n                    # \\u5148\\u5c1d\\u8bd5\\u6309 ISO8601 \\u5e26\\u6beb\\u79d2Z\\u683c\\u5f0f\\u89e3\\u6790\\n                    dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%S.%fZ\\")\\n                    dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                    # \\u8f6c\\u6362\\u4e3a\\u4e0a\\u6d77\\u65f6\\u95f4\\uff08UTC+8\\uff09\\n                    shanghai_tz = timezone(timedelta(hours=8))\\n                    dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                    update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                except Exception:\\n                    try:\\n                        # \\u4e0d\\u5e26\\u6beb\\u79d2\\u7684ISO8601\\u683c\\u5f0f\\n                        dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%SZ\\")\\n                        dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                        shanghai_tz = timezone(timedelta(hours=8))\\n                        dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                        update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                    except Exception:\\n                        try:\\n                            # \\u5982\\u679c\\u662f\\u65f6\\u95f4\\u6233\\uff08\\u79d2\\u7ea7\\u6216\\u6beb\\u79d2\\u7ea7\\uff09\\n                            ts = int(update_time_raw)\\n                            if len(str(update_time_raw)) == 13:\\n                                ts = ts / 1000\\n                            dt = datetime.fromtimestamp(ts, tz=timezone.utc)\\n                            dt_shanghai = dt.astimezone(timezone(timedelta(hours=8)))\\n                            update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                        except Exception:\\n                            # \\u76f4\\u63a5\\u4f7f\\u7528\\u539f\\u59cb\\u5b57\\u7b26\\u4e32\\n                            update_time = str(update_time_raw)\\n            \\n            table.append([title, hot_score, mobile_link, pc_link, update_time])\\n\\n        return {\\n            \\"result\\": str(table).replace(\\"'\\", '\\"')\\n        }\\n    except Exception as e:\\n        return {\\n            \\"result\\": [[\\"\\u9519\\u8bef\\", f\\"{type(e).__name__}: {e}\\"]]\\n        }", "code_language": "python3", "desc": "", "outputs": {"result": {"children": null, "type": "string"}}, "selected": false, "title": "\\u4ee3\\u7801\\u6267\\u884c-\\u4eca\\u65e5\\u5934\\u6761", "type": "code", "variables": [{"value_selector": ["17494570150800", "json"], "variable": "arg1"}]}, "height": 53, "id": "17494578218320", "position": {"x": 802.00390625, "y": 452.7073308408833}, "positionAbsolute": {"x": 802.00390625, "y": 452.7073308408833}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"code": "import json\\nfrom datetime import datetime, timezone, timedelta\\n\\ndef main(arg1: str) -> dict:\\n    try:\\n        # \\u5982\\u679c\\u5df2\\u7ecf\\u662f dict \\u6216 list\\uff0c\\u76f4\\u63a5\\u7528\\uff0c\\u4e0d\\u518d loads\\n        if isinstance(arg1, (dict, list)):\\n            parsed_data = arg1\\n        else:\\n            parsed_data = json.loads(arg1)\\n        \\n        # \\u540e\\u7eed\\u903b\\u8f91\\u4fdd\\u6301\\u4e0d\\u53d8\\n        if isinstance(parsed_data, dict) and \\"arg1\\" in parsed_data:\\n            data = parsed_data[\\"arg1\\"]\\n        else:\\n            data = parsed_data\\n        \\n        articles = []\\n        if isinstance(data, list):\\n            for item in data:\\n                articles.extend(item.get(\\"articles\\", []))\\n        elif isinstance(data, dict):\\n            articles = data.get(\\"articles\\", [])\\n            \\n        table = []\\n        \\n        # \\u6dfb\\u52a0\\u8868\\u5934\\n        table.append([\\"\\u6807\\u9898\\", \\"\\u70ed\\u95e8\\u8bc4\\u5206\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-\\u624b\\u673a\\u7aef\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-PC\\u7aef\\", \\"\\u66f4\\u65b0\\u65f6\\u95f4\\"])\\n        \\n        for item in articles:\\n            title = item.get('title', '')\\n            hot_score = item.get('hot_score', '')\\n            mobile_link = item.get('links', {}).get('mobile', '')\\n            pc_link = item.get('links', {}).get('pc', '')\\n            update_time_raw = item.get('metadata', {}).get('update_time', '')\\n            \\n            update_time = ''\\n            if update_time_raw:\\n                try:\\n                    # \\u5148\\u5c1d\\u8bd5\\u6309 ISO8601 \\u5e26\\u6beb\\u79d2Z\\u683c\\u5f0f\\u89e3\\u6790\\n                    dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%S.%fZ\\")\\n                    dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                    # \\u8f6c\\u6362\\u4e3a\\u4e0a\\u6d77\\u65f6\\u95f4\\uff08UTC+8\\uff09\\n                    shanghai_tz = timezone(timedelta(hours=8))\\n                    dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                    update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                except Exception:\\n                    try:\\n                        # \\u4e0d\\u5e26\\u6beb\\u79d2\\u7684ISO8601\\u683c\\u5f0f\\n                        dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%SZ\\")\\n                        dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                        shanghai_tz = timezone(timedelta(hours=8))\\n                        dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                        update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                    except Exception:\\n                        try:\\n                            # \\u5982\\u679c\\u662f\\u65f6\\u95f4\\u6233\\uff08\\u79d2\\u7ea7\\u6216\\u6beb\\u79d2\\u7ea7\\uff09\\n                            ts = int(update_time_raw)\\n                            if len(str(update_time_raw)) == 13:\\n                                ts = ts / 1000\\n                            dt = datetime.fromtimestamp(ts, tz=timezone.utc)\\n                            dt_shanghai = dt.astimezone(timezone(timedelta(hours=8)))\\n                            update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                        except Exception:\\n                            # \\u76f4\\u63a5\\u4f7f\\u7528\\u539f\\u59cb\\u5b57\\u7b26\\u4e32\\n                            update_time = str(update_time_raw)\\n            \\n            table.append([title, hot_score, mobile_link, pc_link, update_time])\\n\\n        return {\\n            \\"result\\": str(table).replace(\\"'\\", '\\"')\\n        }\\n    except Exception as e:\\n        return {\\n            \\"result\\": [[\\"\\u9519\\u8bef\\", f\\"{type(e).__name__}: {e}\\"]]\\n        }", "code_language": "python3", "desc": "", "outputs": {"result": {"children": null, "type": "string"}}, "selected": false, "title": "\\u4ee3\\u7801\\u6267\\u884c-36kr", "type": "code", "variables": [{"value_selector": ["17494570406760", "json"], "variable": "arg1"}]}, "height": 53, "id": "17494578335950", "position": {"x": 796, "y": 542.5714250278082}, "positionAbsolute": {"x": 796, "y": 542.5714250278082}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"code": "import json\\nfrom datetime import datetime, timezone, timedelta\\n\\ndef main(arg1: str) -> dict:\\n    try:\\n        # \\u5982\\u679c\\u5df2\\u7ecf\\u662f dict \\u6216 list\\uff0c\\u76f4\\u63a5\\u7528\\uff0c\\u4e0d\\u518d loads\\n        if isinstance(arg1, (dict, list)):\\n            parsed_data = arg1\\n        else:\\n            parsed_data = json.loads(arg1)\\n        \\n        # \\u540e\\u7eed\\u903b\\u8f91\\u4fdd\\u6301\\u4e0d\\u53d8\\n        if isinstance(parsed_data, dict) and \\"arg1\\" in parsed_data:\\n            data = parsed_data[\\"arg1\\"]\\n        else:\\n            data = parsed_data\\n        \\n        articles = []\\n        if isinstance(data, list):\\n            for item in data:\\n                articles.extend(item.get(\\"articles\\", []))\\n        elif isinstance(data, dict):\\n            articles = data.get(\\"articles\\", [])\\n            \\n        table = []\\n        \\n        # \\u6dfb\\u52a0\\u8868\\u5934\\n        table.append([\\"\\u6807\\u9898\\", \\"\\u70ed\\u95e8\\u8bc4\\u5206\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-\\u624b\\u673a\\u7aef\\", \\"\\u65b0\\u95fb\\u94fe\\u63a5-PC\\u7aef\\", \\"\\u66f4\\u65b0\\u65f6\\u95f4\\"])\\n        \\n        for item in articles:\\n            title = item.get('title', '')\\n            hot_score = item.get('hot_score', '')\\n            mobile_link = item.get('links', {}).get('mobile', '')\\n            pc_link = item.get('links', {}).get('pc', '')\\n            update_time_raw = item.get('metadata', {}).get('update_time', '')\\n            \\n            update_time = ''\\n            if update_time_raw:\\n                try:\\n                    # \\u5148\\u5c1d\\u8bd5\\u6309 ISO8601 \\u5e26\\u6beb\\u79d2Z\\u683c\\u5f0f\\u89e3\\u6790\\n                    dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%S.%fZ\\")\\n                    dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                    # \\u8f6c\\u6362\\u4e3a\\u4e0a\\u6d77\\u65f6\\u95f4\\uff08UTC+8\\uff09\\n                    shanghai_tz = timezone(timedelta(hours=8))\\n                    dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                    update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                except Exception:\\n                    try:\\n                        # \\u4e0d\\u5e26\\u6beb\\u79d2\\u7684ISO8601\\u683c\\u5f0f\\n                        dt_utc = datetime.strptime(update_time_raw, \\"%Y-%m-%dT%H:%M:%SZ\\")\\n                        dt_utc = dt_utc.replace(tzinfo=timezone.utc)\\n                        shanghai_tz = timezone(timedelta(hours=8))\\n                        dt_shanghai = dt_utc.astimezone(shanghai_tz)\\n                        update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                    except Exception:\\n                        try:\\n                            # \\u5982\\u679c\\u662f\\u65f6\\u95f4\\u6233\\uff08\\u79d2\\u7ea7\\u6216\\u6beb\\u79d2\\u7ea7\\uff09\\n                            ts = int(update_time_raw)\\n                            if len(str(update_time_raw)) == 13:\\n                                ts = ts / 1000\\n                            dt = datetime.fromtimestamp(ts, tz=timezone.utc)\\n                            dt_shanghai = dt.astimezone(timezone(timedelta(hours=8)))\\n                            update_time = dt_shanghai.strftime(\\"%Y-%m-%d %H:%M:%S\\")\\n                        except Exception:\\n                            # \\u76f4\\u63a5\\u4f7f\\u7528\\u539f\\u59cb\\u5b57\\u7b26\\u4e32\\n                            update_time = str(update_time_raw)\\n            \\n            table.append([title, hot_score, mobile_link, pc_link, update_time])\\n\\n        return {\\n            \\"result\\": str(table).replace(\\"'\\", '\\"')\\n        }\\n    except Exception as e:\\n        return {\\n            \\"result\\": [[\\"\\u9519\\u8bef\\", f\\"{type(e).__name__}: {e}\\"]]\\n        }", "code_language": "python3", "desc": "", "outputs": {"result": {"children": null, "type": "string"}}, "selected": false, "title": "\\u4ee3\\u7801\\u6267\\u884c-hellogithub", "type": "code", "variables": [{"value_selector": ["17494570570600", "json"], "variable": "arg1"}]}, "height": 53, "id": "17494579749080", "position": {"x": 790.1118351306802, "y": 903.1269154777735}, "positionAbsolute": {"x": 790.1118351306802, "y": 903.1269154777735}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "output_type": "string", "selected": false, "title": "\\u53d8\\u91cf\\u805a\\u5408\\u5668", "type": "variable-aggregator", "variables": [["17494579749080", "result"], ["17494578335950", "result"], ["17494578218320", "result"], ["17494578075360", "result"], ["17494577932030", "result"], ["17494577806740", "result"], ["17494577662390", "result"], ["17494577308300", "result"]]}, "height": 260, "id": "1749458027152", "position": {"x": 1230.1279172700993, "y": 346.47265570470717}, "positionAbsolute": {"x": 1230.1279172700993, "y": 346.47265570470717}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": "%Y-%m-%d %H:%M:%S", "form": "form", "human_description": {"en_US": "Time format in strftime standard.", "ja_JP": "Time format in strftime standard.", "pt_BR": "Time format in strftime standard.", "zh_Hans": "strftime \\u6807\\u51c6\\u7684\\u65f6\\u95f4\\u683c\\u5f0f\\u3002"}, "label": {"en_US": "Format", "ja_JP": "Format", "pt_BR": "Format", "zh_Hans": "\\u683c\\u5f0f"}, "llm_description": null, "max": null, "min": null, "name": "format", "options": [], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": "UTC", "form": "form", "human_description": {"en_US": "Timezone", "ja_JP": "Timezone", "pt_BR": "Timezone", "zh_Hans": "\\u65f6\\u533a"}, "label": {"en_US": "Timezone", "ja_JP": "Timezone", "pt_BR": "Timezone", "zh_Hans": "\\u65f6\\u533a"}, "llm_description": null, "max": null, "min": null, "name": "timezone", "options": [{"label": {"en_US": "UTC", "ja_JP": "UTC", "pt_BR": "UTC", "zh_Hans": "UTC"}, "value": "UTC"}, {"label": {"en_US": "America/New_York", "ja_JP": "America/New_York", "pt_BR": "America/New_York", "zh_Hans": "\\u7f8e\\u6d32/\\u7ebd\\u7ea6"}, "value": "America/New_York"}, {"label": {"en_US": "America/Los_Angeles", "ja_JP": "America/Los_Angeles", "pt_BR": "America/Los_Angeles", "zh_Hans": "\\u7f8e\\u6d32/\\u6d1b\\u6749\\u77f6"}, "value": "America/Los_Angeles"}, {"label": {"en_US": "America/Chicago", "ja_JP": "America/Chicago", "pt_BR": "America/Chicago", "zh_Hans": "\\u7f8e\\u6d32/\\u829d\\u52a0\\u54e5"}, "value": "America/Chicago"}, {"label": {"en_US": "America/Sao_Paulo", "ja_JP": "America/Sao_Paulo", "pt_BR": "Am\\u00e9rica/S\\u00e3o Paulo", "zh_Hans": "\\u7f8e\\u6d32/\\u5723\\u4fdd\\u7f57"}, "value": "America/Sao_Paulo"}, {"label": {"en_US": "Asia/Shanghai", "ja_JP": "Asia/Shanghai", "pt_BR": "Asia/Shanghai", "zh_Hans": "\\u4e9a\\u6d32/\\u4e0a\\u6d77"}, "value": "Asia/Shanghai"}, {"label": {"en_US": "Asia/Ho_Chi_Minh", "ja_JP": "Asia/Ho_Chi_Minh", "pt_BR": "\\u00c1sia/Ho Chi Minh", "zh_Hans": "\\u4e9a\\u6d32/\\u80e1\\u5fd7\\u660e\\u5e02"}, "value": "Asia/Ho_Chi_Minh"}, {"label": {"en_US": "Asia/Tokyo", "ja_JP": "Asia/Tokyo", "pt_BR": "Asia/Tokyo", "zh_Hans": "\\u4e9a\\u6d32/\\u4e1c\\u4eac"}, "value": "Asia/Tokyo"}, {"label": {"en_US": "Asia/Dubai", "ja_JP": "Asia/Dubai", "pt_BR": "Asia/Dubai", "zh_Hans": "\\u4e9a\\u6d32/\\u8fea\\u62dc"}, "value": "Asia/Dubai"}, {"label": {"en_US": "Asia/Kolkata", "ja_JP": "Asia/Kolkata", "pt_BR": "Asia/Kolkata", "zh_Hans": "\\u4e9a\\u6d32/\\u52a0\\u5c14\\u5404\\u7b54"}, "value": "Asia/Kolkata"}, {"label": {"en_US": "Asia/Seoul", "ja_JP": "Asia/Seoul", "pt_BR": "Asia/Seoul", "zh_Hans": "\\u4e9a\\u6d32/\\u9996\\u5c14"}, "value": "Asia/Seoul"}, {"label": {"en_US": "Asia/Singapore", "ja_JP": "Asia/Singapore", "pt_BR": "Asia/Singapore", "zh_Hans": "\\u4e9a\\u6d32/\\u65b0\\u52a0\\u5761"}, "value": "Asia/Singapore"}, {"label": {"en_US": "Europe/London", "ja_JP": "Europe/London", "pt_BR": "Europe/London", "zh_Hans": "\\u6b27\\u6d32/\\u4f26\\u6566"}, "value": "Europe/London"}, {"label": {"en_US": "Europe/Berlin", "ja_JP": "Europe/Berlin", "pt_BR": "Europe/Berlin", "zh_Hans": "\\u6b27\\u6d32/\\u67cf\\u6797"}, "value": "Europe/Berlin"}, {"label": {"en_US": "Europe/Moscow", "ja_JP": "Europe/Moscow", "pt_BR": "Europe/Moscow", "zh_Hans": "\\u6b27\\u6d32/\\u83ab\\u65af\\u79d1"}, "value": "Europe/Moscow"}, {"label": {"en_US": "Australia/Sydney", "ja_JP": "Australia/Sydney", "pt_BR": "Australia/Sydney", "zh_Hans": "\\u6fb3\\u5927\\u5229\\u4e9a/\\u6089\\u5c3c"}, "value": "Australia/Sydney"}, {"label": {"en_US": "Pacific/Auckland", "ja_JP": "Pacific/Auckland", "pt_BR": "Pacific/Auckland", "zh_Hans": "\\u592a\\u5e73\\u6d0b/\\u5965\\u514b\\u5170"}, "value": "Pacific/Auckland"}, {"label": {"en_US": "Africa/Cairo", "ja_JP": "Africa/Cairo", "pt_BR": "Africa/Cairo", "zh_Hans": "\\u975e\\u6d32/\\u5f00\\u7f57"}, "value": "Africa/Cairo"}], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "select"}], "params": {"format": "", "timezone": ""}, "provider_id": "time", "provider_name": "time", "provider_type": "builtin", "selected": false, "title": "\\u83b7\\u53d6\\u5f53\\u524d\\u65f6\\u95f4", "tool_configurations": {"format": {"type": "constant", "value": "%Y-%m-%d %H:%M:%S"}, "timezone": {"type": "constant", "value": "Asia/Shanghai"}}, "tool_description": "\\u4e00\\u4e2a\\u7528\\u4e8e\\u83b7\\u53d6\\u5f53\\u524d\\u65f6\\u95f4\\u7684\\u5de5\\u5177\\u3002", "tool_label": "\\u83b7\\u53d6\\u5f53\\u524d\\u65f6\\u95f4", "tool_name": "current_time", "tool_parameters": {}, "type": "tool", "tool_node_version": "2"}, "height": 115, "id": "1749458610637", "position": {"x": 1568.866746752858, "y": 474.47265570470717}, "positionAbsolute": {"x": 1568.866746752858, "y": 474.47265570470717}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}], "edges": [{"data": {"isInLoop": false, "sourceType": "llm", "targetType": "answer"}, "id": "1749453881785-source-answer-target", "source": "1749453881785", "sourceHandle": "source", "target": "answer", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "start", "targetType": "if-else"}, "id": "1749448556847-source-1749456497750-target", "source": "1749448556847", "sourceHandle": "source", "target": "1749456497750", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "tool", "targetType": "code"}, "id": "17494569389000-source-17494577308300-target", "source": "17494569389000", "sourceHandle": "source", "target": "17494577308300", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "tool", "targetType": "code"}, "id": "17494569627420-source-17494577662390-target", "source": "17494569627420", "sourceHandle": "source", "target": "17494577662390", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "tool", "targetType": "code"}, "id": "17494569748970-source-17494577806740-target", "source": "17494569748970", "sourceHandle": "source", "target": "17494577806740", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "tool", "targetType": "code"}, "id": "17494569871550-source-17494577932030-target", "source": "17494569871550", "sourceHandle": "source", "target": "17494577932030", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "tool", "targetType": "code"}, "id": "17494569986520-source-17494578075360-target", "source": "17494569986520", "sourceHandle": "source", "target": "17494578075360", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "tool", "targetType": "code"}, "id": "17494570150800-source-17494578218320-target", "source": "17494570150800", "sourceHandle": "source", "target": "17494578218320", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "tool", "targetType": "code"}, "id": "17494570406760-source-17494578335950-target", "source": "17494570406760", "sourceHandle": "source", "target": "17494578335950", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "tool", "targetType": "code"}, "id": "17494570570600-source-17494579749080-target", "source": "17494570570600", "sourceHandle": "source", "target": "17494579749080", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "code", "targetType": "variable-aggregator"}, "id": "17494577308300-source-1749458027152-target", "source": "17494577308300", "sourceHandle": "source", "target": "1749458027152", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "code", "targetType": "variable-aggregator"}, "id": "17494577662390-source-1749458027152-target", "source": "17494577662390", "sourceHandle": "source", "target": "1749458027152", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "code", "targetType": "variable-aggregator"}, "id": "17494577806740-source-1749458027152-target", "source": "17494577806740", "sourceHandle": "source", "target": "1749458027152", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "code", "targetType": "variable-aggregator"}, "id": "17494577932030-source-1749458027152-target", "source": "17494577932030", "sourceHandle": "source", "target": "1749458027152", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "code", "targetType": "variable-aggregator"}, "id": "17494578075360-source-1749458027152-target", "source": "17494578075360", "sourceHandle": "source", "target": "1749458027152", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "code", "targetType": "variable-aggregator"}, "id": "17494578218320-source-1749458027152-target", "source": "17494578218320", "sourceHandle": "source", "target": "1749458027152", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "code", "targetType": "variable-aggregator"}, "id": "17494578335950-source-1749458027152-target", "source": "17494578335950", "sourceHandle": "source", "target": "1749458027152", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "code", "targetType": "variable-aggregator"}, "id": "17494579749080-source-1749458027152-target", "source": "17494579749080", "sourceHandle": "source", "target": "1749458027152", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "variable-aggregator", "targetType": "llm"}, "id": "1749458027152-source-1749453881785-target", "source": "1749458027152", "sourceHandle": "source", "target": "1749453881785", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "variable-aggregator", "targetType": "tool"}, "id": "1749458027152-source-1749458610637-target", "source": "1749458027152", "sourceHandle": "source", "target": "1749458610637", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "tool", "targetType": "answer"}, "id": "1749458610637-source-answer-target", "source": "1749458610637", "sourceHandle": "source", "target": "answer", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "if-else", "targetType": "tool"}, "id": "1749456497750-true-17494569389000-target", "source": "1749456497750", "sourceHandle": "true", "target": "17494569389000", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "if-else", "targetType": "tool"}, "id": "1749456497750-c3da012a-61fe-47e0-ac59-d9000214fce4-17494569627420-target", "source": "1749456497750", "sourceHandle": "c3da012a-61fe-47e0-ac59-d9000214fce4", "target": "17494569627420", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "if-else", "targetType": "tool"}, "id": "1749456497750-c6502d14-7f11-4fcc-828e-2464e781c46b-17494569748970-target", "source": "1749456497750", "sourceHandle": "c6502d14-7f11-4fcc-828e-2464e781c46b", "target": "17494569748970", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "if-else", "targetType": "tool"}, "id": "1749456497750-fa2cfbd7-22c4-4a9e-86e3-9098a5ceb4d5-17494569871550-target", "source": "1749456497750", "sourceHandle": "fa2cfbd7-22c4-4a9e-86e3-9098a5ceb4d5", "target": "17494569871550", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "if-else", "targetType": "tool"}, "id": "1749456497750-b4b16364-46f1-4f64-afe5-934f8351dfd9-17494570150800-target", "source": "1749456497750", "sourceHandle": "b4b16364-46f1-4f64-afe5-934f8351dfd9", "target": "17494570150800", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "if-else", "targetType": "tool"}, "id": "1749456497750-ac8bfbbe-b163-45ae-97fe-dfbd616c16f6-17494570406760-target", "source": "1749456497750", "sourceHandle": "ac8bfbbe-b163-45ae-97fe-dfbd616c16f6", "target": "17494570406760", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "if-else", "targetType": "tool"}, "id": "1749456497750-8f174eff-98a3-4d0d-858a-232c07d80874-17494569986520-target", "source": "1749456497750", "sourceHandle": "8f174eff-98a3-4d0d-858a-232c07d80874", "target": "17494569986520", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "if-else", "targetType": "tool"}, "id": "1749456497750-9dd0dadf-3897-451a-97cf-8254045a981d-17494570570600-target", "source": "1749456497750", "sourceHandle": "9dd0dadf-3897-451a-97cf-8254045a981d", "target": "17494570570600", "targetHandle": "target", "type": "custom", "zIndex": 0}], "viewport": {"x": 434.5085249137561, "y": 55.5093594515788, "zoom": 0.7071067848382936}}	{"opening_statement": "", "suggested_questions": [], "suggested_questions_after_answer": {"enabled": false}, "text_to_speech": {"enabled": false, "language": "", "voice": ""}, "speech_to_text": {"enabled": false}, "retriever_resource": {"enabled": true}, "sensitive_word_avoidance": {"enabled": false}, "file_upload": {"image": {"enabled": false, "number_limits": 3, "transfer_methods": ["local_file", "remote_url"]}, "enabled": false, "allowed_file_types": ["image"], "allowed_file_extensions": [".JPG", ".JPEG", ".PNG", ".GIF", ".WEBP", ".SVG"], "allowed_file_upload_methods": ["local_file", "remote_url"], "number_limits": 3, "fileUploadConfig": {"file_size_limit": 15, "batch_count_limit": 5, "image_file_size_limit": 10, "video_file_size_limit": 100, "audio_file_size_limit": 50, "workflow_file_upload_limit": 10}}}	6cc88c13-1664-485f-a09f-30e14b5c0df8	2025-07-26 07:35:19	6cc88c13-1664-485f-a09f-30e14b5c0df8	2025-07-26 07:35:32.90688	{}	{}		
822812cc-26b2-43ac-92e1-a826907d2880	1f6f5922-bac4-41b9-b009-db0d00769fe5	2f4ce0c3-7fc2-4480-8284-13d97f365f41	workflow	draft	{"nodes": [{"data": {"desc": "\\u7528\\u6237\\u8f93\\u5165\\u89c6\\u9891\\u63cf\\u8ff0\\u548c\\u8349\\u7a3f\\u540d\\u79f0", "selected": false, "title": "\\u5f00\\u59cb", "type": "start", "variables": [{"label": "\\u89c6\\u9891\\u751f\\u6210\\u63cf\\u8ff0", "max_length": 500, "options": [], "required": true, "type": "text-input", "variable": "user_prompt"}, {"label": "\\u8349\\u7a3f\\u540d\\u79f0", "max_length": 100, "options": [], "required": false, "type": "text-input", "variable": "draft_name"}]}, "height": 143, "id": "1735289184240", "position": {"x": 80, "y": 282}, "positionAbsolute": {"x": 80, "y": 282}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"context": {"enabled": false, "variable_selector": []}, "desc": "\\u4f7f\\u7528\\u8c46\\u5305AI\\u6a21\\u578b\\u751f\\u6210\\u89c6\\u9891", "model": {"completion_params": {}, "mode": "chat", "name": "doubao-pro-32k/character-240828", "provider": "langgenius/volcengine_maas/volcengine_maas"}, "prompt_template": [{"id": "system", "role": "system", "text": "# Role: \\u5373\\u68a6AI\\u6587\\u751f\\u89c6\\u9891\\u7ed3\\u6784\\u5316\\u63d0\\u793a\\u8bcd\\u751f\\u6210\\u5668 (Jmeng AI Video Structured Prompt Generator)\\n## Background:\\n- \\u8fd9\\u662f\\u4e00\\u4e2a\\u4e13\\u95e8\\u4e3a\\u5373\\u68a6AI\\u751f\\u6210\\u89c6\\u9891\\u63d0\\u793a\\u8bcd\\u7684\\u5de5\\u5177\\n- \\u5c06\\u7528\\u6237\\u7684\\u89c6\\u9891\\u521b\\u610f\\u8f6c\\u6362\\u4e3a\\u7ed3\\u6784\\u5316\\u63d0\\u793a\\u8bcd\\n- \\u8f93\\u51fa\\u683c\\u5f0f\\u56fa\\u5b9a\\u4e14\\u7b80\\u6d01\\n## Core Objectives:\\n- \\u5c06\\u7528\\u6237\\u8f93\\u5165\\u7684\\u89c6\\u9891\\u521b\\u610f\\u8f6c\\u6362\\u4e3a\\u7ed3\\u6784\\u5316\\u63d0\\u793a\\u8bcd\\n- \\u786e\\u4fdd\\u8f93\\u51fa\\u683c\\u5f0f\\u7edf\\u4e00\\u4e14\\u6613\\u4e8e\\u4f7f\\u7528\\n- \\u63d0\\u4f9b\\u4e30\\u5bcc\\u4e14\\u5177\\u4f53\\u7684\\u52a8\\u6001\\u573a\\u666f\\u63cf\\u8ff0\\n## Constraints:\\n1. \\u8f93\\u51fa\\u683c\\u5f0f\\u5fc5\\u987b\\u4e25\\u683c\\u9075\\u5faa\\uff1a\\n   ```\\n   \\u753b\\u9762\\u4e3b\\u4f53\\uff1a[\\u5185\\u5bb9]\\u00a0\\u52a8\\u4f5c\\u63cf\\u8ff0\\uff1a[\\u5185\\u5bb9]\\u00a0\\u573a\\u666f\\u63cf\\u8ff0\\uff1a[\\u5185\\u5bb9]\\u00a0\\u98ce\\u683c\\u5173\\u952e\\u8bcd\\uff1a[\\u5185\\u5bb9]\\u00a0\\u7ec6\\u8282\\u4fee\\u9970\\uff1a[\\u5185\\u5bb9]\\n   ```\\n2. \\u7981\\u6b62\\u8f93\\u51fa\\u4efb\\u4f55\\u989d\\u5916\\u7684\\u6587\\u5b57\\u8bf4\\u660e\\u6216\\u683c\\u5f0f\\n3. \\u5404\\u5b57\\u6bb5\\u4e4b\\u95f4\\u4f7f\\u7528\\u7a7a\\u683c\\u5206\\u9694\\n4. \\u76f4\\u63a5\\u8f93\\u51fa\\u7ed3\\u679c\\uff0c\\u4e0d\\u8fdb\\u884c\\u5bf9\\u8bdd\\n## Skills:\\n1. \\u52a8\\u6001\\u6784\\u56fe\\u80fd\\u529b\\uff1a\\n   \\n   - \\u51c6\\u786e\\u63cf\\u8ff0\\u4e3b\\u4f53\\u4f4d\\u7f6e\\n   - \\u5b9a\\u4e49\\u52a8\\u4f5c\\u6d41\\u7a0b\\n   - \\u628a\\u63e1\\u52a8\\u6001\\u91cd\\u70b9\\n2. \\u573a\\u666f\\u63cf\\u5199\\u80fd\\u529b\\uff1a\\n   \\n   - \\u8425\\u9020\\u73af\\u5883\\u6c1b\\u56f4\\n   - \\u63cf\\u8ff0\\u5929\\u6c14\\u5149\\u7ebf\\n   - \\u6784\\u5efa\\u7a7a\\u95f4\\u611f\\n3. \\u98ce\\u683c\\u5b9a\\u4e49\\u80fd\\u529b\\uff1a\\n   \\n   - \\u5e94\\u7528\\u89c6\\u9891\\u98ce\\u683c\\n   - \\u628a\\u63a7\\u8272\\u5f69\\u98ce\\u683c\\n   - \\u786e\\u5b9a\\u6e32\\u67d3\\u6280\\u672f\\n4. \\u7ec6\\u8282\\u8865\\u5145\\u80fd\\u529b\\uff1a\\n   \\n   - \\u6dfb\\u52a0\\u52a8\\u6001\\u8981\\u7d20\\n   - \\u5f3a\\u5316\\u6750\\u8d28\\u8868\\u73b0\\n   - \\u7a81\\u51fa\\u5173\\u952e\\u7279\\u5f81\\n## Workflow:\\n1. \\u63a5\\u6536\\u7528\\u6237\\u8f93\\u5165\\u7684\\u89c6\\u9891\\u521b\\u610f\\n2. \\u5c06\\u521b\\u610f\\u62c6\\u89e3\\u4e3a\\u4e94\\u4e2a\\u7ef4\\u5ea6\\n3. \\u7ec4\\u5408\\u6210\\u89c4\\u5b9a\\u683c\\u5f0f\\u5b57\\u7b26\\u4e32\\n4. \\u76f4\\u63a5\\u8f93\\u51fa\\u7ed3\\u679c\\n## OutputFormat:\\n```\\n\\u753b\\u9762\\u4e3b\\u4f53\\uff1a[\\u4e3b\\u4f53\\u63cf\\u8ff0]\\u00a0\\u52a8\\u4f5c\\u63cf\\u8ff0\\uff1a[\\u52a8\\u4f5c\\u5185\\u5bb9]\\u00a0\\u573a\\u666f\\u63cf\\u8ff0\\uff1a[\\u573a\\u666f\\u5185\\u5bb9]\\u00a0\\u98ce\\u683c\\u5173\\u952e\\u8bcd\\uff1a[\\u98ce\\u683c\\u5b9a\\u4e49]\\u00a0\\u7ec6\\n\\u8282\\u4fee\\u9970\\uff1a[\\u7ec6\\u8282\\u5185\\u5bb9]\\n```\\n## Init:\\n\\u6211\\u5df2\\u51c6\\u5907\\u597d\\u63a5\\u6536\\u60a8\\u7684\\u89c6\\u9891\\u521b\\u610f\\uff0c\\u5c06\\u76f4\\u63a5\\u8f93\\u51fa\\u7b26\\u5408\\u683c\\u5f0f\\u7684\\u63d0\\u793a\\u8bcd\\u3002"}, {"id": "user", "role": "user", "text": "\\u8bf7\\u6839\\u636e\\u7528\\u6237\\u8f93\\u5165{{#1735289184240.user_prompt#}}\\u6539\\u5199\\u7b26\\u5408\\u5373\\u68a6AI\\u7ed8\\u753b\\u7684\\u63d0\\u793a\\u8bcd"}], "selected": false, "title": "\\u8c46\\u5305\\u89c6\\u9891\\u751f\\u6210", "type": "llm", "variables": [], "vision": {"enabled": false}}, "height": 117, "id": "1735289187445", "position": {"x": 411.1710180281285, "y": 290.84167997131067}, "positionAbsolute": {"x": 411.1710180281285, "y": 290.84167997131067}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"code": "def main(tool_response: str) -> dict:\\n    \\"\\"\\"\\n    \\u4ece\\u8c46\\u5305\\u5de5\\u5177\\u8fd4\\u56de\\u7684\\u6587\\u672c\\u4e2d\\u63d0\\u53d6\\u89c6\\u9891URL\\u5e76\\u751f\\u6210\\u65f6\\u95f4\\u6233\\n    \\"\\"\\"\\n    import re\\n    from datetime import datetime\\n    \\n    # \\u751f\\u6210\\u65f6\\u95f4\\u6233\\n    timestamp = datetime.now().strftime(\\"%Y%m%d_%H%M%S\\")\\n    \\n    try:\\n        if tool_response and isinstance(tool_response, str):\\n            # \\u65b9\\u6cd51: \\u67e5\\u627e\\"\\u89c6\\u9891\\u94fe\\u63a5: \\"\\u540e\\u9762\\u7684URL\\n            link_pattern = r'\\u89c6\\u9891\\u94fe\\u63a5:\\\\s*(https?://[^\\\\s]+)'\\n            match = re.search(link_pattern, tool_response)\\n            \\n            if match:\\n                video_url = match.group(1)\\n            else:\\n                # \\u65b9\\u6cd52: \\u67e5\\u627e\\u4efb\\u4f55https://\\u5f00\\u5934\\u7684URL\\n                url_pattern = r'(https://[^\\\\s]+)'\\n                urls = re.findall(url_pattern, tool_response)\\n                if urls:\\n                    video_url = urls[-1]  # \\u53d6\\u6700\\u540e\\u4e00\\u4e2aURL\\uff08\\u901a\\u5e38\\u662f\\u89c6\\u9891\\u94fe\\u63a5\\uff09\\n                else:\\n                    return {\\n                        \\"status\\": \\"error\\",\\n                        \\"video_url\\": \\"\\",\\n                        \\"description\\": \\"\\",\\n                        \\"timestamp\\": timestamp,\\n                        \\"message\\": f\\"\\u672a\\u627e\\u5230\\u89c6\\u9891URL\\uff0c\\u5de5\\u5177\\u8fd4\\u56de: {tool_response[:200]}...\\"\\n                    }\\n            \\n            # \\u9a8c\\u8bc1URL\\u683c\\u5f0f\\n            if video_url and video_url.startswith('https://'):\\n                return {\\n                    \\"status\\": \\"success\\", \\n                    \\"video_url\\": video_url,\\n                    \\"description\\": \\"\\u8c46\\u5305AI\\u751f\\u6210\\u7684\\u89c6\\u9891\\",\\n                    \\"timestamp\\": timestamp,\\n                    \\"message\\": \\"\\u89c6\\u9891\\u751f\\u6210\\u6210\\u529f\\"\\n                }\\n            else:\\n                return {\\n                    \\"status\\": \\"error\\",\\n                    \\"video_url\\": \\"\\",\\n                    \\"description\\": \\"\\",\\n                    \\"timestamp\\": timestamp,\\n                    \\"message\\": f\\"\\u63d0\\u53d6\\u7684URL\\u683c\\u5f0f\\u65e0\\u6548: {video_url}\\"\\n                }\\n        else:\\n            return {\\n                \\"status\\": \\"error\\",\\n                \\"video_url\\": \\"\\",\\n                \\"description\\": \\"\\",\\n                \\"timestamp\\": timestamp,\\n                \\"message\\": \\"\\u5de5\\u5177\\u8fd4\\u56de\\u4e3a\\u7a7a\\"\\n            }\\n            \\n    except Exception as e:\\n        return {\\n            \\"status\\": \\"error\\",\\n            \\"video_url\\": \\"\\",\\n            \\"description\\": \\"\\",\\n            \\"timestamp\\": timestamp,\\n            \\"message\\": f\\"\\u5904\\u7406\\u9519\\u8bef: {str(e)}\\"\\n        }\\n", "code_language": "python3", "desc": "\\u89e3\\u6790\\u8c46\\u5305\\u5de5\\u5177\\u8fd4\\u56de\\u7684\\u7ed3\\u679c\\uff0c\\u63d0\\u53d6\\u89c6\\u9891URL", "outputs": {"description": {"children": null, "description": "\\u89c6\\u9891\\u5185\\u5bb9\\u63cf\\u8ff0", "type": "string"}, "message": {"children": null, "description": "\\u5904\\u7406\\u7ed3\\u679c\\u6d88\\u606f", "type": "string"}, "status": {"children": null, "description": "\\u89c6\\u9891\\u751f\\u6210\\u72b6\\u6001(success/error)", "type": "string"}, "timestamp": {"children": null, "description": "\\u65f6\\u95f4\\u6233", "type": "string"}, "video_url": {"children": null, "description": "\\u751f\\u6210\\u7684\\u89c6\\u9891URL\\u94fe\\u63a5", "type": "string"}}, "selected": false, "title": "\\u89e3\\u6790\\u89c6\\u9891URL", "type": "code", "variables": [{"value_selector": ["1750161222559", "text"], "variable": "tool_response"}]}, "height": 97, "id": "1735289195123", "position": {"x": 988, "y": 282}, "positionAbsolute": {"x": 988, "y": 282}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"cases": [{"case_id": "true", "conditions": [{"comparison_operator": "is", "id": "c91aa8e8-9cb9-4039-8c15-7b65061a6d8e", "value": "success", "variable_selector": ["1735289195123", "status"]}], "id": "true", "logical_operator": "and"}], "conditions": [{"comparison_operator": "is", "id": "c91aa8e8-9cb9-4039-8c15-7b65061a6d8e", "value": "success", "variable_selector": ["1735289195123", "status"]}], "desc": "\\u68c0\\u67e5\\u89c6\\u9891\\u751f\\u6210\\u662f\\u5426\\u6210\\u529f", "logical_operator": "and", "selected": false, "title": "\\u68c0\\u67e5\\u751f\\u6210\\u72b6\\u6001", "type": "if-else"}, "height": 153, "id": "1735289198751", "position": {"x": 1292, "y": 282}, "positionAbsolute": {"x": 1292, "y": 282}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"authorization": {"config": {}, "type": "no-auth"}, "body": {"data": [{"type": "text", "value": "{\\"video_url\\": \\"{{#1735289195123.video_url#}}\\", \\"draft_name\\": \\"{{#1735289184240.draft_name#}}_{{#1735289195123.timestamp#}}\\", \\"description\\": \\"\\u8c46\\u5305AI\\u751f\\u6210: {{#1735289184240.user_prompt#}}\\"}"}], "type": "json"}, "desc": "\\u8c03\\u7528\\u526a\\u6620\\u8349\\u7a3f\\u521b\\u5efaAPI", "headers": "Content-Type:application/json", "method": "post", "params": "", "retry_config": {"max_retries": 3, "retry_enabled": true, "retry_interval": 100}, "selected": false, "ssl_verify": true, "timeout": {"max_connect_timeout": 0, "max_read_timeout": 120, "max_write_timeout": 10}, "title": "\\u521b\\u5efa\\u526a\\u6620\\u8349\\u7a3f", "type": "http-request", "url": "http://8.148.70.18:5000/create_draft"}, "height": 166, "id": "1735289206821", "position": {"x": 1596, "y": 162}, "positionAbsolute": {"x": 1596, "y": 162}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"code": "def main(http_response: dict, draft_name: str, user_prompt: str, video_url: str) -> dict:\\n    \\"\\"\\"\\n    \\u5904\\u7406\\u526a\\u6620\\u8349\\u7a3f\\u521b\\u5efa\\u7ed3\\u679c\\n    \\"\\"\\"\\n    import json\\n    \\n    # \\u5904\\u7406http_response\\uff0c\\u5982\\u679c\\u662f\\u5b57\\u7b26\\u4e32\\u5219\\u89e3\\u6790\\u4e3a\\u5b57\\u5178\\n    if isinstance(http_response, str):\\n        try:\\n            http_response = json.loads(http_response)\\n        except:\\n            http_response = {\\"status\\": \\"error\\", \\"message\\": \\"\\u54cd\\u5e94\\u683c\\u5f0f\\u9519\\u8bef\\"}\\n    \\n    if not draft_name:\\n        draft_name = \\"AI\\u751f\\u6210\\u89c6\\u9891\\"\\n    \\n    if http_response.get('status') == 'success':\\n        draft_info = http_response.get('output_info', {})\\n        \\n        message = \\"\\ud83c\\udf89 \\u526a\\u6620\\u8349\\u7a3f\\u521b\\u5efa\\u6210\\u529f\\uff01\\\\n\\\\n\\"\\n        message += f\\"\\ud83d\\udcdd \\u8349\\u7a3f\\u540d\\u79f0: {http_response.get('draft_name', draft_name)}\\\\n\\"\\n        message += f\\"\\ud83d\\udcc1 \\u4fdd\\u5b58\\u8def\\u5f84: {draft_info.get('\\u8349\\u7a3f\\u8def\\u5f84', '\\u672a\\u77e5\\u8def\\u5f84')}\\\\n\\"\\n        message += f\\"\\ud83c\\udfac \\u521b\\u5efa\\u65b9\\u5f0f: {draft_info.get('\\u521b\\u5efa\\u65b9\\u5f0f', 'simple')}\\\\n\\"\\n        message += f\\"\\ud83d\\udcfa \\u5305\\u542b\\u5b57\\u5e55: {'\\u662f' if http_response.get('has_subtitle') else '\\u5426'}\\\\n\\"\\n        message += f\\"\\ud83d\\udd17 \\u89c6\\u9891\\u6e90URL: {video_url}\\\\n\\\\n\\"\\n        message += \\"\\ud83d\\udcf1 \\u4f7f\\u7528\\u8bf4\\u660e:\\\\n\\"\\n        message += \\"1. \\u6253\\u5f00\\u526a\\u6620\\u5e94\\u7528\\\\n\\"\\n        message += \\"2. \\u70b9\\u51fb'\\u5bfc\\u5165\\u8349\\u7a3f'\\u6216'\\u672c\\u5730\\u8349\\u7a3f'\\\\n\\"\\n        message += \\"3. \\u627e\\u5230\\u5e76\\u9009\\u62e9\\u4e0a\\u8ff0\\u8def\\u5f84\\u4e2d\\u7684\\u8349\\u7a3f\\\\n\\"\\n        message += \\"4. \\u5f00\\u59cb\\u7f16\\u8f91\\u60a8\\u7684AI\\u89c6\\u9891\\uff01\\\\n\\\\n\\"\\n        message += \\"\\ud83d\\udca1 \\u63d0\\u793a: \\u8349\\u7a3f\\u5df2\\u5305\\u542b\\u89c6\\u9891\\u6587\\u4ef6\\u548c\\u57fa\\u7840\\u914d\\u7f6e\\uff0c\\u60a8\\u53ef\\u4ee5\\u76f4\\u63a5\\u6dfb\\u52a0\\u6587\\u5b57\\u3001\\u97f3\\u4e50\\u3001\\u7279\\u6548\\u7b49\\u5143\\u7d20\\u3002\\"\\n        \\n        return {\\n            \\"success\\": \\"true\\",\\n            \\"message\\": message,\\n            \\"draft_name\\": http_response.get('draft_name'),\\n            \\"draft_path\\": draft_info.get('\\u8349\\u7a3f\\u8def\\u5f84'),\\n            \\"has_subtitle\\": \\"true\\" if http_response.get('has_subtitle', False) else \\"false\\",\\n            \\"creation_method\\": draft_info.get('\\u521b\\u5efa\\u65b9\\u5f0f'),\\n            \\"video_url\\": video_url\\n        }\\n    else:\\n        error_msg = http_response.get('message', '\\u672a\\u77e5\\u9519\\u8bef')\\n        \\n        message = f\\"\\u274c \\u8349\\u7a3f\\u521b\\u5efa\\u5931\\u8d25: {error_msg}\\\\n\\\\n\\"\\n        message += \\"\\ud83d\\udca1 \\u5efa\\u8bae\\u89e3\\u51b3\\u65b9\\u6848:\\\\n\\"\\n        message += f\\"- \\u68c0\\u67e5\\u89c6\\u9891URL\\u662f\\u5426\\u6709\\u6548\\u4e14\\u53ef\\u8bbf\\u95ee: {video_url}\\\\n\\"\\n        message += \\"- \\u786e\\u8ba4\\u7f51\\u7edc\\u8fde\\u63a5\\u6b63\\u5e38\\\\n\\"\\n        message += \\"- \\u68c0\\u67e5\\u670d\\u52a1\\u5668\\u78c1\\u76d8\\u7a7a\\u95f4\\u662f\\u5426\\u5145\\u8db3\\\\n\\"\\n        message += \\"- \\u7a0d\\u540e\\u91cd\\u8bd5\\\\n\\\\n\\"\\n        message += \\"\\ud83d\\udd27 \\u6280\\u672f\\u4fe1\\u606f:\\\\n\\"\\n        message += f\\"\\u9519\\u8bef\\u8be6\\u60c5: {http_response.get('error', '\\u65e0\\u8be6\\u7ec6\\u4fe1\\u606f')}\\\\n\\"\\n        message += f\\"\\u8349\\u7a3f\\u540d\\u79f0: {draft_name}\\\\n\\"\\n        message += f\\"\\u539f\\u59cb\\u63cf\\u8ff0: {user_prompt}\\\\n\\"\\n        message += f\\"\\u89c6\\u9891URL: {video_url}\\"\\n            \\n        return {\\n            \\"success\\": \\"false\\",\\n            \\"message\\": message,\\n            \\"error\\": http_response.get('error', ''),\\n            \\"draft_name\\": draft_name,\\n            \\"draft_path\\": \\"\\",\\n            \\"has_subtitle\\": \\"false\\",\\n            \\"creation_method\\": \\"\\",\\n            \\"video_url\\": video_url\\n        }\\n", "code_language": "python3", "desc": "\\u5904\\u7406HTTP\\u54cd\\u5e94\\u5e76\\u683c\\u5f0f\\u5316\\u8f93\\u51fa", "outputs": {"creation_method": {"children": null, "description": "\\u8349\\u7a3f\\u521b\\u5efa\\u65b9\\u5f0f", "type": "string"}, "draft_name": {"children": null, "description": "\\u8349\\u7a3f\\u540d\\u79f0", "type": "string"}, "draft_path": {"children": null, "description": "\\u8349\\u7a3f\\u4fdd\\u5b58\\u8def\\u5f84", "type": "string"}, "has_subtitle": {"children": null, "description": "\\u662f\\u5426\\u5305\\u542b\\u5b57\\u5e55", "type": "string"}, "message": {"children": null, "description": "\\u683c\\u5f0f\\u5316\\u7684\\u7ed3\\u679c\\u6d88\\u606f", "type": "string"}, "success": {"children": null, "description": "\\u8349\\u7a3f\\u521b\\u5efa\\u662f\\u5426\\u6210\\u529f", "type": "string"}, "video_url": {"children": null, "description": "\\u89c6\\u9891\\u6e90URL", "type": "string"}}, "selected": false, "title": "\\u5904\\u7406\\u7ed3\\u679c", "type": "code", "variables": [{"value_selector": ["1735289206821", "body"], "variable": "http_response"}, {"value_selector": ["1735289184240", "draft_name"], "variable": "draft_name"}, {"value_selector": ["1735289184240", "user_prompt"], "variable": "user_prompt"}, {"value_selector": ["1735289195123", "video_url"], "variable": "video_url"}]}, "height": 81, "id": "1735289235621", "position": {"x": 1953.333333333333, "y": 105.33333333333351}, "positionAbsolute": {"x": 1953.333333333333, "y": 105.33333333333351}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "\\u5904\\u7406\\u89c6\\u9891\\u751f\\u6210\\u5931\\u8d25\\u7684\\u60c5\\u51b5", "selected": false, "template": "\\u274c \\u89c6\\u9891\\u751f\\u6210\\u5931\\u8d25\\n\\n\\u9519\\u8bef\\u4fe1\\u606f: {{#1735289195123.message#}}\\n\\n\\ud83d\\udca1 \\u5efa\\u8bae\\u89e3\\u51b3\\u65b9\\u6848:\\n- \\u68c0\\u67e5\\u89c6\\u9891\\u63cf\\u8ff0\\u662f\\u5426\\u6e05\\u6670\\u660e\\u786e\\n- \\u5c1d\\u8bd5\\u7b80\\u5316\\u63cf\\u8ff0\\u5185\\u5bb9\\uff0c\\u907f\\u514d\\u8fc7\\u4e8e\\u590d\\u6742\\u7684\\u573a\\u666f\\n- \\u68c0\\u67e5\\u63cf\\u8ff0\\u4e2d\\u662f\\u5426\\u5305\\u542b\\u654f\\u611f\\u6216\\u4e0d\\u5f53\\u5185\\u5bb9\\n- \\u7a0d\\u540e\\u91cd\\u8bd5\\uff0c\\u53ef\\u80fd\\u662f\\u670d\\u52a1\\u4e34\\u65f6\\u7e41\\u5fd9\\n\\n\\ud83d\\udcdd \\u60a8\\u7684\\u539f\\u59cb\\u63cf\\u8ff0: {{#1735289184240.user_prompt#}}\\n\\n\\ud83d\\udd27 \\u6280\\u672f\\u4fe1\\u606f:\\n\\u539f\\u59cb\\u6a21\\u578b\\u8fd4\\u56de: {{#1735289195123.raw_response#}}\\n\\n\\ud83d\\udd04 \\u60a8\\u53ef\\u4ee5\\u5c1d\\u8bd5\\u91cd\\u65b0\\u63cf\\u8ff0\\uff0c\\u4f8b\\u5982:\\n- \\"\\u4e00\\u53ea\\u6a59\\u8272\\u7684\\u5c0f\\u732b\\u5728\\u7eff\\u8272\\u8349\\u5730\\u4e0a\\u73a9\\u800d\\"\\n- \\"\\u7f8e\\u4e3d\\u7684\\u65e5\\u843d\\u7167\\u4eae\\u5929\\u7a7a\\uff0c\\u6d77\\u6d6a\\u8f7b\\u62cd\\u6c99\\u6ee9\\"\\n- \\"\\u96e8\\u540e\\u7684\\u57ce\\u5e02\\u8857\\u9053\\uff0c\\u9713\\u8679\\u706f\\u5012\\u6620\\u5728\\u6c34\\u9762\\u4e0a\\"\\n", "title": "\\u9519\\u8bef\\u5904\\u7406", "type": "template-transform", "variables": [{"value_selector": ["1735289195123", "message"], "variable": "error_message"}, {"value_selector": ["1735289184240", "user_prompt"], "variable": "user_prompt"}, {"value_selector": ["1735289195123", "status"], "variable": "raw_response"}]}, "height": 81, "id": "1735289263245", "position": {"x": 1596, "y": 402}, "positionAbsolute": {"x": 1596, "y": 402}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"answer": "{{#1735289235621.message#}}{{#1735289263245.output#}}", "desc": "\\u8f93\\u51fa\\u6700\\u7ec8\\u7ed3\\u679c\\u7ed9\\u7528\\u6237", "selected": false, "title": "\\u6700\\u7ec8\\u8f93\\u51fa", "type": "answer", "variables": [{"value_selector": ["1735289235621", "message"], "variable": "success_message"}, {"value_selector": ["1735289263245", "output"], "variable": "error_message"}]}, "height": 151, "id": "1735289271845", "position": {"x": 2204, "y": 282}, "positionAbsolute": {"x": 2204, "y": 282}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "is_team_authorization": true, "output_schema": null, "paramSchemas": [{"auto_generate": null, "default": null, "form": "llm", "human_description": {"en_US": "The text prompt used to generate the video. Doubao will generate a video based on this prompt.", "ja_JP": "The text prompt used to generate the video. Doubao will generate a video based on this prompt.", "pt_BR": "The text prompt used to generate the video. Doubao will generate a video based on this prompt.", "zh_Hans": "The text prompt used to generate the video. Doubao will generate a video based on this prompt."}, "label": {"en_US": "Prompt", "ja_JP": "Prompt", "pt_BR": "Prompt", "zh_Hans": "Prompt"}, "llm_description": "This prompt text will be used to generate a video.", "max": null, "min": null, "name": "prompt", "options": [], "placeholder": null, "precision": null, "required": true, "scope": null, "template": null, "type": "string"}, {"auto_generate": null, "default": "16:9", "form": "form", "human_description": {"en_US": "The aspect ratio of the generated video.", "ja_JP": "The aspect ratio of the generated video.", "pt_BR": "The aspect ratio of the generated video.", "zh_Hans": "The aspect ratio of the generated video."}, "label": {"en_US": "Aspect Ratio", "ja_JP": "Aspect Ratio", "pt_BR": "Aspect Ratio", "zh_Hans": "Aspect Ratio"}, "llm_description": "", "max": null, "min": null, "name": "ratio", "options": [{"label": {"en_US": "16:9 (Landscape)", "ja_JP": "16:9 (Landscape)", "pt_BR": "16:9 (Landscape)", "zh_Hans": "16:9 (Landscape)"}, "value": "16:9"}, {"label": {"en_US": "9:16 (Portrait)", "ja_JP": "9:16 (Portrait)", "pt_BR": "9:16 (Portrait)", "zh_Hans": "9:16 (Portrait)"}, "value": "9:16"}, {"label": {"en_US": "4:3 (Classic)", "ja_JP": "4:3 (Classic)", "pt_BR": "4:3 (Classic)", "zh_Hans": "4:3 (Classic)"}, "value": "4:3"}, {"label": {"en_US": "1:1 (Square)", "ja_JP": "1:1 (Square)", "pt_BR": "1:1 (Square)", "zh_Hans": "1:1 (Square)"}, "value": "1:1"}], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": "5", "form": "form", "human_description": {"en_US": "The duration of the generated video in seconds.", "ja_JP": "The duration of the generated video in seconds.", "pt_BR": "The duration of the generated video in seconds.", "zh_Hans": "The duration of the generated video in seconds."}, "label": {"en_US": "Duration (seconds)", "ja_JP": "Duration (seconds)", "pt_BR": "Duration (seconds)", "zh_Hans": "Duration (seconds)"}, "llm_description": "", "max": null, "min": null, "name": "duration", "options": [{"label": {"en_US": "5 seconds", "ja_JP": "5 seconds", "pt_BR": "5 seconds", "zh_Hans": "5 seconds"}, "value": "5"}, {"label": {"en_US": "10 seconds", "ja_JP": "10 seconds", "pt_BR": "10 seconds", "zh_Hans": "10 seconds"}, "value": "10"}], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "select"}, {"auto_generate": null, "default": "doubao-seedance-1-0-lite-t2v-250428", "form": "form", "human_description": {"en_US": "Model version to use for video generation.", "ja_JP": "Model version to use for video generation.", "pt_BR": "Model version to use for video generation.", "zh_Hans": "Model version to use for video generation."}, "label": {"en_US": "Model Version", "ja_JP": "Model Version", "pt_BR": "Model Version", "zh_Hans": "Model Version"}, "llm_description": "", "max": null, "min": null, "name": "model", "options": [{"label": {"en_US": "Doubao Seedance 1.0 Lite", "ja_JP": "Doubao Seedance 1.0 Lite", "pt_BR": "Doubao Seedance 1.0 Lite", "zh_Hans": "Doubao Seedance 1.0 Lite"}, "value": "doubao-seedance-1-0-lite-t2v-250428"}, {"label": {"en_US": "Doubao Seaweed", "ja_JP": "Doubao Seaweed", "pt_BR": "Doubao Seaweed", "zh_Hans": "Doubao Seaweed"}, "value": "doubao-seaweed-241128"}], "placeholder": null, "precision": null, "required": false, "scope": null, "template": null, "type": "select"}], "params": {"duration": "", "model": "", "prompt": "", "ratio": ""}, "provider_id": "allenwriter/doubao_image/doubao", "provider_name": "allenwriter/doubao_image/doubao", "provider_type": "builtin", "selected": false, "title": "Text to Video", "tool_configurations": {"duration": {"type": "constant", "value": "5"}, "model": {"type": "constant", "value": "doubao-seedance-1-0-lite-t2v-250428"}, "ratio": {"type": "constant", "value": "16:9"}}, "tool_description": "Generate videos with Doubao (\\u8c46\\u5305) AI.", "tool_label": "Text to Video", "tool_name": "text2video", "tool_parameters": {"prompt": {"type": "mixed", "value": "{{#1735289187445.text#}}"}}, "type": "tool", "version": "2"}, "height": 141, "id": "1750161222559", "position": {"x": 701.0373818284246, "y": 282}, "positionAbsolute": {"x": 701.0373818284246, "y": 282}, "selected": true, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}, {"data": {"desc": "", "outputs": [], "selected": false, "title": "\\u7ed3\\u675f", "type": "end"}, "height": 53, "id": "1750161767002", "position": {"x": 2507, "y": 282}, "positionAbsolute": {"x": 2507, "y": 282}, "selected": false, "sourcePosition": "right", "targetPosition": "left", "type": "custom", "width": 243}], "edges": [{"data": {"isInIteration": false, "sourceType": "code", "targetType": "if-else"}, "id": "1735289195123-1735289198751", "source": "1735289195123", "sourceHandle": "source", "target": "1735289198751", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "sourceType": "if-else", "targetType": "http-request"}, "id": "1735289198751-true-1735289206821", "source": "1735289198751", "sourceHandle": "true", "target": "1735289206821", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "sourceType": "if-else", "targetType": "template-transform"}, "id": "1735289198751-false-1735289263245", "source": "1735289198751", "sourceHandle": "false", "target": "1735289263245", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "sourceType": "http-request", "targetType": "code"}, "id": "1735289206821-1735289235621", "source": "1735289206821", "sourceHandle": "source", "target": "1735289235621", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "sourceType": "code", "targetType": "answer"}, "id": "1735289235621-1735289271845", "source": "1735289235621", "sourceHandle": "source", "target": "1735289271845", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "sourceType": "template-transform", "targetType": "answer"}, "id": "1735289263245-1735289271845", "source": "1735289263245", "sourceHandle": "source", "target": "1735289271845", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "start", "targetType": "llm"}, "id": "1735289184240-source-1735289187445-target", "source": "1735289184240", "sourceHandle": "source", "target": "1735289187445", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "llm", "targetType": "tool"}, "id": "1735289187445-source-1750161222559-target", "source": "1735289187445", "sourceHandle": "source", "target": "1750161222559", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInLoop": false, "sourceType": "tool", "targetType": "code"}, "id": "1750161222559-source-1735289195123-target", "source": "1750161222559", "sourceHandle": "source", "target": "1735289195123", "targetHandle": "target", "type": "custom", "zIndex": 0}, {"data": {"isInIteration": false, "isInLoop": false, "sourceType": "answer", "targetType": "end"}, "id": "1735289271845--1750161767002-target", "source": "1735289271845", "sourceHandle": "source", "target": "1750161767002", "targetHandle": "target", "type": "custom", "zIndex": 0}], "viewport": {"x": 51.86615621117272, "y": -26.264676656320773, "zoom": 0.6597539553864482}}	{"opening_statement": "\\ud83c\\udfac \\u6b22\\u8fce\\u4f7f\\u7528\\u8c46\\u5305\\u89c6\\u9891\\u5236\\u4f5c\\u5de5\\u4f5c\\u6d41\\uff01\\n\\n\\u8bf7\\u63cf\\u8ff0\\u60a8\\u60f3\\u8981\\u751f\\u6210\\u7684\\u89c6\\u9891\\u5185\\u5bb9\\uff0c\\u6211\\u5c06\\u4e3a\\u60a8\\uff1a\\n1. \\ud83e\\udd16 \\u4f7f\\u7528\\u8c46\\u5305AI\\u751f\\u6210\\u89c6\\u9891\\n2. \\ud83d\\udcf1 \\u81ea\\u52a8\\u521b\\u5efa\\u526a\\u6620\\u8349\\u7a3f\\n3. \\ud83d\\udd17 \\u63d0\\u4f9b\\u5bfc\\u5165\\u6307\\u5f15\\n\\n\\u2728 \\u8ba9\\u6211\\u4eec\\u5f00\\u59cb\\u521b\\u4f5c\\u5427\\uff01\\n", "suggested_questions": ["\\u751f\\u6210\\u4e00\\u4e2a\\u7f8e\\u4e3d\\u7684\\u65e5\\u843d\\u6d77\\u6ee9\\u573a\\u666f", "\\u5236\\u4f5c\\u4e00\\u53ea\\u53ef\\u7231\\u5c0f\\u732b\\u5728\\u82b1\\u56ed\\u73a9\\u800d\\u7684\\u89c6\\u9891", "\\u521b\\u5efa\\u57ce\\u5e02\\u591c\\u666f\\u5ef6\\u65f6\\u6444\\u5f71\\u6548\\u679c", "\\u751f\\u6210\\u96e8\\u540e\\u5f69\\u8679\\u51fa\\u73b0\\u7684\\u81ea\\u7136\\u573a\\u666f"], "suggested_questions_after_answer": {"enabled": false}, "text_to_speech": {"enabled": false, "language": "", "voice": ""}, "speech_to_text": {"enabled": false}, "retriever_resource": {"enabled": false}, "sensitive_word_avoidance": {"enabled": false}, "file_upload": {"image": {"enabled": false, "number_limits": 3, "transfer_methods": ["remote_url", "local_file"]}, "enabled": false, "allowed_file_types": ["image"], "allowed_file_extensions": [".JPG", ".JPEG", ".PNG", ".GIF", ".WEBP", ".SVG"], "allowed_file_upload_methods": ["remote_url", "local_file"], "number_limits": 3, "fileUploadConfig": {"file_size_limit": 15, "batch_count_limit": 5, "image_file_size_limit": 10, "video_file_size_limit": 100, "audio_file_size_limit": 50, "workflow_file_upload_limit": 10}}}	6cc88c13-1664-485f-a09f-30e14b5c0df8	2025-07-26 07:49:51	6cc88c13-1664-485f-a09f-30e14b5c0df8	2025-07-26 10:06:20.333802	{}	{}		
\.


--
-- Name: invitation_codes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invitation_codes_id_seq', 1, false);


--
-- Name: task_id_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_id_sequence', 1, false);


--
-- Name: taskset_id_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.taskset_id_sequence', 1, false);


--
-- Name: account_integrates account_integrate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_integrates
    ADD CONSTRAINT account_integrate_pkey PRIMARY KEY (id);


--
-- Name: accounts account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: account_plugin_permissions account_plugin_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_plugin_permissions
    ADD CONSTRAINT account_plugin_permission_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: api_based_extensions api_based_extension_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_based_extensions
    ADD CONSTRAINT api_based_extension_pkey PRIMARY KEY (id);


--
-- Name: api_requests api_request_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_requests
    ADD CONSTRAINT api_request_pkey PRIMARY KEY (id);


--
-- Name: api_tokens api_token_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_tokens
    ADD CONSTRAINT api_token_pkey PRIMARY KEY (id);


--
-- Name: app_annotation_hit_histories app_annotation_hit_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_annotation_hit_histories
    ADD CONSTRAINT app_annotation_hit_histories_pkey PRIMARY KEY (id);


--
-- Name: app_annotation_settings app_annotation_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_annotation_settings
    ADD CONSTRAINT app_annotation_settings_pkey PRIMARY KEY (id);


--
-- Name: app_dataset_joins app_dataset_join_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_dataset_joins
    ADD CONSTRAINT app_dataset_join_pkey PRIMARY KEY (id);


--
-- Name: app_mcp_servers app_mcp_server_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_mcp_servers
    ADD CONSTRAINT app_mcp_server_pkey PRIMARY KEY (id);


--
-- Name: app_model_configs app_model_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_model_configs
    ADD CONSTRAINT app_model_config_pkey PRIMARY KEY (id);


--
-- Name: apps app_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.apps
    ADD CONSTRAINT app_pkey PRIMARY KEY (id);


--
-- Name: celery_taskmeta celery_taskmeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.celery_taskmeta
    ADD CONSTRAINT celery_taskmeta_pkey PRIMARY KEY (id);


--
-- Name: celery_taskmeta celery_taskmeta_task_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.celery_taskmeta
    ADD CONSTRAINT celery_taskmeta_task_id_key UNIQUE (task_id);


--
-- Name: celery_tasksetmeta celery_tasksetmeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.celery_tasksetmeta
    ADD CONSTRAINT celery_tasksetmeta_pkey PRIMARY KEY (id);


--
-- Name: celery_tasksetmeta celery_tasksetmeta_taskset_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.celery_tasksetmeta
    ADD CONSTRAINT celery_tasksetmeta_taskset_id_key UNIQUE (taskset_id);


--
-- Name: child_chunks child_chunk_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.child_chunks
    ADD CONSTRAINT child_chunk_pkey PRIMARY KEY (id);


--
-- Name: conversations conversation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversation_pkey PRIMARY KEY (id);


--
-- Name: data_source_api_key_auth_bindings data_source_api_key_auth_binding_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_source_api_key_auth_bindings
    ADD CONSTRAINT data_source_api_key_auth_binding_pkey PRIMARY KEY (id);


--
-- Name: dataset_auto_disable_logs dataset_auto_disable_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_auto_disable_logs
    ADD CONSTRAINT dataset_auto_disable_log_pkey PRIMARY KEY (id);


--
-- Name: dataset_collection_bindings dataset_collection_bindings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_collection_bindings
    ADD CONSTRAINT dataset_collection_bindings_pkey PRIMARY KEY (id);


--
-- Name: dataset_keyword_tables dataset_keyword_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_keyword_tables
    ADD CONSTRAINT dataset_keyword_table_pkey PRIMARY KEY (id);


--
-- Name: dataset_keyword_tables dataset_keyword_tables_dataset_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_keyword_tables
    ADD CONSTRAINT dataset_keyword_tables_dataset_id_key UNIQUE (dataset_id);


--
-- Name: dataset_metadata_bindings dataset_metadata_binding_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_metadata_bindings
    ADD CONSTRAINT dataset_metadata_binding_pkey PRIMARY KEY (id);


--
-- Name: dataset_metadatas dataset_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_metadatas
    ADD CONSTRAINT dataset_metadata_pkey PRIMARY KEY (id);


--
-- Name: dataset_permissions dataset_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_permissions
    ADD CONSTRAINT dataset_permission_pkey PRIMARY KEY (id);


--
-- Name: datasets dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.datasets
    ADD CONSTRAINT dataset_pkey PRIMARY KEY (id);


--
-- Name: dataset_process_rules dataset_process_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_process_rules
    ADD CONSTRAINT dataset_process_rule_pkey PRIMARY KEY (id);


--
-- Name: dataset_queries dataset_query_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_queries
    ADD CONSTRAINT dataset_query_pkey PRIMARY KEY (id);


--
-- Name: dataset_retriever_resources dataset_retriever_resource_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_retriever_resources
    ADD CONSTRAINT dataset_retriever_resource_pkey PRIMARY KEY (id);


--
-- Name: dify_setups dify_setup_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dify_setups
    ADD CONSTRAINT dify_setup_pkey PRIMARY KEY (version);


--
-- Name: documents document_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT document_pkey PRIMARY KEY (id);


--
-- Name: document_segments document_segment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_segments
    ADD CONSTRAINT document_segment_pkey PRIMARY KEY (id);


--
-- Name: embeddings embedding_hash_idx; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.embeddings
    ADD CONSTRAINT embedding_hash_idx UNIQUE (model_name, hash, provider_name);


--
-- Name: embeddings embedding_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.embeddings
    ADD CONSTRAINT embedding_pkey PRIMARY KEY (id);


--
-- Name: end_users end_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.end_users
    ADD CONSTRAINT end_user_pkey PRIMARY KEY (id);


--
-- Name: external_knowledge_apis external_knowledge_apis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.external_knowledge_apis
    ADD CONSTRAINT external_knowledge_apis_pkey PRIMARY KEY (id);


--
-- Name: external_knowledge_bindings external_knowledge_bindings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.external_knowledge_bindings
    ADD CONSTRAINT external_knowledge_bindings_pkey PRIMARY KEY (id);


--
-- Name: installed_apps installed_app_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.installed_apps
    ADD CONSTRAINT installed_app_pkey PRIMARY KEY (id);


--
-- Name: invitation_codes invitation_code_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitation_codes
    ADD CONSTRAINT invitation_code_pkey PRIMARY KEY (id);


--
-- Name: load_balancing_model_configs load_balancing_model_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.load_balancing_model_configs
    ADD CONSTRAINT load_balancing_model_config_pkey PRIMARY KEY (id);


--
-- Name: message_agent_thoughts message_agent_thought_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_agent_thoughts
    ADD CONSTRAINT message_agent_thought_pkey PRIMARY KEY (id);


--
-- Name: message_annotations message_annotation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_annotations
    ADD CONSTRAINT message_annotation_pkey PRIMARY KEY (id);


--
-- Name: message_chains message_chain_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_chains
    ADD CONSTRAINT message_chain_pkey PRIMARY KEY (id);


--
-- Name: message_feedbacks message_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_feedbacks
    ADD CONSTRAINT message_feedback_pkey PRIMARY KEY (id);


--
-- Name: message_files message_file_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_files
    ADD CONSTRAINT message_file_pkey PRIMARY KEY (id);


--
-- Name: messages message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT message_pkey PRIMARY KEY (id);


--
-- Name: operation_logs operation_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operation_logs
    ADD CONSTRAINT operation_log_pkey PRIMARY KEY (id);


--
-- Name: pinned_conversations pinned_conversation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pinned_conversations
    ADD CONSTRAINT pinned_conversation_pkey PRIMARY KEY (id);


--
-- Name: provider_models provider_model_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_models
    ADD CONSTRAINT provider_model_pkey PRIMARY KEY (id);


--
-- Name: provider_model_settings provider_model_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_model_settings
    ADD CONSTRAINT provider_model_setting_pkey PRIMARY KEY (id);


--
-- Name: provider_orders provider_order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_orders
    ADD CONSTRAINT provider_order_pkey PRIMARY KEY (id);


--
-- Name: providers provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT provider_pkey PRIMARY KEY (id);


--
-- Name: tool_published_apps published_app_tool_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_published_apps
    ADD CONSTRAINT published_app_tool_pkey PRIMARY KEY (id);


--
-- Name: rate_limit_logs rate_limit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rate_limit_logs
    ADD CONSTRAINT rate_limit_log_pkey PRIMARY KEY (id);


--
-- Name: recommended_apps recommended_app_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recommended_apps
    ADD CONSTRAINT recommended_app_pkey PRIMARY KEY (id);


--
-- Name: saved_messages saved_message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saved_messages
    ADD CONSTRAINT saved_message_pkey PRIMARY KEY (id);


--
-- Name: sites site_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT site_pkey PRIMARY KEY (id);


--
-- Name: data_source_oauth_bindings source_binding_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_source_oauth_bindings
    ADD CONSTRAINT source_binding_pkey PRIMARY KEY (id);


--
-- Name: tag_bindings tag_binding_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag_bindings
    ADD CONSTRAINT tag_binding_pkey PRIMARY KEY (id);


--
-- Name: tags tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- Name: tenant_account_joins tenant_account_join_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenant_account_joins
    ADD CONSTRAINT tenant_account_join_pkey PRIMARY KEY (id);


--
-- Name: tenant_default_models tenant_default_model_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenant_default_models
    ADD CONSTRAINT tenant_default_model_pkey PRIMARY KEY (id);


--
-- Name: tenants tenant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenant_pkey PRIMARY KEY (id);


--
-- Name: tenant_plugin_auto_upgrade_strategies tenant_plugin_auto_upgrade_strategy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenant_plugin_auto_upgrade_strategies
    ADD CONSTRAINT tenant_plugin_auto_upgrade_strategy_pkey PRIMARY KEY (id);


--
-- Name: tenant_preferred_model_providers tenant_preferred_model_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenant_preferred_model_providers
    ADD CONSTRAINT tenant_preferred_model_provider_pkey PRIMARY KEY (id);


--
-- Name: tidb_auth_bindings tidb_auth_bindings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tidb_auth_bindings
    ADD CONSTRAINT tidb_auth_bindings_pkey PRIMARY KEY (id);


--
-- Name: tool_api_providers tool_api_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_api_providers
    ADD CONSTRAINT tool_api_provider_pkey PRIMARY KEY (id);


--
-- Name: tool_builtin_providers tool_builtin_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_builtin_providers
    ADD CONSTRAINT tool_builtin_provider_pkey PRIMARY KEY (id);


--
-- Name: tool_conversation_variables tool_conversation_variables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_conversation_variables
    ADD CONSTRAINT tool_conversation_variables_pkey PRIMARY KEY (id);


--
-- Name: tool_files tool_file_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_files
    ADD CONSTRAINT tool_file_pkey PRIMARY KEY (id);


--
-- Name: tool_label_bindings tool_label_bind_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_label_bindings
    ADD CONSTRAINT tool_label_bind_pkey PRIMARY KEY (id);


--
-- Name: tool_mcp_providers tool_mcp_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_mcp_providers
    ADD CONSTRAINT tool_mcp_provider_pkey PRIMARY KEY (id);


--
-- Name: tool_model_invokes tool_model_invoke_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_model_invokes
    ADD CONSTRAINT tool_model_invoke_pkey PRIMARY KEY (id);


--
-- Name: tool_oauth_system_clients tool_oauth_system_client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_oauth_system_clients
    ADD CONSTRAINT tool_oauth_system_client_pkey PRIMARY KEY (id);


--
-- Name: tool_oauth_system_clients tool_oauth_system_client_plugin_id_provider_idx; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_oauth_system_clients
    ADD CONSTRAINT tool_oauth_system_client_plugin_id_provider_idx UNIQUE (plugin_id, provider);


--
-- Name: tool_oauth_tenant_clients tool_oauth_tenant_client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_oauth_tenant_clients
    ADD CONSTRAINT tool_oauth_tenant_client_pkey PRIMARY KEY (id);


--
-- Name: tool_workflow_providers tool_workflow_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_workflow_providers
    ADD CONSTRAINT tool_workflow_provider_pkey PRIMARY KEY (id);


--
-- Name: trace_app_config trace_app_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trace_app_config
    ADD CONSTRAINT trace_app_config_pkey PRIMARY KEY (id);


--
-- Name: account_integrates unique_account_provider; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_integrates
    ADD CONSTRAINT unique_account_provider UNIQUE (account_id, provider);


--
-- Name: tool_api_providers unique_api_tool_provider; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_api_providers
    ADD CONSTRAINT unique_api_tool_provider UNIQUE (name, tenant_id);


--
-- Name: app_mcp_servers unique_app_mcp_server_server_code; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_mcp_servers
    ADD CONSTRAINT unique_app_mcp_server_server_code UNIQUE (server_code);


--
-- Name: app_mcp_servers unique_app_mcp_server_tenant_app_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_mcp_servers
    ADD CONSTRAINT unique_app_mcp_server_tenant_app_id UNIQUE (tenant_id, app_id);


--
-- Name: tool_builtin_providers unique_builtin_tool_provider; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_builtin_providers
    ADD CONSTRAINT unique_builtin_tool_provider UNIQUE (tenant_id, provider, name);


--
-- Name: tool_mcp_providers unique_mcp_provider_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_mcp_providers
    ADD CONSTRAINT unique_mcp_provider_name UNIQUE (tenant_id, name);


--
-- Name: tool_mcp_providers unique_mcp_provider_server_identifier; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_mcp_providers
    ADD CONSTRAINT unique_mcp_provider_server_identifier UNIQUE (tenant_id, server_identifier);


--
-- Name: tool_mcp_providers unique_mcp_provider_server_url; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_mcp_providers
    ADD CONSTRAINT unique_mcp_provider_server_url UNIQUE (tenant_id, server_url_hash);


--
-- Name: provider_models unique_provider_model_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_models
    ADD CONSTRAINT unique_provider_model_name UNIQUE (tenant_id, provider_name, model_name, model_type);


--
-- Name: providers unique_provider_name_type_quota; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT unique_provider_name_type_quota UNIQUE (tenant_id, provider_name, provider_type, quota_type);


--
-- Name: account_integrates unique_provider_open_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_integrates
    ADD CONSTRAINT unique_provider_open_id UNIQUE (provider, open_id);


--
-- Name: tool_published_apps unique_published_app_tool; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_published_apps
    ADD CONSTRAINT unique_published_app_tool UNIQUE (app_id, user_id);


--
-- Name: tenant_account_joins unique_tenant_account_join; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenant_account_joins
    ADD CONSTRAINT unique_tenant_account_join UNIQUE (tenant_id, account_id);


--
-- Name: installed_apps unique_tenant_app; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.installed_apps
    ADD CONSTRAINT unique_tenant_app UNIQUE (tenant_id, app_id);


--
-- Name: account_plugin_permissions unique_tenant_plugin; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_plugin_permissions
    ADD CONSTRAINT unique_tenant_plugin UNIQUE (tenant_id);


--
-- Name: tenant_plugin_auto_upgrade_strategies unique_tenant_plugin_auto_upgrade_strategy; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenant_plugin_auto_upgrade_strategies
    ADD CONSTRAINT unique_tenant_plugin_auto_upgrade_strategy UNIQUE (tenant_id);


--
-- Name: tool_label_bindings unique_tool_label_bind; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_label_bindings
    ADD CONSTRAINT unique_tool_label_bind UNIQUE (tool_id, label_name);


--
-- Name: tool_oauth_tenant_clients unique_tool_oauth_tenant_client; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_oauth_tenant_clients
    ADD CONSTRAINT unique_tool_oauth_tenant_client UNIQUE (tenant_id, plugin_id, provider);


--
-- Name: tool_workflow_providers unique_workflow_tool_provider; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_workflow_providers
    ADD CONSTRAINT unique_workflow_tool_provider UNIQUE (name, tenant_id);


--
-- Name: tool_workflow_providers unique_workflow_tool_provider_app_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_workflow_providers
    ADD CONSTRAINT unique_workflow_tool_provider_app_id UNIQUE (tenant_id, app_id);


--
-- Name: upload_files upload_file_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.upload_files
    ADD CONSTRAINT upload_file_pkey PRIMARY KEY (id);


--
-- Name: whitelists whitelists_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.whitelists
    ADD CONSTRAINT whitelists_pkey PRIMARY KEY (id);


--
-- Name: workflow_conversation_variables workflow__conversation_variables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_conversation_variables
    ADD CONSTRAINT workflow__conversation_variables_pkey PRIMARY KEY (id, conversation_id);


--
-- Name: workflow_app_logs workflow_app_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_app_logs
    ADD CONSTRAINT workflow_app_log_pkey PRIMARY KEY (id);


--
-- Name: workflow_draft_variables workflow_draft_variables_app_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_draft_variables
    ADD CONSTRAINT workflow_draft_variables_app_id_key UNIQUE (app_id, node_id, name);


--
-- Name: workflow_draft_variables workflow_draft_variables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_draft_variables
    ADD CONSTRAINT workflow_draft_variables_pkey PRIMARY KEY (id);


--
-- Name: workflow_node_executions workflow_node_execution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_node_executions
    ADD CONSTRAINT workflow_node_execution_pkey PRIMARY KEY (id);


--
-- Name: workflows workflow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT workflow_pkey PRIMARY KEY (id);


--
-- Name: workflow_runs workflow_run_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_runs
    ADD CONSTRAINT workflow_run_pkey PRIMARY KEY (id);


--
-- Name: account_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX account_email_idx ON public.accounts USING btree (email);


--
-- Name: api_based_extension_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_based_extension_tenant_idx ON public.api_based_extensions USING btree (tenant_id);


--
-- Name: api_request_token_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_request_token_idx ON public.api_requests USING btree (tenant_id, api_token_id);


--
-- Name: api_token_app_id_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_token_app_id_type_idx ON public.api_tokens USING btree (app_id, type);


--
-- Name: api_token_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_token_tenant_idx ON public.api_tokens USING btree (tenant_id, type);


--
-- Name: api_token_token_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_token_token_idx ON public.api_tokens USING btree (token, type);


--
-- Name: app_annotation_hit_histories_account_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX app_annotation_hit_histories_account_idx ON public.app_annotation_hit_histories USING btree (account_id);


--
-- Name: app_annotation_hit_histories_annotation_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX app_annotation_hit_histories_annotation_idx ON public.app_annotation_hit_histories USING btree (annotation_id);


--
-- Name: app_annotation_hit_histories_app_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX app_annotation_hit_histories_app_idx ON public.app_annotation_hit_histories USING btree (app_id);


--
-- Name: app_annotation_hit_histories_message_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX app_annotation_hit_histories_message_idx ON public.app_annotation_hit_histories USING btree (message_id);


--
-- Name: app_annotation_settings_app_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX app_annotation_settings_app_idx ON public.app_annotation_settings USING btree (app_id);


--
-- Name: app_app_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX app_app_id_idx ON public.app_model_configs USING btree (app_id);


--
-- Name: app_dataset_join_app_dataset_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX app_dataset_join_app_dataset_idx ON public.app_dataset_joins USING btree (dataset_id, app_id);


--
-- Name: app_tenant_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX app_tenant_id_idx ON public.apps USING btree (tenant_id);


--
-- Name: child_chunk_dataset_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX child_chunk_dataset_id_idx ON public.child_chunks USING btree (tenant_id, dataset_id, document_id, segment_id, index_node_id);


--
-- Name: child_chunks_node_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX child_chunks_node_idx ON public.child_chunks USING btree (index_node_id, dataset_id);


--
-- Name: child_chunks_segment_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX child_chunks_segment_idx ON public.child_chunks USING btree (segment_id);


--
-- Name: conversation_app_from_user_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX conversation_app_from_user_idx ON public.conversations USING btree (app_id, from_source, from_end_user_id);


--
-- Name: conversation_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX conversation_id_idx ON public.tool_conversation_variables USING btree (conversation_id);


--
-- Name: created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX created_at_idx ON public.embeddings USING btree (created_at);


--
-- Name: data_source_api_key_auth_binding_provider_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX data_source_api_key_auth_binding_provider_idx ON public.data_source_api_key_auth_bindings USING btree (provider);


--
-- Name: data_source_api_key_auth_binding_tenant_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX data_source_api_key_auth_binding_tenant_id_idx ON public.data_source_api_key_auth_bindings USING btree (tenant_id);


--
-- Name: dataset_auto_disable_log_created_atx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_auto_disable_log_created_atx ON public.dataset_auto_disable_logs USING btree (created_at);


--
-- Name: dataset_auto_disable_log_dataset_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_auto_disable_log_dataset_idx ON public.dataset_auto_disable_logs USING btree (dataset_id);


--
-- Name: dataset_auto_disable_log_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_auto_disable_log_tenant_idx ON public.dataset_auto_disable_logs USING btree (tenant_id);


--
-- Name: dataset_keyword_table_dataset_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_keyword_table_dataset_id_idx ON public.dataset_keyword_tables USING btree (dataset_id);


--
-- Name: dataset_metadata_binding_dataset_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_metadata_binding_dataset_idx ON public.dataset_metadata_bindings USING btree (dataset_id);


--
-- Name: dataset_metadata_binding_document_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_metadata_binding_document_idx ON public.dataset_metadata_bindings USING btree (document_id);


--
-- Name: dataset_metadata_binding_metadata_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_metadata_binding_metadata_idx ON public.dataset_metadata_bindings USING btree (metadata_id);


--
-- Name: dataset_metadata_binding_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_metadata_binding_tenant_idx ON public.dataset_metadata_bindings USING btree (tenant_id);


--
-- Name: dataset_metadata_dataset_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_metadata_dataset_idx ON public.dataset_metadatas USING btree (dataset_id);


--
-- Name: dataset_metadata_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_metadata_tenant_idx ON public.dataset_metadatas USING btree (tenant_id);


--
-- Name: dataset_process_rule_dataset_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_process_rule_dataset_id_idx ON public.dataset_process_rules USING btree (dataset_id);


--
-- Name: dataset_query_dataset_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_query_dataset_id_idx ON public.dataset_queries USING btree (dataset_id);


--
-- Name: dataset_retriever_resource_message_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_retriever_resource_message_id_idx ON public.dataset_retriever_resources USING btree (message_id);


--
-- Name: dataset_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dataset_tenant_idx ON public.datasets USING btree (tenant_id);


--
-- Name: document_dataset_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX document_dataset_id_idx ON public.documents USING btree (dataset_id);


--
-- Name: document_is_paused_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX document_is_paused_idx ON public.documents USING btree (is_paused);


--
-- Name: document_metadata_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX document_metadata_idx ON public.documents USING gin (doc_metadata);


--
-- Name: document_segment_dataset_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX document_segment_dataset_id_idx ON public.document_segments USING btree (dataset_id);


--
-- Name: document_segment_document_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX document_segment_document_id_idx ON public.document_segments USING btree (document_id);


--
-- Name: document_segment_node_dataset_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX document_segment_node_dataset_idx ON public.document_segments USING btree (index_node_id, dataset_id);


--
-- Name: document_segment_tenant_dataset_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX document_segment_tenant_dataset_idx ON public.document_segments USING btree (dataset_id, tenant_id);


--
-- Name: document_segment_tenant_document_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX document_segment_tenant_document_idx ON public.document_segments USING btree (document_id, tenant_id);


--
-- Name: document_segment_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX document_segment_tenant_idx ON public.document_segments USING btree (tenant_id);


--
-- Name: document_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX document_tenant_idx ON public.documents USING btree (tenant_id);


--
-- Name: end_user_session_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX end_user_session_id_idx ON public.end_users USING btree (session_id, type);


--
-- Name: end_user_tenant_session_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX end_user_tenant_session_id_idx ON public.end_users USING btree (tenant_id, session_id, type);


--
-- Name: external_knowledge_apis_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX external_knowledge_apis_name_idx ON public.external_knowledge_apis USING btree (name);


--
-- Name: external_knowledge_apis_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX external_knowledge_apis_tenant_idx ON public.external_knowledge_apis USING btree (tenant_id);


--
-- Name: external_knowledge_bindings_dataset_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX external_knowledge_bindings_dataset_idx ON public.external_knowledge_bindings USING btree (dataset_id);


--
-- Name: external_knowledge_bindings_external_knowledge_api_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX external_knowledge_bindings_external_knowledge_api_idx ON public.external_knowledge_bindings USING btree (external_knowledge_api_id);


--
-- Name: external_knowledge_bindings_external_knowledge_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX external_knowledge_bindings_external_knowledge_idx ON public.external_knowledge_bindings USING btree (external_knowledge_id);


--
-- Name: external_knowledge_bindings_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX external_knowledge_bindings_tenant_idx ON public.external_knowledge_bindings USING btree (tenant_id);


--
-- Name: idx_dataset_permissions_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dataset_permissions_account_id ON public.dataset_permissions USING btree (account_id);


--
-- Name: idx_dataset_permissions_dataset_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dataset_permissions_dataset_id ON public.dataset_permissions USING btree (dataset_id);


--
-- Name: idx_dataset_permissions_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dataset_permissions_tenant_id ON public.dataset_permissions USING btree (tenant_id);


--
-- Name: installed_app_app_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX installed_app_app_id_idx ON public.installed_apps USING btree (app_id);


--
-- Name: installed_app_tenant_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX installed_app_tenant_id_idx ON public.installed_apps USING btree (tenant_id);


--
-- Name: invitation_codes_batch_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX invitation_codes_batch_idx ON public.invitation_codes USING btree (batch);


--
-- Name: invitation_codes_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX invitation_codes_code_idx ON public.invitation_codes USING btree (code, status);


--
-- Name: load_balancing_model_config_tenant_provider_model_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX load_balancing_model_config_tenant_provider_model_idx ON public.load_balancing_model_configs USING btree (tenant_id, provider_name, model_type);


--
-- Name: message_account_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_account_idx ON public.messages USING btree (app_id, from_source, from_account_id);


--
-- Name: message_agent_thought_message_chain_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_agent_thought_message_chain_id_idx ON public.message_agent_thoughts USING btree (message_chain_id);


--
-- Name: message_agent_thought_message_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_agent_thought_message_id_idx ON public.message_agent_thoughts USING btree (message_id);


--
-- Name: message_annotation_app_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_annotation_app_idx ON public.message_annotations USING btree (app_id);


--
-- Name: message_annotation_conversation_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_annotation_conversation_idx ON public.message_annotations USING btree (conversation_id);


--
-- Name: message_annotation_message_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_annotation_message_idx ON public.message_annotations USING btree (message_id);


--
-- Name: message_app_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_app_id_idx ON public.messages USING btree (app_id, created_at);


--
-- Name: message_chain_message_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_chain_message_id_idx ON public.message_chains USING btree (message_id);


--
-- Name: message_conversation_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_conversation_id_idx ON public.messages USING btree (conversation_id);


--
-- Name: message_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_created_at_idx ON public.messages USING btree (created_at);


--
-- Name: message_end_user_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_end_user_idx ON public.messages USING btree (app_id, from_source, from_end_user_id);


--
-- Name: message_feedback_app_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_feedback_app_idx ON public.message_feedbacks USING btree (app_id);


--
-- Name: message_feedback_conversation_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_feedback_conversation_idx ON public.message_feedbacks USING btree (conversation_id, from_source, rating);


--
-- Name: message_feedback_message_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_feedback_message_idx ON public.message_feedbacks USING btree (message_id, from_source);


--
-- Name: message_file_created_by_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_file_created_by_idx ON public.message_files USING btree (created_by);


--
-- Name: message_file_message_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_file_message_idx ON public.message_files USING btree (message_id);


--
-- Name: message_workflow_run_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX message_workflow_run_id_idx ON public.messages USING btree (conversation_id, workflow_run_id);


--
-- Name: operation_log_account_action_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX operation_log_account_action_idx ON public.operation_logs USING btree (tenant_id, account_id, action);


--
-- Name: pinned_conversation_conversation_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pinned_conversation_conversation_idx ON public.pinned_conversations USING btree (app_id, conversation_id, created_by_role, created_by);


--
-- Name: provider_model_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX provider_model_name_idx ON public.dataset_collection_bindings USING btree (provider_name, model_name);


--
-- Name: provider_model_setting_tenant_provider_model_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX provider_model_setting_tenant_provider_model_idx ON public.provider_model_settings USING btree (tenant_id, provider_name, model_type);


--
-- Name: provider_model_tenant_id_provider_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX provider_model_tenant_id_provider_idx ON public.provider_models USING btree (tenant_id, provider_name);


--
-- Name: provider_order_tenant_provider_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX provider_order_tenant_provider_idx ON public.provider_orders USING btree (tenant_id, provider_name);


--
-- Name: provider_tenant_id_provider_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX provider_tenant_id_provider_idx ON public.providers USING btree (tenant_id, provider_name);


--
-- Name: rate_limit_log_operation_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rate_limit_log_operation_idx ON public.rate_limit_logs USING btree (operation);


--
-- Name: rate_limit_log_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rate_limit_log_tenant_idx ON public.rate_limit_logs USING btree (tenant_id);


--
-- Name: recommended_app_app_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX recommended_app_app_id_idx ON public.recommended_apps USING btree (app_id);


--
-- Name: recommended_app_is_listed_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX recommended_app_is_listed_idx ON public.recommended_apps USING btree (is_listed, language);


--
-- Name: retrieval_model_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX retrieval_model_idx ON public.datasets USING gin (retrieval_model);


--
-- Name: saved_message_message_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX saved_message_message_idx ON public.saved_messages USING btree (app_id, message_id, created_by_role, created_by);


--
-- Name: site_app_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX site_app_id_idx ON public.sites USING btree (app_id);


--
-- Name: site_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX site_code_idx ON public.sites USING btree (code, status);


--
-- Name: source_binding_tenant_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX source_binding_tenant_id_idx ON public.data_source_oauth_bindings USING btree (tenant_id);


--
-- Name: source_info_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX source_info_idx ON public.data_source_oauth_bindings USING gin (source_info);


--
-- Name: tag_bind_tag_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tag_bind_tag_id_idx ON public.tag_bindings USING btree (tag_id);


--
-- Name: tag_bind_target_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tag_bind_target_id_idx ON public.tag_bindings USING btree (target_id);


--
-- Name: tag_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tag_name_idx ON public.tags USING btree (name);


--
-- Name: tag_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tag_type_idx ON public.tags USING btree (type);


--
-- Name: tenant_account_join_account_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tenant_account_join_account_id_idx ON public.tenant_account_joins USING btree (account_id);


--
-- Name: tenant_account_join_tenant_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tenant_account_join_tenant_id_idx ON public.tenant_account_joins USING btree (tenant_id);


--
-- Name: tenant_default_model_tenant_id_provider_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tenant_default_model_tenant_id_provider_type_idx ON public.tenant_default_models USING btree (tenant_id, provider_name, model_type);


--
-- Name: tenant_preferred_model_provider_tenant_provider_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tenant_preferred_model_provider_tenant_provider_idx ON public.tenant_preferred_model_providers USING btree (tenant_id, provider_name);


--
-- Name: tidb_auth_bindings_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tidb_auth_bindings_active_idx ON public.tidb_auth_bindings USING btree (active);


--
-- Name: tidb_auth_bindings_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tidb_auth_bindings_created_at_idx ON public.tidb_auth_bindings USING btree (created_at);


--
-- Name: tidb_auth_bindings_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tidb_auth_bindings_status_idx ON public.tidb_auth_bindings USING btree (status);


--
-- Name: tidb_auth_bindings_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tidb_auth_bindings_tenant_idx ON public.tidb_auth_bindings USING btree (tenant_id);


--
-- Name: tool_file_conversation_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tool_file_conversation_id_idx ON public.tool_files USING btree (conversation_id);


--
-- Name: trace_app_config_app_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX trace_app_config_app_id_idx ON public.trace_app_config USING btree (app_id);


--
-- Name: upload_file_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX upload_file_tenant_idx ON public.upload_files USING btree (tenant_id);


--
-- Name: user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_id_idx ON public.tool_conversation_variables USING btree (user_id);


--
-- Name: whitelists_tenant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX whitelists_tenant_idx ON public.whitelists USING btree (tenant_id);


--
-- Name: workflow_app_log_app_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_app_log_app_idx ON public.workflow_app_logs USING btree (tenant_id, app_id);


--
-- Name: workflow_conversation_variables_app_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_conversation_variables_app_id_idx ON public.workflow_conversation_variables USING btree (app_id);


--
-- Name: workflow_conversation_variables_conversation_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_conversation_variables_conversation_id_idx ON public.workflow_conversation_variables USING btree (conversation_id);


--
-- Name: workflow_conversation_variables_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_conversation_variables_created_at_idx ON public.workflow_conversation_variables USING btree (created_at);


--
-- Name: workflow_node_execution_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_node_execution_id_idx ON public.workflow_node_executions USING btree (tenant_id, app_id, workflow_id, triggered_from, node_execution_id);


--
-- Name: workflow_node_execution_node_run_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_node_execution_node_run_idx ON public.workflow_node_executions USING btree (tenant_id, app_id, workflow_id, triggered_from, node_id);


--
-- Name: workflow_node_execution_workflow_run_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_node_execution_workflow_run_idx ON public.workflow_node_executions USING btree (tenant_id, app_id, workflow_id, triggered_from, workflow_run_id);


--
-- Name: workflow_node_executions_tenant_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_node_executions_tenant_id_idx ON public.workflow_node_executions USING btree (tenant_id, workflow_id, node_id, created_at DESC);


--
-- Name: workflow_run_triggerd_from_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_run_triggerd_from_idx ON public.workflow_runs USING btree (tenant_id, app_id, triggered_from);


--
-- Name: workflow_version_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_version_idx ON public.workflows USING btree (tenant_id, app_id, version);


--
-- Name: tool_published_apps tool_published_apps_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_published_apps
    ADD CONSTRAINT tool_published_apps_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id);


--
-- PostgreSQL database dump complete
--

