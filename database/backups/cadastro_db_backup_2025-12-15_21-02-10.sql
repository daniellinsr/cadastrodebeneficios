--
-- PostgreSQL database dump
--

\restrict ULg4gxnASEhLsFXotghtXcBOGOHQMyICj7yEz6YO6Aet9615fjc6JlcGpWlYdZc

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2025-12-15 21:02:11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 16388)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 3604 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 899 (class 1247 OID 16639)
-- Name: address_type; Type: TYPE; Schema: public; Owner: cadastro_user
--

CREATE TYPE public.address_type AS ENUM (
    'home',
    'work',
    'delivery',
    'billing',
    'other'
);


ALTER TYPE public.address_type OWNER TO cadastro_user;

--
-- TOC entry 881 (class 1247 OID 16482)
-- Name: card_status; Type: TYPE; Schema: public; Owner: cadastro_user
--

CREATE TYPE public.card_status AS ENUM (
    'active',
    'blocked',
    'cancelled',
    'pending'
);


ALTER TYPE public.card_status OWNER TO cadastro_user;

--
-- TOC entry 878 (class 1247 OID 16477)
-- Name: card_type; Type: TYPE; Schema: public; Owner: cadastro_user
--

CREATE TYPE public.card_type AS ENUM (
    'virtual',
    'physical'
);


ALTER TYPE public.card_type OWNER TO cadastro_user;

--
-- TOC entry 893 (class 1247 OID 16570)
-- Name: transaction_category; Type: TYPE; Schema: public; Owner: cadastro_user
--

CREATE TYPE public.transaction_category AS ENUM (
    'food',
    'transport',
    'health',
    'education',
    'entertainment',
    'shopping',
    'bills',
    'services',
    'other'
);


ALTER TYPE public.transaction_category OWNER TO cadastro_user;

--
-- TOC entry 890 (class 1247 OID 16556)
-- Name: transaction_status; Type: TYPE; Schema: public; Owner: cadastro_user
--

CREATE TYPE public.transaction_status AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'cancelled',
    'refunded'
);


ALTER TYPE public.transaction_status OWNER TO cadastro_user;

--
-- TOC entry 887 (class 1247 OID 16538)
-- Name: transaction_type; Type: TYPE; Schema: public; Owner: cadastro_user
--

CREATE TYPE public.transaction_type AS ENUM (
    'purchase',
    'refund',
    'transfer',
    'deposit',
    'withdrawal',
    'payment',
    'cashback',
    'fee'
);


ALTER TYPE public.transaction_type OWNER TO cadastro_user;

--
-- TOC entry 236 (class 1255 OID 16474)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: cadastro_user
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO cadastro_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 225 (class 1259 OID 16649)
-- Name: addresses; Type: TABLE; Schema: public; Owner: cadastro_user
--

CREATE TABLE public.addresses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    address_type public.address_type DEFAULT 'home'::public.address_type NOT NULL,
    label character varying(100),
    cep character varying(9) NOT NULL,
    logradouro character varying(255) NOT NULL,
    numero character varying(20) NOT NULL,
    complemento character varying(100),
    bairro character varying(100) NOT NULL,
    cidade character varying(100) NOT NULL,
    estado character varying(2) NOT NULL,
    pais character varying(3) DEFAULT 'BRA'::character varying,
    referencia text,
    destinatario character varying(255),
    telefone_contato character varying(20),
    latitude numeric(10,8),
    longitude numeric(11,8),
    is_default boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


ALTER TABLE public.addresses OWNER TO cadastro_user;

--
-- TOC entry 3605 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE addresses; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON TABLE public.addresses IS 'Endereços dos usuários';


--
-- TOC entry 3606 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN addresses.address_type; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.addresses.address_type IS 'Tipo de endereço (casa, trabalho, entrega, etc)';


--
-- TOC entry 3607 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN addresses.label; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.addresses.label IS 'Nome/label personalizado para o endereço';


