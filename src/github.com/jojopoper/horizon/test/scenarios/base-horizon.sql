--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

DROP INDEX public.unique_schema_migrations;
DROP INDEX public.trade_effects_by_order_book;
DROP INDEX public.index_history_transactions_on_id;
DROP INDEX public.index_history_transaction_statuses_lc_on_all;
DROP INDEX public.index_history_transaction_participants_on_transaction_hash;
DROP INDEX public.index_history_transaction_participants_on_account;
DROP INDEX public.index_history_operations_on_type;
DROP INDEX public.index_history_operations_on_transaction_id;
DROP INDEX public.index_history_operations_on_id;
DROP INDEX public.index_history_ledgers_on_sequence;
DROP INDEX public.index_history_ledgers_on_previous_ledger_hash;
DROP INDEX public.index_history_ledgers_on_ledger_hash;
DROP INDEX public.index_history_ledgers_on_importer_version;
DROP INDEX public.index_history_ledgers_on_id;
DROP INDEX public.index_history_ledgers_on_closed_at;
DROP INDEX public.index_history_effects_on_type;
DROP INDEX public.index_history_accounts_on_id;
DROP INDEX public.hs_transaction_by_id;
DROP INDEX public.hs_ledger_by_id;
DROP INDEX public.hist_op_p_id;
DROP INDEX public.hist_e_id;
DROP INDEX public.hist_e_by_order;
DROP INDEX public.by_status;
DROP INDEX public.by_ledger;
DROP INDEX public.by_hash;
DROP INDEX public.by_account;
ALTER TABLE ONLY public.history_transaction_statuses DROP CONSTRAINT history_transaction_statuses_pkey;
ALTER TABLE ONLY public.history_transaction_participants DROP CONSTRAINT history_transaction_participants_pkey;
ALTER TABLE ONLY public.history_operation_participants DROP CONSTRAINT history_operation_participants_pkey;
ALTER TABLE public.history_transaction_statuses ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.history_transaction_participants ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.history_operation_participants ALTER COLUMN id DROP DEFAULT;
DROP TABLE public.schema_migrations;
DROP TABLE public.history_transactions;
DROP SEQUENCE public.history_transaction_statuses_id_seq;
DROP TABLE public.history_transaction_statuses;
DROP SEQUENCE public.history_transaction_participants_id_seq;
DROP TABLE public.history_transaction_participants;
DROP TABLE public.history_operations;
DROP SEQUENCE public.history_operation_participants_id_seq;
DROP TABLE public.history_operation_participants;
DROP TABLE public.history_ledgers;
DROP TABLE public.history_effects;
DROP TABLE public.history_accounts;
DROP EXTENSION hstore;
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: history_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_accounts (
    id bigint NOT NULL,
    address character varying(64)
);


--
-- Name: history_effects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_effects (
    history_account_id bigint NOT NULL,
    history_operation_id bigint NOT NULL,
    "order" integer NOT NULL,
    type integer NOT NULL,
    details jsonb
);


--
-- Name: history_ledgers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_ledgers (
    sequence integer NOT NULL,
    ledger_hash character varying(64) NOT NULL,
    previous_ledger_hash character varying(64),
    transaction_count integer DEFAULT 0 NOT NULL,
    operation_count integer DEFAULT 0 NOT NULL,
    closed_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id bigint,
    importer_version integer DEFAULT 1 NOT NULL
);


--
-- Name: history_operation_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_operation_participants (
    id integer NOT NULL,
    history_operation_id bigint NOT NULL,
    history_account_id bigint NOT NULL
);


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_operation_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_operation_participants_id_seq OWNED BY history_operation_participants.id;


--
-- Name: history_operations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_operations (
    id bigint NOT NULL,
    transaction_id bigint NOT NULL,
    application_order integer NOT NULL,
    type integer NOT NULL,
    details jsonb
);