--
-- TOC entry 3608 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN addresses.cep; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.addresses.cep IS 'CEP (formato: 12345-678)';


--
-- TOC entry 3609 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN addresses.logradouro; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.addresses.logradouro IS 'Logradouro (rua, avenida, etc)';


--
-- TOC entry 3610 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN addresses.numero; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.addresses.numero IS 'Número do endereço';


--
-- TOC entry 3611 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN addresses.complemento; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.addresses.complemento IS 'Complemento (apto, bloco, etc)';


--
-- TOC entry 3612 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN addresses.estado; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.addresses.estado IS 'UF do estado (SP, RJ, etc)';


--
-- TOC entry 3613 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN addresses.pais; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.addresses.pais IS 'Código ISO 3166-1 alpha-3 do país';


--
-- TOC entry 3614 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN addresses.referencia; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.addresses.referencia IS 'Ponto de referência';


--
-- TOC entry 3615 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN addresses.is_default; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.addresses.is_default IS 'Indica se é o endereço padrão do usuário';


--
-- TOC entry 223 (class 1259 OID 16491)
-- Name: cards; Type: TABLE; Schema: public; Owner: cadastro_user
--

CREATE TABLE public.cards (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    card_number character varying(16) NOT NULL,
    card_holder_name character varying(255) NOT NULL,
    expiry_month smallint NOT NULL,
    expiry_year smallint NOT NULL,
    cvv character varying(4) NOT NULL,
    card_type public.card_type DEFAULT 'virtual'::public.card_type NOT NULL,
    status public.card_status DEFAULT 'pending'::public.card_status NOT NULL,
    balance numeric(10,2) DEFAULT 0.00,
    credit_limit numeric(10,2) DEFAULT 0.00,
    daily_limit numeric(10,2),
    monthly_limit numeric(10,2),
    is_default boolean DEFAULT false,
    allow_online_purchases boolean DEFAULT true,
    allow_contactless boolean DEFAULT true,
    allow_international boolean DEFAULT false,
    activated_at timestamp without time zone,
    blocked_at timestamp without time zone,
    blocked_reason text,
    cancelled_at timestamp without time zone,
    cancelled_reason text,
    delivery_address text,
    delivery_date date,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone,
    CONSTRAINT cards_balance_check CHECK ((balance >= (0)::numeric)),
    CONSTRAINT cards_credit_limit_check CHECK ((credit_limit >= (0)::numeric)),
    CONSTRAINT cards_expiry_month_check CHECK (((expiry_month >= 1) AND (expiry_month <= 12))),
    CONSTRAINT cards_expiry_year_check CHECK (((expiry_year)::numeric >= EXTRACT(year FROM CURRENT_DATE)))
);


ALTER TABLE public.cards OWNER TO cadastro_user;

--
-- TOC entry 3616 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE cards; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON TABLE public.cards IS 'Tabela de cartões de benefícios (virtuais e físicos)';


--
-- TOC entry 3617 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN cards.card_number; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.cards.card_number IS 'Número do cartão (16 dígitos)';


--
-- TOC entry 3618 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN cards.cvv; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.cards.cvv IS 'Código de segurança (3 ou 4 dígitos)';


--
-- TOC entry 3619 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN cards.balance; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.cards.balance IS 'Saldo disponível no cartão';


--
-- TOC entry 3620 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN cards.credit_limit; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.cards.credit_limit IS 'Limite de crédito do cartão';


--
-- TOC entry 3621 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN cards.is_default; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.cards.is_default IS 'Indica se é o cartão padrão do usuário';


--
-- TOC entry 3622 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN cards.allow_online_purchases; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.cards.allow_online_purchases IS 'Permite compras online';


--
-- TOC entry 3623 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN cards.allow_contactless; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.cards.allow_contactless IS 'Permite pagamento por aproximação';


--
-- TOC entry 3624 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN cards.allow_international; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.cards.allow_international IS 'Permite transações internacionais';


--
-- TOC entry 222 (class 1259 OID 16451)
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: cadastro_user
--

CREATE TABLE public.password_reset_tokens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    token character varying(500) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    used_at timestamp without time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO cadastro_user;

--
-- TOC entry 3625 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE password_reset_tokens; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON TABLE public.password_reset_tokens IS 'Tokens para reset de senha';


--
-- TOC entry 3626 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN password_reset_tokens.token; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.password_reset_tokens.token IS 'Token único para reset';


--
-- TOC entry 3627 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN password_reset_tokens.expires_at; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.password_reset_tokens.expires_at IS 'Data de expiração do token (geralmente 1 hora)';


--
-- TOC entry 3628 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN password_reset_tokens.used_at; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.password_reset_tokens.used_at IS 'Data em que o token foi usado';


--
-- TOC entry 221 (class 1259 OID 16428)
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: cadastro_user
--

CREATE TABLE public.refresh_tokens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    token character varying(500) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    revoked_at timestamp without time zone,
    device_name character varying(255),
    device_type character varying(50),
    ip_address inet,
    user_agent text
);


ALTER TABLE public.refresh_tokens OWNER TO cadastro_user;

--
-- TOC entry 3629 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON TABLE public.refresh_tokens IS 'Tokens de refresh para renovação de access tokens';


--
-- TOC entry 3630 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN refresh_tokens.token; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.refresh_tokens.token IS 'Token de refresh (JWT)';


--
-- TOC entry 3631 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN refresh_tokens.expires_at; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.refresh_tokens.expires_at IS 'Data de expiração do token';


--
-- TOC entry 3632 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN refresh_tokens.revoked_at; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.refresh_tokens.revoked_at IS 'Data de revogação do token';


--
-- TOC entry 224 (class 1259 OID 16589)
-- Name: transactions; Type: TABLE; Schema: public; Owner: cadastro_user
--

CREATE TABLE public.transactions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    card_id uuid NOT NULL,
    user_id uuid NOT NULL,
    amount numeric(10,2) NOT NULL,
    transaction_type public.transaction_type NOT NULL,
    status public.transaction_status DEFAULT 'pending'::public.transaction_status NOT NULL,
    category public.transaction_category DEFAULT 'other'::public.transaction_category,
    description text NOT NULL,
    merchant_name character varying(255),
    merchant_category character varying(100),
    merchant_location character varying(255),
    latitude numeric(10,8),
    longitude numeric(11,8),
    receipt_url text,
    authorization_code character varying(100),
    reference_number character varying(100),
    cashback_amount numeric(10,2) DEFAULT 0.00,
    cashback_percentage numeric(5,2),
    related_transaction_id uuid,
    processed_at timestamp without time zone,
    failed_reason text,
    cancelled_reason text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone,
    CONSTRAINT transactions_amount_check CHECK ((amount >= (0)::numeric))
);


ALTER TABLE public.transactions OWNER TO cadastro_user;

--
-- TOC entry 3633 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE transactions; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON TABLE public.transactions IS 'Tabela de transações de cartões';


--
-- TOC entry 3634 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN transactions.amount; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.transactions.amount IS 'Valor da transação';


--
-- TOC entry 3635 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN transactions.transaction_type; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.transactions.transaction_type IS 'Tipo de transação (compra, estorno, etc)';


--
-- TOC entry 3636 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN transactions.status; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.transactions.status IS 'Status atual da transação';


--
-- TOC entry 3637 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN transactions.category; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.transactions.category IS 'Categoria da transação';


--
-- TOC entry 3638 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN transactions.merchant_name; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.transactions.merchant_name IS 'Nome do estabelecimento';


--
-- TOC entry 3639 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN transactions.cashback_amount; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.transactions.cashback_amount IS 'Valor do cashback';


--
-- TOC entry 3640 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN transactions.related_transaction_id; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.transactions.related_transaction_id IS 'ID da transação relacionada (para estornos)';