--
-- Name: history_transaction_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_transaction_participants (
    id integer NOT NULL,
    transaction_hash character varying(64) NOT NULL,
    account character varying(64) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_transaction_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_transaction_participants_id_seq OWNED BY history_transaction_participants.id;


--
-- Name: history_transaction_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_transaction_statuses (
    id integer NOT NULL,
    result_code_s character varying NOT NULL,
    result_code integer NOT NULL
);


--
-- Name: history_transaction_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_transaction_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_transaction_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_transaction_statuses_id_seq OWNED BY history_transaction_statuses.id;


--
-- Name: history_transactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_transactions (
    transaction_hash character varying(64) NOT NULL,
    ledger_sequence integer NOT NULL,
    application_order integer NOT NULL,
    account character varying(64) NOT NULL,
    account_sequence bigint NOT NULL,
    max_fee integer NOT NULL,
    fee_paid integer NOT NULL,
    operation_count integer NOT NULL,
    transaction_status_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id bigint,
    tx_envelope text,
    tx_result text,
    tx_meta text
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_operation_participants ALTER COLUMN id SET DEFAULT nextval('history_operation_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_transaction_participants ALTER COLUMN id SET DEFAULT nextval('history_transaction_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_transaction_statuses ALTER COLUMN id SET DEFAULT nextval('history_transaction_statuses_id_seq'::regclass);


--
-- Data for Name: history_accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_accounts (id, address) FROM stdin;
0	GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H
8589938689	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU
8589942785	GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2
8589946881	GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON
\.


--
-- Data for Name: history_effects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_effects (history_account_id, history_operation_id, "order", type, details) FROM stdin;
8589938689	8589938689	1	0	{"starting_balance": "100.0"}
0	8589938689	2	3	{"amount": "100.0", "asset_type": "native"}
8589938689	8589938689	3	10	{"weight": 2, "public_key": "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU"}
8589942785	8589942785	1	0	{"starting_balance": "100.0"}
0	8589942785	2	3	{"amount": "100.0", "asset_type": "native"}
8589942785	8589942785	3	10	{"weight": 2, "public_key": "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2"}
8589946881	8589946881	1	0	{"starting_balance": "100.0"}
0	8589946881	2	3	{"amount": "100.0", "asset_type": "native"}
8589946881	8589946881	3	10	{"weight": 2, "public_key": "GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON"}
8589946881	12884905985	1	2	{"amount": "5.0", "asset_type": "native"}
8589938689	12884905985	2	3	{"amount": "5.0", "asset_type": "native"}
\.


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_ledgers (sequence, ledger_hash, previous_ledger_hash, transaction_count, operation_count, closed_at, created_at, updated_at, id, importer_version) FROM stdin;
1	5ade5048fb66795219cbb45a55bf5e2710f739610d10e6875bf7f85d85900669	\N	0	0	1970-01-01 00:00:00	2015-09-14 15:40:01.886563	2015-09-14 15:40:01.886563	4294967296	1
2	639b9b63c5a24f69c8b7102126b3c4442b6f9769106355a6ab1f9f04ebc4b657	5ade5048fb66795219cbb45a55bf5e2710f739610d10e6875bf7f85d85900669	3	3	2015-09-14 15:40:00	2015-09-14 15:40:01.896782	2015-09-14 15:40:01.896782	8589934592	1
3	0e7934b42e1c3bc5c9bd70370f9a0ec50f0ecf52f7aea95ecaa6934b0f4a43ab	639b9b63c5a24f69c8b7102126b3c4442b6f9769106355a6ab1f9f04ebc4b657	1	1	2015-09-14 15:40:01	2015-09-14 15:40:01.978109	2015-09-14 15:40:01.978109	12884901888	1
\.


--
-- Data for Name: history_operation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operation_participants (id, history_operation_id, history_account_id) FROM stdin;
74	8589938689	0
75	8589938689	8589938689
76	8589942785	0
77	8589942785	8589942785
78	8589946881	0
79	8589946881	8589946881
80	12884905985	8589938689
81	12884905985	8589946881
\.


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_operation_participants_id_seq', 81, true);


--
-- Data for Name: history_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operations (id, transaction_id, application_order, type, details) FROM stdin;
8589938689	8589938688	1	0	{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU", "starting_balance": "100.0"}
8589942785	8589942784	1	0	{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2", "starting_balance": "100.0"}
8589946881	8589946880	1	0	{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON", "starting_balance": "100.0"}
12884905985	12884905984	1	1	{"to": "GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON", "from": "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU", "amount": "5.0", "asset_type": "native"}
\.


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transaction_participants (id, transaction_hash, account, created_at, updated_at) FROM stdin;
74	c492d87c4642815dfb3c7dcce01af4effd162b031064098a0d786b6e0a00fd74	GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H	2015-09-14 15:40:01.901889	2015-09-14 15:40:01.901889
75	c492d87c4642815dfb3c7dcce01af4effd162b031064098a0d786b6e0a00fd74	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	2015-09-14 15:40:01.902953	2015-09-14 15:40:01.902953
76	f70627f6d076a346902bdeaa0d55d8403dfcbdfad1c79d58baf54031a5c477ce	GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H	2015-09-14 15:40:01.925746	2015-09-14 15:40:01.925746
77	f70627f6d076a346902bdeaa0d55d8403dfcbdfad1c79d58baf54031a5c477ce	GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2	2015-09-14 15:40:01.926859	2015-09-14 15:40:01.926859
78	2ea11f77ea64e5d24978176ab762904921f236c9b6f867032161e7d439f5fc0e	GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H	2015-09-14 15:40:01.94934	2015-09-14 15:40:01.94934
79	2ea11f77ea64e5d24978176ab762904921f236c9b6f867032161e7d439f5fc0e	GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON	2015-09-14 15:40:01.950489	2015-09-14 15:40:01.950489
80	6cb73d3fdbf5b651ca18810f4dfbc3bdd65bc2653feaf0765b246dca51d3f85d	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	2015-09-14 15:40:01.98293	2015-09-14 15:40:01.98293
81	6cb73d3fdbf5b651ca18810f4dfbc3bdd65bc2653feaf0765b246dca51d3f85d	GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON	2015-09-14 15:40:01.984004	2015-09-14 15:40:01.984004
\.


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 81, true);


--
-- Data for Name: history_transaction_statuses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transaction_statuses (id, result_code_s, result_code) FROM stdin;
\.


--
-- Name: history_transaction_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_statuses_id_seq', 1, false);


--
-- Data for Name: history_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transactions (transaction_hash, ledger_sequence, application_order, account, account_sequence, max_fee, fee_paid, operation_count, transaction_status_id, created_at, updated_at, id, tx_envelope, tx_result, tx_meta) FROM stdin;
c492d87c4642815dfb3c7dcce01af4effd162b031064098a0d786b6e0a00fd74	2	1	GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H	1	0	0	1	-1	2015-09-14 15:40:01.89962	2015-09-14 15:40:01.89962	8589938688	AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAACgAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rKAAAAAAAAAAABVvwF9wAAAEAKZ7IPj/46PuWU6ZOtyMosctNAkXRNX9WCAI5RnfRk+AyxDLoDZP/9l3NvsxQtWj9juQOuoBlFLnWu8intgxQA	xJLYfEZCgV37PH3M4Br07/0WKwMQZAmKDXhrbgoA/XQAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAAAgAAAAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcBY0V4XYn/9gAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAgAAAAAAAAACAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAA7msoAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wFjRXgh7zX2AAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
f70627f6d076a346902bdeaa0d55d8403dfcbdfad1c79d58baf54031a5c477ce	2	2	GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H	2	0	0	1	-1	2015-09-14 15:40:01.923482	2015-09-14 15:40:01.923482	8589942784	AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAACgAAAAAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAAAO5rKAAAAAAAAAAABVvwF9wAAAEBAdzrfagUELK+B7YIfOjPLUDKSom+E85ERFvGzumzFW30TsfC+cZtHkp6Dt5quxa5w3K5KHRV6vJTtLcjIuosA	9wYn9tB2o0aQK96qDVXYQD38vfrRx51YuvVAMaXEd84AAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAAAgAAAAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcBY0V4Ie817AAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAgAAAAAAAAACAAAAAAAAAAA7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAA7msoAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wFjRXfmVGvsAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
2ea11f77ea64e5d24978176ab762904921f236c9b6f867032161e7d439f5fc0e	2	3	GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H	3	0	0	1	-1	2015-09-14 15:40:01.947116	2015-09-14 15:40:01.947116	8589946880	AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAACgAAAAAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAAAO5rKAAAAAAAAAAABVvwF9wAAAECEIeCxPJe3yRtnh0sMzF8b0F0GtR1zmiJ3QtT9rEnCv1PjqiTzwgH17er14ERCqDQPy82j560ImRCLns6779kL	LqEfd+pk5dJJeBdqt2KQSSHyNsm2+GcDIWHn1Dn1/A4AAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAAAgAAAAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcBY0V35lRr4gAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAgAAAAAAAAACAAAAAAAAAABuaCbVXZ2DlXWarV6UxwbW3GNJgpn3ASChIFp5bxSIWgAAAAA7msoAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wFjRXequaHiAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
6cb73d3fdbf5b651ca18810f4dfbc3bdd65bc2653feaf0765b246dca51d3f85d	3	1	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	8589934593	0	0	1	-1	2015-09-14 15:40:01.980763	2015-09-14 15:40:01.980763	12884905984	AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAACgAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAAAAAAAAAL68IAAAAAAAAAAAa7kvkwAAABAyqwZizeSkpNDIsUt2B1huJHRJS+YhRfaPsML7t9FlOCXgpWnSLAIzTfQ3/IKH73CRu84FRMw3sv0fTwfv8UrAw==	bLc9P9v1tlHKGIEPTfvDvdZbwmU/6vB2WyRtylHT+F0AAAAAAAAACgAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAAAwAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rJ9gAAAAIAAAABAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAgAAAAEAAAADAAAAAAAAAABuaCbVXZ2DlXWarV6UxwbW3GNJgpn3ASChIFp5bxSIWgAAAAA+lbqAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAA4n9l2AAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY schema_migrations (version) FROM stdin;
20150508215546
20150310224849
20150313225945
20150313225955
20150501160031
20150508003829
20150508175821
20150508183542
20150609230237
20150629181921
20150825223417
20150825180131
20150902224148
\.


--
-- Name: history_operation_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_operation_participants
    ADD CONSTRAINT history_operation_participants_pkey PRIMARY KEY (id);


--
-- Name: history_transaction_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_transaction_participants
    ADD CONSTRAINT history_transaction_participants_pkey PRIMARY KEY (id);


--
-- Name: history_transaction_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_transaction_statuses
    ADD CONSTRAINT history_transaction_statuses_pkey PRIMARY KEY (id);


--
-- Name: by_account; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_account ON history_transactions USING btree (account, account_sequence);


--
-- Name: by_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_hash ON history_transactions USING btree (transaction_hash);


--
-- Name: by_ledger; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_ledger ON history_transactions USING btree (ledger_sequence, application_order);


--
-- Name: by_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_status ON history_transactions USING btree (transaction_status_id);


--
-- Name: hist_e_by_order; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hist_e_by_order ON history_effects USING btree (history_operation_id, "order");


--
-- Name: hist_e_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hist_e_id ON history_effects USING btree (history_account_id, history_operation_id, "order");


--
-- Name: hist_op_p_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hist_op_p_id ON history_operation_participants USING btree (history_account_id, history_operation_id);


--
-- Name: hs_ledger_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hs_ledger_by_id ON history_ledgers USING btree (id);


--
-- Name: hs_transaction_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hs_transaction_by_id ON history_transactions USING btree (id);


--
-- Name: index_history_accounts_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_accounts_on_id ON history_accounts USING btree (id);


--
-- Name: index_history_effects_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_effects_on_type ON history_effects USING btree (type);


--
-- Name: index_history_ledgers_on_closed_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_ledgers_on_closed_at ON history_ledgers USING btree (closed_at);


--
-- Name: index_history_ledgers_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_ledgers_on_id ON history_ledgers USING btree (id);


--
-- Name: index_history_ledgers_on_importer_version; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_ledgers_on_importer_version ON history_ledgers USING btree (importer_version);


--
-- Name: index_history_ledgers_on_ledger_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_ledgers_on_ledger_hash ON history_ledgers USING btree (ledger_hash);


--
-- Name: index_history_ledgers_on_previous_ledger_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_ledgers_on_previous_ledger_hash ON history_ledgers USING btree (previous_ledger_hash);


--
-- Name: index_history_ledgers_on_sequence; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_ledgers_on_sequence ON history_ledgers USING btree (sequence);


--
-- Name: index_history_operations_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_operations_on_id ON history_operations USING btree (id);


--
-- Name: index_history_operations_on_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_operations_on_transaction_id ON history_operations USING btree (transaction_id);


--
-- Name: index_history_operations_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_operations_on_type ON history_operations USING btree (type);


--
-- Name: index_history_transaction_participants_on_account; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_transaction_participants_on_account ON history_transaction_participants USING btree (account);


--
-- Name: index_history_transaction_participants_on_transaction_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_transaction_participants_on_transaction_hash ON history_transaction_participants USING btree (transaction_hash);


--
-- Name: index_history_transaction_statuses_lc_on_all; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_transaction_statuses_lc_on_all ON history_transaction_statuses USING btree (id, result_code, result_code_s);


--
-- Name: index_history_transactions_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_transactions_on_id ON history_transactions USING btree (id);


--
-- Name: trade_effects_by_order_book; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX trade_effects_by_order_book ON history_effects USING btree (((details ->> 'sold_asset_type'::text)), ((details ->> 'sold_asset_code'::text)), ((details ->> 'sold_asset_issuer'::text)), ((details ->> 'bought_asset_type'::text)), ((details ->> 'bought_asset_code'::text)), ((details ->> 'bought_asset_issuer'::text))) WHERE (type = 33);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM nullstyle;
GRANT ALL ON SCHEMA public TO nullstyle;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