--
-- TOC entry 220 (class 1259 OID 16399)
-- Name: users; Type: TABLE; Schema: public; Owner: cadastro_user
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nome character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified boolean DEFAULT false,
    email_verified_at timestamp without time zone,
    password_hash character varying(255) NOT NULL,
    cpf character varying(14),
    telefone character varying(20) NOT NULL,
    data_nascimento date,
    google_id character varying(255),
    google_access_token text,
    google_refresh_token text,
    avatar_url text,
    is_active boolean DEFAULT true,
    is_admin boolean DEFAULT false,
    last_login_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO cadastro_user;

--
-- TOC entry 3641 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON TABLE public.users IS 'Tabela principal de usuários do sistema';


--
-- TOC entry 3642 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN users.id; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.users.id IS 'ID único do usuário (UUID)';


--
-- TOC entry 3643 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN users.nome; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.users.nome IS 'Nome completo do usuário';


--
-- TOC entry 3644 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN users.email; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.users.email IS 'Email do usuário (único)';


--
-- TOC entry 3645 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN users.email_verified; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.users.email_verified IS 'Indica se o email foi verificado';


--
-- TOC entry 3646 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN users.password_hash; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.users.password_hash IS 'Hash bcrypt da senha do usuário';


--
-- TOC entry 3647 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN users.cpf; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.users.cpf IS 'CPF do usuário (opcional, único)';


--
-- TOC entry 3648 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN users.telefone; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.users.telefone IS 'Telefone do usuário';


--
-- TOC entry 3649 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN users.google_id; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.users.google_id IS 'ID do usuário no Google (para OAuth)';


--
-- TOC entry 3650 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN users.is_active; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.users.is_active IS 'Indica se o usuário está ativo';


--
-- TOC entry 3651 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN users.is_admin; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.users.is_admin IS 'Indica se o usuário é administrador';


--
-- TOC entry 3652 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN users.deleted_at; Type: COMMENT; Schema: public; Owner: cadastro_user
--

COMMENT ON COLUMN public.users.deleted_at IS 'Data de exclusão (soft delete)';


--
-- TOC entry 3598 (class 0 OID 16649)
-- Dependencies: 225
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: cadastro_user
--

COPY public.addresses (id, user_id, address_type, label, cep, logradouro, numero, complemento, bairro, cidade, estado, pais, referencia, destinatario, telefone_contato, latitude, longitude, is_default, is_active, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- TOC entry 3596 (class 0 OID 16491)
-- Dependencies: 223
-- Data for Name: cards; Type: TABLE DATA; Schema: public; Owner: cadastro_user
--

COPY public.cards (id, user_id, card_number, card_holder_name, expiry_month, expiry_year, cvv, card_type, status, balance, credit_limit, daily_limit, monthly_limit, is_default, allow_online_purchases, allow_contactless, allow_international, activated_at, blocked_at, blocked_reason, cancelled_at, cancelled_reason, delivery_address, delivery_date, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- TOC entry 3595 (class 0 OID 16451)
-- Dependencies: 222
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: cadastro_user
--

COPY public.password_reset_tokens (id, user_id, token, expires_at, created_at, used_at) FROM stdin;
\.


--
-- TOC entry 3594 (class 0 OID 16428)
-- Dependencies: 221
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: cadastro_user
--

COPY public.refresh_tokens (id, user_id, token, expires_at, created_at, revoked_at, device_name, device_type, ip_address, user_agent) FROM stdin;
\.


--
-- TOC entry 3597 (class 0 OID 16589)
-- Dependencies: 224
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: cadastro_user
--

COPY public.transactions (id, card_id, user_id, amount, transaction_type, status, category, description, merchant_name, merchant_category, merchant_location, latitude, longitude, receipt_url, authorization_code, reference_number, cashback_amount, cashback_percentage, related_transaction_id, processed_at, failed_reason, cancelled_reason, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- TOC entry 3593 (class 0 OID 16399)
-- Dependencies: 220
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: cadastro_user
--

COPY public.users (id, nome, email, email_verified, email_verified_at, password_hash, cpf, telefone, data_nascimento, google_id, google_access_token, google_refresh_token, avatar_url, is_active, is_admin, last_login_at, created_at, updated_at, deleted_at) FROM stdin;
296101bc-5a58-405c-a33a-0540bd5a5985	Administrador Sistema	admin@cadastro.com	t	\N	$2b$10$EeYFZja2eDfF8oesqI7EYex6qGJeksRPBvQ3x/YiRDxFPBP7Ck0Xy	12345678901	+5511999991111	\N	\N	\N	\N	\N	t	f	\N	2025-12-15 21:00:53.111143	2025-12-15 21:00:53.111143	\N
87d2ffb7-f512-46ec-a3f5-5265a501d8e6	João da Silva	cliente1@example.com	t	\N	$2b$10$JqHtxFw73HP.6LwRaFBtB.5IuBxhBI10uACIkI0Ax4GPyIEVL0VQG	98765432100	+5511999992222	\N	\N	\N	\N	\N	t	f	\N	2025-12-15 21:00:53.150049	2025-12-15 21:00:53.150049	\N
4e673ebd-ad9f-4dcb-b58b-7c25dea41116	Maria Santos	cliente2@example.com	t	\N	$2b$10$JqHtxFw73HP.6LwRaFBtB.5IuBxhBI10uACIkI0Ax4GPyIEVL0VQG	11122233344	+5511999993333	\N	\N	\N	\N	\N	t	f	\N	2025-12-15 21:00:53.172635	2025-12-15 21:00:53.172635	\N
daf9fc7a-a9c7-430a-91cf-976b6464c220	Usuário Teste	teste@example.com	t	\N	$2b$10$JqHtxFw73HP.6LwRaFBtB.5IuBxhBI10uACIkI0Ax4GPyIEVL0VQG	55566677788	+5511999994444	\N	\N	\N	\N	\N	t	f	\N	2025-12-15 21:00:53.195664	2025-12-15 21:00:53.195664	\N
\.


--
-- TOC entry 3427 (class 2606 OID 16671)
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- TOC entry 3402 (class 2606 OID 16523)
-- Name: cards cards_card_number_key; Type: CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_card_number_key UNIQUE (card_number);


--
-- TOC entry 3404 (class 2606 OID 16521)
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- TOC entry 3398 (class 2606 OID 16463)
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 3400 (class 2606 OID 16465)
-- Name: password_reset_tokens password_reset_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_token_key UNIQUE (token);


--
-- TOC entry 3391 (class 2606 OID 16440)
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 3393 (class 2606 OID 16442)
-- Name: refresh_tokens refresh_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_key UNIQUE (token);


--
-- TOC entry 3425 (class 2606 OID 16609)
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- TOC entry 3380 (class 2606 OID 16420)
-- Name: users users_cpf_key; Type: CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_cpf_key UNIQUE (cpf);


--
-- TOC entry 3382 (class 2606 OID 16418)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3384 (class 2606 OID 16422)
-- Name: users users_google_id_key; Type: CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_google_id_key UNIQUE (google_id);


--
-- TOC entry 3386 (class 2606 OID 16416)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3428 (class 1259 OID 16681)
-- Name: idx_addresses_active; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_addresses_active ON public.addresses USING btree (is_active) WHERE (deleted_at IS NULL);


--
-- TOC entry 3429 (class 1259 OID 16678)
-- Name: idx_addresses_cep; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_addresses_cep ON public.addresses USING btree (cep);


--
-- TOC entry 3430 (class 1259 OID 16682)
-- Name: idx_addresses_created_at; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_addresses_created_at ON public.addresses USING btree (created_at);


--
-- TOC entry 3431 (class 1259 OID 16680)
-- Name: idx_addresses_default; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_addresses_default ON public.addresses USING btree (is_default) WHERE ((is_default = true) AND (deleted_at IS NULL));


--
-- TOC entry 3432 (class 1259 OID 16679)
-- Name: idx_addresses_type; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_addresses_type ON public.addresses USING btree (address_type);


--
-- TOC entry 3433 (class 1259 OID 16683)
-- Name: idx_addresses_user_default; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE UNIQUE INDEX idx_addresses_user_default ON public.addresses USING btree (user_id) WHERE ((is_default = true) AND (deleted_at IS NULL));


--
-- TOC entry 3434 (class 1259 OID 16677)
-- Name: idx_addresses_user_id; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_addresses_user_id ON public.addresses USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- TOC entry 3405 (class 1259 OID 16530)
-- Name: idx_cards_card_number; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_cards_card_number ON public.cards USING btree (card_number) WHERE (deleted_at IS NULL);


--
-- TOC entry 3406 (class 1259 OID 16534)
-- Name: idx_cards_created_at; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_cards_created_at ON public.cards USING btree (created_at);


--
-- TOC entry 3407 (class 1259 OID 16533)
-- Name: idx_cards_default; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_cards_default ON public.cards USING btree (is_default) WHERE ((is_default = true) AND (deleted_at IS NULL));


--
-- TOC entry 3408 (class 1259 OID 16531)
-- Name: idx_cards_status; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_cards_status ON public.cards USING btree (status) WHERE (deleted_at IS NULL);


--
-- TOC entry 3409 (class 1259 OID 16532)
-- Name: idx_cards_type; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_cards_type ON public.cards USING btree (card_type);


--
-- TOC entry 3410 (class 1259 OID 16536)
-- Name: idx_cards_user_default; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE UNIQUE INDEX idx_cards_user_default ON public.cards USING btree (user_id) WHERE ((is_default = true) AND (deleted_at IS NULL));


--
-- TOC entry 3411 (class 1259 OID 16529)
-- Name: idx_cards_user_id; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_cards_user_id ON public.cards USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- TOC entry 3394 (class 1259 OID 16473)
-- Name: idx_password_reset_expires_at; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_password_reset_expires_at ON public.password_reset_tokens USING btree (expires_at);


--
-- TOC entry 3395 (class 1259 OID 16472)
-- Name: idx_password_reset_token; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_password_reset_token ON public.password_reset_tokens USING btree (token) WHERE (used_at IS NULL);


--
-- TOC entry 3396 (class 1259 OID 16471)
-- Name: idx_password_reset_user_id; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_password_reset_user_id ON public.password_reset_tokens USING btree (user_id);


--
-- TOC entry 3387 (class 1259 OID 16450)
-- Name: idx_refresh_tokens_expires_at; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_refresh_tokens_expires_at ON public.refresh_tokens USING btree (expires_at);


--
-- TOC entry 3388 (class 1259 OID 16449)
-- Name: idx_refresh_tokens_token; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_refresh_tokens_token ON public.refresh_tokens USING btree (token) WHERE (revoked_at IS NULL);


--
-- TOC entry 3389 (class 1259 OID 16448)
-- Name: idx_refresh_tokens_user_id; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_refresh_tokens_user_id ON public.refresh_tokens USING btree (user_id);


--
-- TOC entry 3412 (class 1259 OID 16631)
-- Name: idx_transactions_amount; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_transactions_amount ON public.transactions USING btree (amount);


--
-- TOC entry 3413 (class 1259 OID 16636)
-- Name: idx_transactions_card_date; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_transactions_card_date ON public.transactions USING btree (card_id, created_at DESC) WHERE (deleted_at IS NULL);


--
-- TOC entry 3414 (class 1259 OID 16625)
-- Name: idx_transactions_card_id; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_transactions_card_id ON public.transactions USING btree (card_id) WHERE (deleted_at IS NULL);


--
-- TOC entry 3415 (class 1259 OID 16629)
-- Name: idx_transactions_category; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_transactions_category ON public.transactions USING btree (category);


--
-- TOC entry 3416 (class 1259 OID 16630)
-- Name: idx_transactions_created_at; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_transactions_created_at ON public.transactions USING btree (created_at DESC);


--
-- TOC entry 3417 (class 1259 OID 16632)
-- Name: idx_transactions_merchant; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_transactions_merchant ON public.transactions USING btree (merchant_name);


--
-- TOC entry 3418 (class 1259 OID 16633)
-- Name: idx_transactions_processed_at; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_transactions_processed_at ON public.transactions USING btree (processed_at);


--
-- TOC entry 3419 (class 1259 OID 16634)
-- Name: idx_transactions_related; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_transactions_related ON public.transactions USING btree (related_transaction_id) WHERE (related_transaction_id IS NOT NULL);


--
-- TOC entry 3420 (class 1259 OID 16628)
-- Name: idx_transactions_status; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_transactions_status ON public.transactions USING btree (status);


--
-- TOC entry 3421 (class 1259 OID 16627)
-- Name: idx_transactions_type; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_transactions_type ON public.transactions USING btree (transaction_type);


--
-- TOC entry 3422 (class 1259 OID 16635)
-- Name: idx_transactions_user_date; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_transactions_user_date ON public.transactions USING btree (user_id, created_at DESC) WHERE (deleted_at IS NULL);


--
-- TOC entry 3423 (class 1259 OID 16626)
-- Name: idx_transactions_user_id; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_transactions_user_id ON public.transactions USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- TOC entry 3374 (class 1259 OID 16426)
-- Name: idx_users_active; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_users_active ON public.users USING btree (is_active) WHERE (deleted_at IS NULL);


--
-- TOC entry 3375 (class 1259 OID 16424)
-- Name: idx_users_cpf; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_users_cpf ON public.users USING btree (cpf) WHERE ((deleted_at IS NULL) AND (cpf IS NOT NULL));


--
-- TOC entry 3376 (class 1259 OID 16427)
-- Name: idx_users_created_at; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_users_created_at ON public.users USING btree (created_at);


--
-- TOC entry 3377 (class 1259 OID 16423)
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_users_email ON public.users USING btree (email) WHERE (deleted_at IS NULL);


--
-- TOC entry 3378 (class 1259 OID 16425)
-- Name: idx_users_google_id; Type: INDEX; Schema: public; Owner: cadastro_user
--

CREATE INDEX idx_users_google_id ON public.users USING btree (google_id) WHERE ((deleted_at IS NULL) AND (google_id IS NOT NULL));


--
-- TOC entry 3445 (class 2620 OID 16684)
-- Name: addresses update_addresses_updated_at; Type: TRIGGER; Schema: public; Owner: cadastro_user
--

CREATE TRIGGER update_addresses_updated_at BEFORE UPDATE ON public.addresses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 3443 (class 2620 OID 16535)
-- Name: cards update_cards_updated_at; Type: TRIGGER; Schema: public; Owner: cadastro_user
--

CREATE TRIGGER update_cards_updated_at BEFORE UPDATE ON public.cards FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 3444 (class 2620 OID 16637)
-- Name: transactions update_transactions_updated_at; Type: TRIGGER; Schema: public; Owner: cadastro_user
--

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON public.transactions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 3442 (class 2620 OID 16475)
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: cadastro_user
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 3441 (class 2606 OID 16672)
-- Name: addresses addresses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3437 (class 2606 OID 16524)
-- Name: cards cards_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3436 (class 2606 OID 16466)
-- Name: password_reset_tokens password_reset_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3435 (class 2606 OID 16443)
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3438 (class 2606 OID 16610)
-- Name: transactions transactions_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.cards(id) ON DELETE CASCADE;


--
-- TOC entry 3439 (class 2606 OID 16620)
-- Name: transactions transactions_related_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_related_transaction_id_fkey FOREIGN KEY (related_transaction_id) REFERENCES public.transactions(id);


--
-- TOC entry 3440 (class 2606 OID 16615)
-- Name: transactions transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cadastro_user
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2025-12-15 21:02:13

--
-- PostgreSQL database dump complete
--

\unrestrict ULg4gxnASEhLsFXotghtXcBOGOHQMyICj7yEz6YO6Aet9615fjc6JlcGpWlYdZc

