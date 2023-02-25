--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1

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
-- Name: func_handle_action(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.func_handle_action() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
match_result_extra match_result_view%ROWTYPE;

--create trigger to automatically updated to team_resutl when has the change of result table.
--select into statement: to copy data from old table to new table
BEGIN
select into match_result_extra * from match_result_view where id = new.match_id;
    if match_result_extra.home_result > match_result_extra.away_result then
        UPDATE team_results set win_match = win_match + 1,
                                goal_scored = goal_scored + match_result_extra.home_result,
                                goal_against = goal_against + match_result_extra.away_result
                         where team_id = match_result_extra.hometeam_id;
        UPDATE team_results set lost_match = lost_match + 1 ,
                                goal_scored = goal_scored + match_result_extra.away_result,
                                goal_against = goal_against + match_result_extra.home_result
                            where team_id = match_result_extra.awayteam_id;
                 return new;
    elseif match_result_extra.home_result < match_result_extra.away_result THEN
        UPDATE team_results set lost_match = lost_match + 1 ,
                                goal_scored=goal_scored+match_result_extra.home_result,
                                goal_against = goal_against + match_result_extra.away_result
                         where team_id=match_result_extra.hometeam_id;
        UPDATE team_results set win_match=win_match+1,
                                goal_scored=goal_scored+match_result_extra.away_result,
                                goal_against=goal_against+match_result_extra.home_result
            where team_id = match_result_extra.awayteam_id;
        return new;
    else 
         UPDATE team_results set draw_match=draw_match+1, 
                                 goal_scored =goal_scored+match_result_extra.home_result,
                                goal_against=goal_against+match_result_extra.away_result
                             where team_id=match_result_extra.hometeam_id;
            UPDATE team_results set draw_match=draw_match+1,
                                     goal_scored=goal_scored+match_result_extra.home_result,
                                goal_against=goal_against + match_result_extra.away_result
            where team_id = match_result_extra.awayteam_id;
      return new;
      end if;      

END;
$$;


ALTER FUNCTION public.func_handle_action() OWNER TO postgres;

--
-- Name: match_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.match_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.hometeam_id = NEW.awayteam_id THEN
        RAISE EXCEPTION 'Home team and away team cannot be the same';
    END IF;
    RETURN NEW;
END $$;


ALTER FUNCTION public.match_insert() OWNER TO postgres;

--
-- Name: team_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.team_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	declare team_id int;
begin 
	SELECT old.id INTO team_id;
	if exists(select * from matches where hometeam_id = team_id or awayteam_id = team_id)
	then 
		raise exception 'Cannot delete team with existing matches';
	end if;
	return new;
end;
$$;


ALTER FUNCTION public.team_delete() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: match_results; Type: TABLE; Schema: public; Owner: hunglai
--

CREATE TABLE public.match_results (
    id integer NOT NULL,
    match_id integer NOT NULL,
    home_result integer NOT NULL,
    away_result integer NOT NULL
);


ALTER TABLE public.match_results OWNER TO hunglai;

--
-- Name: matches; Type: TABLE; Schema: public; Owner: hunglai
--

CREATE TABLE public.matches (
    id integer NOT NULL,
    attendance integer,
    stadium_id integer NOT NULL,
    awayteam_id integer NOT NULL,
    hometeam_id integer NOT NULL,
    match_date date,
    "group" character varying(1),
    round integer
);


ALTER TABLE public.matches OWNER TO hunglai;

--
-- Name: match_result_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.match_result_view AS
 SELECT matches.id,
    matches.attendance,
    matches.stadium_id,
    matches.awayteam_id,
    matches.hometeam_id,
    matches.match_date,
    match_results.home_result,
    match_results.away_result
   FROM (public.matches
     JOIN public.match_results ON ((matches.id = match_results.match_id)));


ALTER TABLE public.match_result_view OWNER TO postgres;

--
-- Name: match_results_id_seq; Type: SEQUENCE; Schema: public; Owner: hunglai
--

CREATE SEQUENCE public.match_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.match_results_id_seq OWNER TO hunglai;

--
-- Name: match_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hunglai
--

ALTER SEQUENCE public.match_results_id_seq OWNED BY public.match_results.id;


--
-- Name: matches_id_seq; Type: SEQUENCE; Schema: public; Owner: hunglai
--

CREATE SEQUENCE public.matches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.matches_id_seq OWNER TO hunglai;

--
-- Name: matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hunglai
--

ALTER SEQUENCE public.matches_id_seq OWNED BY public.matches.id;


--
-- Name: players; Type: TABLE; Schema: public; Owner: hunglai
--

CREATE TABLE public.players (
    id integer NOT NULL,
    name character varying(50),
    team_id integer,
    age integer,
    "position" character varying(50),
    num_kit integer,
    nationality character varying(50)
);


ALTER TABLE public.players OWNER TO hunglai;

--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: hunglai
--

CREATE SEQUENCE public.players_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.players_id_seq OWNER TO hunglai;

--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hunglai
--

ALTER SEQUENCE public.players_id_seq OWNED BY public.players.id;


--
-- Name: scores; Type: TABLE; Schema: public; Owner: hunglai
--

CREATE TABLE public.scores (
    id integer NOT NULL,
    scorer_id integer NOT NULL,
    assist_id integer,
    own_goal boolean NOT NULL,
    match_id integer NOT NULL
);


ALTER TABLE public.scores OWNER TO hunglai;

--
-- Name: scores_id_seq; Type: SEQUENCE; Schema: public; Owner: hunglai
--

CREATE SEQUENCE public.scores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scores_id_seq OWNER TO hunglai;

--
-- Name: scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hunglai
--

ALTER SEQUENCE public.scores_id_seq OWNED BY public.scores.id;


--
-- Name: stadiums; Type: TABLE; Schema: public; Owner: hunglai
--

CREATE TABLE public.stadiums (
    id integer NOT NULL,
    name character varying(50),
    team_id integer,
    capacity integer,
    address character varying
);


ALTER TABLE public.stadiums OWNER TO hunglai;

--
-- Name: stadiums_id_seq; Type: SEQUENCE; Schema: public; Owner: hunglai
--

CREATE SEQUENCE public.stadiums_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stadiums_id_seq OWNER TO hunglai;

--
-- Name: stadiums_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hunglai
--

ALTER SEQUENCE public.stadiums_id_seq OWNED BY public.stadiums.id;


--
-- Name: team_links; Type: TABLE; Schema: public; Owner: hunglai
--

CREATE TABLE public.team_links (
    id integer NOT NULL,
    team_name character varying,
    info_team_url character varying,
    squad_url character varying
);


ALTER TABLE public.team_links OWNER TO hunglai;

--
-- Name: team_links_id_seq; Type: SEQUENCE; Schema: public; Owner: hunglai
--

CREATE SEQUENCE public.team_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.team_links_id_seq OWNER TO hunglai;

--
-- Name: team_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hunglai
--

ALTER SEQUENCE public.team_links_id_seq OWNED BY public.team_links.id;


--
-- Name: team_results; Type: TABLE; Schema: public; Owner: hunglai
--

CREATE TABLE public.team_results (
    id integer NOT NULL,
    team_id integer NOT NULL,
    win_match integer,
    draw_match integer,
    lost_match integer,
    goal_scored integer,
    goal_against integer
);


ALTER TABLE public.team_results OWNER TO hunglai;

--
-- Name: team_results_id_seq; Type: SEQUENCE; Schema: public; Owner: hunglai
--

CREATE SEQUENCE public.team_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.team_results_id_seq OWNER TO hunglai;

--
-- Name: team_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hunglai
--

ALTER SEQUENCE public.team_results_id_seq OWNED BY public.team_results.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: hunglai
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    coach_names character varying(50)[],
    team_name character varying(50),
    color_kit character varying(50),
    team_logo character varying,
    head_coach_name character varying(50)
);


ALTER TABLE public.teams OWNER TO hunglai;

--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: hunglai
--

CREATE SEQUENCE public.teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teams_id_seq OWNER TO hunglai;

--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hunglai
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: match_results id; Type: DEFAULT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.match_results ALTER COLUMN id SET DEFAULT nextval('public.match_results_id_seq'::regclass);


--
-- Name: matches id; Type: DEFAULT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.matches ALTER COLUMN id SET DEFAULT nextval('public.matches_id_seq'::regclass);


--
-- Name: players id; Type: DEFAULT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.players ALTER COLUMN id SET DEFAULT nextval('public.players_id_seq'::regclass);


--
-- Name: scores id; Type: DEFAULT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.scores ALTER COLUMN id SET DEFAULT nextval('public.scores_id_seq'::regclass);


--
-- Name: stadiums id; Type: DEFAULT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.stadiums ALTER COLUMN id SET DEFAULT nextval('public.stadiums_id_seq'::regclass);


--
-- Name: team_links id; Type: DEFAULT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.team_links ALTER COLUMN id SET DEFAULT nextval('public.team_links_id_seq'::regclass);


--
-- Name: team_results id; Type: DEFAULT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.team_results ALTER COLUMN id SET DEFAULT nextval('public.team_results_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Data for Name: match_results; Type: TABLE DATA; Schema: public; Owner: hunglai
--

COPY public.match_results (id, match_id, home_result, away_result) FROM stdin;
1	1	1	1
2	2	1	1
3	3	2	0
4	4	1	3
5	5	6	0
6	6	3	0
7	7	1	2
8	8	2	3
9	9	2	2
10	10	0	0
11	11	1	4
12	12	2	2
13	13	1	2
14	14	1	1
15	15	1	1
16	16	4	2
17	17	0	2
18	18	2	3
19	19	1	1
20	20	1	0
21	21	3	3
22	22	0	0
23	23	6	0
24	24	1	2
25	25	7	0
26	26	4	0
27	27	1	2
28	28	3	3
29	29	0	2
30	30	4	0
31	31	1	1
32	32	3	1
33	33	1	1
34	34	0	2
35	35	4	0
36	36	1	1
37	37	5	0
38	38	0	1
39	39	1	0
40	40	2	2
41	41	4	1
42	42	0	1
43	43	2	1
44	44	1	2
45	45	3	2
46	46	2	0
47	47	1	0
48	48	0	0
49	49	2	2
50	50	1	2
51	51	1	1
52	52	0	1
53	53	0	0
54	54	1	1
55	55	3	0
56	56	0	1
57	57	1	1
58	58	2	1
59	59	3	0
60	60	3	1
61	61	0	6
62	62	2	1
63	63	2	2
64	64	2	0
65	65	5	1
66	66	1	2
67	67	1	0
68	68	3	3
69	69	8	4
70	70	1	2
71	71	1	0
72	72	2	2
73	73	0	3
74	74	1	1
75	75	4	0
76	76	1	0
77	77	1	2
78	78	1	0
79	79	0	0
80	80	1	0
81	81	0	0
82	82	2	1
83	83	0	2
84	84	5	0
85	85	0	0
86	86	3	0
87	87	0	4
88	88	1	0
89	89	0	1
90	90	0	1
91	91	1	1
92	92	4	0
93	93	0	1
94	94	1	3
95	95	2	0
96	96	0	0
97	97	1	0
98	98	4	0
99	99	3	1
100	100	5	1
101	101	5	3
102	102	2	4
103	103	0	2
104	104	2	1
105	105	1	3
106	106	1	5
107	107	4	0
108	108	6	1
109	109	1	0
110	110	2	0
111	111	3	1
112	112	0	0
113	113	3	0
114	114	2	3
115	115	1	0
116	116	1	2
117	117	1	1
118	118	4	2
119	119	0	0
120	120	3	1
121	121	3	0
122	122	0	2
123	123	2	1
124	124	2	1
125	125	1	4
\.


--
-- Data for Name: matches; Type: TABLE DATA; Schema: public; Owner: hunglai
--

COPY public.matches (id, attendance, stadium_id, awayteam_id, hometeam_id, match_date, "group", round) FROM stdin;
1	30852	15	25	15	2016-09-13	A	1
2	46440	24	1	24	2016-09-13	A	1
3	59993	1	15	1	2016-09-28	A	2
4	17155	33	24	25	2016-09-28	A	2
5	59944	1	25	1	2016-10-19	A	3
6	46488	24	15	24	2016-10-19	A	3
7	34639	15	24	15	2016-11-01	A	4
8	30862	33	1	25	2016-11-01	A	4
9	59628	1	24	1	2016-11-23	A	5
10	20821	33	15	25	2016-11-23	A	5
11	36000	15	1	15	2016-12-06	A	6
12	42650	24	25	24	2016-12-06	A	6
13	35137	12	31	12	2016-09-13	B	1
14	42126	29	6	29	2016-09-13	B	1
15	33938	6	12	6	2016-09-28	B	2
16	41281	31	29	31	2016-09-28	B	2
17	25991	12	29	12	2016-10-19	B	3
18	28502	31	6	31	2016-10-19	B	3
19	35552	6	31	6	2016-11-01	B	4
20	51641	29	12	29	2016-11-01	B	4
21	36063	6	29	6	2016-11-23	B	5
22	33736	31	12	31	2016-11-23	B	5
23	14036	12	6	12	2016-12-06	B	6
24	55634	29	31	29	2016-12-06	B	6
25	73290	14	9	14	2016-09-13	C	1
26	30270	22	7	22	2016-09-14	C	1
27	46283	7	14	7	2016-09-28	C	2
28	57592	9	22	9	2016-09-28	C	2
29	57814	9	7	9	2016-10-19	C	3
30	96290	14	22	14	2016-10-19	C	3
31	46283	7	9	7	2016-11-01	C	4
32	53340	22	14	22	2016-11-01	C	4
33	45921	7	22	7	2016-11-23	C	5
34	57937	9	14	9	2016-11-23	C	5
35	67157	14	7	14	2016-12-06	C	6
36	51297	22	9	22	2016-12-06	C	6
37	70000	5	18	5	2016-09-13	D	1
38	33989	26	3	26	2016-09-13	D	1
39	48242	34	5	3	2016-09-28	D	2
40	12646	35	26	18	2016-09-28	D	2
41	70000	5	26	5	2016-10-19	D	3
42	15400	35	3	18	2016-10-19	D	3
43	40392	34	18	3	2016-11-01	D	4
44	35000	26	5	26	2016-11-01	D	4
45	15211	35	5	18	2016-11-23	D	5
46	37891	34	26	3	2016-11-23	D	5
47	70000	5	3	5	2016-12-06	D	6
48	33400	26	18	26	2016-12-06	D	6
49	23459	4	11	4	2016-09-14	E	1
50	85011	36	2	32	2016-09-14	E	1
51	8100	2	4	2	2016-09-27	E	2
52	26153	37	32	11	2016-09-27	E	2
53	28887	4	32	4	2016-10-18	E	3
54	24125	11	2	11	2016-10-18	E	3
55	10029	2	11	2	2016-11-02	E	4
56	85512	36	4	32	2016-11-02	E	4
57	19164	11	4	11	2016-11-22	E	5
58	13100	2	32	2	2016-11-22	E	5
59	21928	4	2	4	2016-12-07	E	6
60	62034	36	11	32	2016-12-07	E	6
61	27304	20	8	20	2016-09-14	F	1
62	72179	27	30	27	2016-09-14	F	1
63	65849	8	27	8	2016-09-27	F	2
64	40094	30	20	30	2016-09-27	F	2
65	70251	27	20	27	2016-10-18	F	3
66	46609	30	8	30	2016-10-18	F	3
67	65849	8	30	8	2016-11-02	F	4
68	\N	20	27	20	2016-11-02	F	4
69	55094	8	20	8	2016-11-22	F	5
70	50046	30	27	30	2016-11-22	F	5
71	28232	20	30	20	2016-12-07	F	6
72	76894	27	8	27	2016-12-07	F	6
73	20970	10	21	10	2016-09-14	G	1
74	34325	17	16	17	2016-09-14	G	1
75	25605	16	10	16	2016-09-27	G	2
76	31805	21	17	21	2016-09-27	G	2
77	23325	10	17	10	2016-10-18	G	3
78	31037	21	16	21	2016-10-18	G	3
79	34146	16	21	16	2016-11-02	G	4
80	32310	17	10	17	2016-11-02	G	4
81	32036	16	17	16	2016-11-22	G	5
82	31443	21	10	21	2016-11-22	G	5
83	18981	10	16	10	2016-12-07	G	6
84	39310	17	21	17	2016-12-07	G	6
85	33261	19	28	19	2016-09-14	H	1
86	43754	23	13	23	2016-09-14	H	1
87	23875	13	19	13	2016-09-27	H	2
88	36741	28	23	28	2016-09-27	H	2
89	6021	13	28	13	2016-10-18	H	3
90	53907	23	19	23	2016-10-18	H	3
91	40356	19	23	19	2016-11-02	H	4
92	35215	28	13	28	2016-11-02	H	4
93	7834	13	23	13	2016-11-22	H	5
94	38942	28	19	28	2016-11-22	H	5
95	39380	19	13	19	2016-12-07	H	6
96	52423	23	28	23	2016-12-07	H	6
97	55124	29	8	29	2017-02-14	\N	7
98	46484	24	14	24	2017-02-14	\N	7
99	78000	27	31	27	2017-02-15	\N	7
100	70000	5	1	5	2017-02-15	\N	7
101	53351	22	2	22	2017-02-21	\N	7
102	29300	4	3	4	2017-02-21	\N	7
103	49229	17	19	17	2017-02-22	\N	7
104	38834	28	21	28	2017-02-22	\N	7
105	56695	31	27	31	2017-03-07	\N	7
106	59911	1	5	1	2017-03-07	\N	7
107	65849	8	29	8	2017-03-08	\N	7
108	96290	14	24	14	2017-03-08	\N	7
109	41161	19	17	19	2017-03-14	\N	7
110	31520	21	28	21	2017-03-14	\N	7
111	15700	2	22	2	2017-03-15	\N	7
112	49133	34	4	3	2017-03-15	\N	7
113	41092	19	14	19	2017-04-11	\N	8
114	65849	8	2	8	2017-04-12	\N	8
115	51423	34	21	3	2017-04-12	\N	8
116	70000	5	27	5	2017-04-12	\N	8
117	31548	21	3	21	2017-04-18	\N	8
118	78346	27	5	27	2017-04-18	\N	8
119	96290	14	19	14	2017-04-19	\N	8
120	17135	2	8	2	2017-04-19	\N	8
121	77609	27	3	27	2017-05-02	\N	9
122	16762	2	19	2	2017-05-03	\N	9
123	40244	19	2	19	2017-05-09	\N	9
124	53422	34	27	3	2017-05-10	\N	9
125	65842	38	27	19	2017-06-03	\N	10
\.


--
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: hunglai
--

COPY public.players (id, name, team_id, age, "position", num_kit, nationality) FROM stdin;
1	Mathieu Debuchy	1	32	Defender	2	France
2	Gabriel Paulista	1	27	Defender	5	Brazil
3	Kieran Gibbs	1	28	Defender	3	England
4	Héctor Bellerín	1	22	Defender	24	Spain
5	Rob Holding	1	22	Defender	16	England
6	Carl Jenkinson	1	25	Defender	25	England
7	Laurent Koscielny	1	32	Defender	6	France
8	Per Mertesacker	1	33	Defender	4	Germany
9	Shkodran Mustafi	1	25	Defender	20	Germany
10	Nacho Monreal	1	31	Defender	18	Spain
11	Olivier Giroud	1	31	Forward	12	France
12	Alex Iwobi	1	21	Forward	17	Nigeria
13	Lucas Pérez	1	29	Forward	9	Spain
14	Alex Oxlade-Chamberlain	1	24	Forward	15	England
15	Alexis Sánchez	1	29	Forward	7	Chile
16	Yaya Sanogo	1	24	Forward	22	France
17	Theo Walcott	1	28	Forward	14	England
18	Danny Welbeck	1	27	Forward	23	England
19	Chris Willock	1	19	Forward	68	England
20	Petr Čech	1	35	Goalkeeper	33	Czech Republic
21	Matt Macey	1	23	Goalkeeper	54	England
22	Emiliano Martínez	1	25	Goalkeeper	26	Argentina
23	David Ospina	1	29	Goalkeeper	13	Colombia
24	Francis Coquelin	1	26	Midfielder	34	France
25	Joshua Dasilva	1	19	Midfielder	41	England
26	Mohamed Elneny	1	25	Midfielder	35	Egypt
27	Ainsley Maitland-Niles	1	20	Midfielder	55	England
28	Mesut Özil	1	29	Midfielder	11	Germany
29	Aaron Ramsey	1	27	Midfielder	8	Wales
30	Jeff Reine-Adélaïde	1	19	Midfielder	22	France
31	Santi Cazorla	1	33	Midfielder	19	Spain
32	Ben Sheaf	1	19	Midfielder	65	England
33	Granit Xhaka	1	25	Midfielder	29	Switzerland
34	Kouadio-Yves Dabila	2	20	Defender	45	Ivory Coast
35	Abdou Diallo	2	21	Defender	34	Senegal
36	Nabil Dirar	2	31	Defender	7	Morocco
37	Kamil Glik	2	29	Defender	25	Poland
38	Jemerson	2	25	Defender	5	Brazil
39	Jorge	2	21	Defender	6	Brazil
40	Safwan Mbaé	2	20	Defender	46	Comoros
41	Benjamin Mendy	2	23	Defender	23	France
42	Kévin N'Doram	2	21	Defender	35	France
43	Pierre-Daniel Nguinda	2	21	Defender	45	Cameroon
44	Andrea Raggi	2	33	Defender	24	Italy
45	Djibril Sidibé	2	25	Defender	19	France
46	Almamy Touré	2	21	Defender	38	France
47	Yhoan Andzouana	2	21	Forward	41	Congo
48	Irvin Cardona	2	20	Forward	37	France
49	Guido Carrillo	2	26	Forward	11	Argentina
50	Radamel Falcao	2	31	Forward	9	Colombia
51	Valère Germain	2	27	Forward	18	France
52	Thomas Lemar	2	22	Forward	27	France
53	Kylian Mbappé	2	19	Forward	29	France
54	Corentin Tirard	2	22	Forward	45	France
55	Loïc Badiashile	2	19	Goalkeeper	40	France
56	Morgan De Sanctis	2	40	Goalkeeper	16	Italy
57	Danijel Subašić	2	33	Goalkeeper	1	Croatia
58	Seydou Sy	2	22	Goalkeeper	30	Senegal
59	Tiemoué Bakayoko	2	23	Midfielder	14	France
60	Dylan Beaulieu	2	20	Midfielder	43	France
61	Bernardo Silva	2	23	Midfielder	10	Portugal
62	Adrien Bongiovanni	2	18	Midfielder	44	Belgium
63	Boschilia	2	21	Midfielder	26	Brazil
64	Fabinho	2	24	Midfielder	2	Brazil
65	João Moutinho	2	31	Midfielder	8	Portugal
66	Tristan Muyumba	2	20	Midfielder	47	France
67	Álex García	3	23	Defender	31	Spain
68	Filipe Luís	3	32	Defender	3	Brazil
69	José Giménez	3	22	Defender	24	Uruguay
70	Diego Godín	3	31	Defender	2	Uruguay
71	Lucas Hernández	3	21	Defender	19	France
72	Juanfran	3	32	Defender	20	Spain
73	Rafa Muñoz	3	23	Defender	32	Spain
74	Stefan Savić	3	26	Defender	15	Montenegro
75	Tachi	3	20	Defender	37	Spain
76	Šime Vrsaljko	3	25	Defender	16	Croatia
77	Mohammed Boulahia Zaka	3	20	Forward	48	Algeria
78	Alessio Cerci	3	30	Forward	17	Italy
79	Ángel Correa	3	22	Forward	11	Argentina
80	Fernando Torres	3	33	Forward	9	Spain
81	Kevin Gameiro	3	30	Forward	21	France
82	Antoine Griezmann	3	26	Forward	7	France
83	Rober Mañas	3	21	Forward	42	Spain
84	Nicolás Schiappacasse	3	18	Forward	28	Uruguay
85	André Moreira	3	22	Goalkeeper	25	Portugal
86	Bernabé	3	24	Goalkeeper	31	Spain
87	Moyá	3	33	Goalkeeper	1	Spain
88	Jan Oblak	3	24	Goalkeeper	13	Slovenia
89	Keidi Bare	3	20	Midfielder	44	Albania
90	Caio Henrique	3	20	Midfielder	27	Brazil
91	Yannick Carrasco	3	24	Midfielder	10	Belgium
92	Augusto Fernández	3	31	Midfielder	12	Argentina
93	Ferni	3	19	Midfielder	45	Spain
94	Gabi	3	34	Midfielder	14	Spain
95	Nicolás Gaitán	3	29	Midfielder	23	Argentina
96	Juan Moreno	3	20	Midfielder	39	Spain
97	Koke	3	25	Midfielder	6	Spain
98	Thomas Partey	3	24	Midfielder	22	Ghana
99	Roberto Olabe	3	21	Midfielder	34	Spain
100	Saúl	3	23	Midfielder	8	Spain
101	Tiago	3	36	Midfielder	5	Portugal
102	Toni Moya	3	19	Midfielder	46	Spain
103	Joel Abu Hanna	4	19	Defender	22	Israel
104	Danny da Costa	4	24	Defender	23	Germany
105	Aleksandar Dragović	4	26	Defender	6	Austria
106	Benjamin Henrichs	4	20	Defender	39	Germany
107	Roberto Hilbert	4	33	Defender	13	Germany
108	Tin Jedvaj	4	22	Defender	16	Croatia
109	Jonathan Tah	4	21	Defender	4	Germany
110	Ömer Toprak	4	28	Defender	21	Turkey
111	Wendell	4	24	Defender	18	Brazil
112	Leon Bailey	4	20	Forward	9	Jamaica
113	Karim Bellarabi	4	27	Forward	38	Germany
114	Javier Hernández	4	29	Forward	7	Mexico
115	Stefan Kießling	4	33	Forward	11	Germany
116	Admir Mehmedi	4	26	Forward	14	Switzerland
117	Joel Pohjanpalo	4	23	Forward	17	Finland
118	Kevin Volland	4	25	Forward	31	Germany
119	Bernd Leno	4	25	Goalkeeper	1	Germany
120	Niklas Lomb	4	24	Goalkeeper	36	Germany
121	Ramazan Özcan	4	33	Goalkeeper	28	Austria
122	Atakan Akkaynak	4	18	Midfielder	37	Germany
123	Charles Aránguiz	4	28	Midfielder	20	Chile
124	Julian Baumgartlinger	4	29	Midfielder	15	Austria
125	Lars Bender	4	28	Midfielder	8	Germany
126	Julian Brandt	4	21	Midfielder	19	Germany
127	Hakan Çalhanoğlu	4	23	Midfielder	10	Turkey
128	Kai Havertz	4	18	Midfielder	29	Germany
129	Kevin Kampl	4	27	Midfielder	44	Slovenia
130	Sam Schreck	4	18	Midfielder	30	Germany
131	Vladlen Yurchenko	4	23	Midfielder	35	Ukraine
132	David Alaba	5	25	Defender	27	Austria
133	Jérôme Boateng	5	29	Defender	17	Germany
134	Nicolas Feldhahn	5	31	Defender	39	Germany
135	Marco Friedl	5	19	Defender	34	Austria
136	Mats Hummels	5	29	Defender	5	Germany
137	Javi Martínez	5	29	Defender	8	Spain
138	Juan Bernat	5	24	Defender	18	Spain
139	Philipp Lahm	5	34	Defender	21	Germany
140	Rafinha	5	32	Defender	13	Brazil
141	Kingsley Coman	5	21	Forward	29	France
142	Douglas Costa	5	27	Forward	11	Brazil
143	Robert Lewandowski	5	29	Forward	9	Poland
144	Thomas Müller	5	28	Forward	25	Germany
145	Franck Ribéry	5	34	Forward	7	France
146	Arjen Robben	5	33	Forward	10	Netherlands
147	Manuel Neuer	5	31	Goalkeeper	1	Germany
148	Tom Starke	5	36	Goalkeeper	22	Germany
149	Sven Ulreich	5	29	Goalkeeper	26	Germany
150	Leo Weinkauf	5	21	Goalkeeper	37	Germany
151	Fabian Benko	5	19	Midfielder	40	Germany
152	Niklas Dorsch	5	19	Midfielder	30	Germany
153	Felix Götze	5	19	Midfielder	20	Germany
154	Joshua Kimmich	5	22	Midfielder	32	Germany
155	Raphael Obermair	5	21	Midfielder	15	Germany
156	Erdal Öztürk	5	21	Midfielder	38	Germany
157	Renato Sanches	5	20	Midfielder	35	Portugal
158	Thiago	5	26	Midfielder	6	Spain
159	Arturo Vidal	5	30	Midfielder	23	Chile
160	Xabi Alonso	5	36	Midfielder	14	Spain
161	Adriano	6	33	Defender	3	Brazil
162	Fatih Aksoy	6	20	Defender	14	Turkey
163	Andreas Beck	6	30	Defender	32	Germany
164	Muhammed Can	6	20	Defender	55	Turkey
165	Caner Erkin	6	29	Defender	88	Turkey
166	Gökhan Gönül	6	32	Defender	77	Turkey
167	Ersan Gülüm	6	30	Defender	4	Turkey
168	Marcelo	6	30	Defender	30	Brazil
169	Matej Mitrović	6	24	Defender	2	Croatia
170	Atınç Nukan	6	24	Defender	33	Turkey
171	Duško Tošić	6	32	Defender	6	Serbia
172	Sezer Yıldırım	6	21	Defender	34	Turkey
173	Vincent Aboubakar	6	25	Forward	9	Cameroon
174	Demba Ba	6	32	Forward	99	Senegal
175	Ryan Babel	6	31	Forward	49	Netherlands
176	Muhammed Durmuş	6	20	Forward	67	Turkey
177	Hamza Küçükköylü	6	21	Forward	50	Turkey
178	Ricardo Quaresma	6	34	Forward	7	Portugal
179	Ömer Şişmanoğlu	6	28	Forward	17	Turkey
180	Cenk Tosun	6	26	Forward	23	Turkey
181	Fabricio	6	30	Goalkeeper	1	Spain
182	Hüseyin Yılmaz	6	21	Goalkeeper	54	Turkey
183	Utku Yuvakuran	6	20	Goalkeeper	97	Turkey
184	Tolga Zengin	6	34	Goalkeeper	29	Turkey
185	Anderson Talisca	6	23	Midfielder	94	Brazil
186	Tolgay Arslan	6	27	Midfielder	18	Germany
187	Oğuzhan Aydoğan	6	20	Midfielder	19	Germany
188	Atiba Hutchinson	6	34	Midfielder	13	Canada
189	Gökhan Inler	6	33	Midfielder	80	Switzerland
190	Veli Kavlak	6	29	Midfielder	8	Austria
191	Aras Özbiliz	6	27	Midfielder	22	Armenia
192	Eslem Öztürk	6	20	Midfielder	41	Turkey
193	Oğuzhan Özyakup	6	25	Midfielder	15	Turkey
194	Sedat Şahintürk	6	21	Midfielder	70	Turkey
195	Ibrahim Tekeli	6	20	Midfielder	26	Turkey
196	Necip Uysal	6	26	Midfielder	20	Turkey
197	Andreas Christensen	7	21	Defender	3	Denmark
198	Mamadou Doucouré	7	19	Defender	29	France
199	Nico Elvedi	7	21	Defender	30	Switzerland
200	Tony Jantschke	7	27	Defender	24	Germany
201	Timothée Kolodziejczak	7	26	Defender	25	France
202	Julian Korb	7	25	Defender	27	Germany
203	Marvin Schulz	7	22	Defender	15	Germany
204	Nico Schulz	7	24	Defender	14	Germany
205	Jannik Vestergaard	7	25	Defender	4	Denmark
206	Oscar Wendt	7	32	Defender	17	Sweden
207	Josip Drmić	7	25	Forward	9	Switzerland
208	Mike Feigenspan	7	22	Forward	47	Germany
209	André Hahn	7	27	Forward	28	Germany
210	Thorgan Hazard	7	24	Forward	10	Belgium
211	Patrick Herrmann	7	26	Forward	7	Germany
212	Jonas Hofmann	7	25	Forward	23	Germany
213	Raffael	7	32	Forward	11	Brazil
214	Ba-Muaka Simakala	7	20	Forward	44	Germany
215	Ibrahima Traoré	7	29	Forward	16	Guinea
216	Christofer Heimeroth	7	36	Goalkeeper	33	Germany
217	Moritz Nicolas	7	20	Goalkeeper	35	Germany
218	Tobias Sippel	7	29	Goalkeeper	21	Germany
219	Yann Sommer	7	29	Goalkeeper	1	Switzerland
220	László Bénes	7	20	Midfielder	22	Slovakia
221	Mahmoud Dahoud	7	21	Midfielder	8	Germany
222	Fabian Johnson	7	30	Midfielder	19	USA
223	Christoph Kramer	7	26	Midfielder	6	Germany
224	Tsiy Ndenge	7	20	Midfielder	26	Germany
225	Nils Rütten	7	22	Midfielder	36	Germany
226	Djibril Sow	7	20	Midfielder	20	Switzerland
227	Lars Stindl	7	29	Midfielder	13	Germany
228	Tobias Strobl	7	27	Midfielder	5	Germany
229	Bartra	8	26	Defender	5	Spain
230	Sven Bender	8	28	Defender	6	Germany
231	Erik Durm	8	25	Defender	37	Germany
232	Matthias Ginter	8	23	Defender	28	Germany
233	Raphaël Guerreiro	8	24	Defender	13	Portugal
234	Sokratis Papastathopoulos	8	29	Defender	25	Greece
235	Joo-ho Park	8	30	Defender	3	South Korea
236	Łukasz Piszczek	8	32	Defender	26	Poland
237	Marcel Schmelzer	8	29	Defender	29	Germany
238	Pierre-Emerick Aubameyang	8	28	Forward	17	Gabon
239	Jacob Bruun Larsen	8	19	Forward	34	Denmark
240	Ousmane Dembélé	8	20	Forward	7	France
241	Alexander Isak	8	18	Forward	14	Sweden
242	Emre Mor	8	20	Forward	9	Turkey
243	Christian Pulišić	8	19	Forward	22	USA
244	André Schürrle	8	27	Forward	21	Germany
245	Hendrik Bonmann	8	23	Goalkeeper	39	Germany
246	Roman Bürki	8	27	Goalkeeper	38	Switzerland
247	Roman Weidenfeller	8	37	Goalkeeper	1	Germany
248	Dženis Burnić	8	19	Midfielder	32	Germany
249	Gonzalo Castro	8	30	Midfielder	27	Germany
250	Mario Götze	8	25	Midfielder	10	Germany
251	Shinji Kagawa	8	28	Midfielder	23	Japan
252	Mikel Merino	8	21	Midfielder	24	Spain
253	Felix Passlack	8	19	Midfielder	30	Germany
254	Marco Reus	8	28	Midfielder	11	Germany
255	Sebastian Rode	8	27	Midfielder	18	Germany
256	Nuri Şahin	8	29	Midfielder	8	Turkey
257	Julian Weigl	8	22	Midfielder	33	Germany
258	Dedryck Boyata	9	27	Defender	20	Belgium
259	Cristian Gamboa	9	28	Defender	12	Costa Rica
260	Emilio Izaguirre	9	31	Defender	3	Honduras
261	Fiacre Kelleher	9	21	Defender	\N	Ireland
262	Mikael Lustig	9	31	Defender	23	Sweden
263	Tony Ralston	9	19	Defender	56	Scotland
264	Jozo Šimunović	9	23	Defender	5	Croatia
265	Erik Sviatchenko	9	26	Defender	28	Denmark
266	Kieran Tierney	9	20	Defender	63	Scotland
267	Kolo Touré	9	36	Defender	2	Ivory Coast
268	Jack Aitchison	9	17	Forward	76	Scotland
269	Moussa Dembélé	9	21	Forward	10	France
270	Luke Donnelly	9	21	Forward	31	Scotland
271	James Forrest	9	26	Forward	49	Scotland
272	Leigh Griffiths	9	27	Forward	9	Scotland
273	Mikey Johnston	9	18	Forward	73	Scotland
274	Paul McMullan	9	21	Forward	\N	Scotland
275	Calvin Miller	9	19	Forward	60	Scotland
276	Logan Bailly	9	32	Goalkeeper	26	Belgium
277	Dorus de Vries	9	37	Goalkeeper	24	Netherlands
278	Craig Gordon	9	35	Goalkeeper	1	Scotland
279	Conor Hazard	9	19	Goalkeeper	65	Northern Ireland
280	Stuart Armstrong	9	25	Midfielder	14	Scotland
281	Nir Bitton	9	26	Midfielder	6	Israel
282	Scott Brown	9	32	Midfielder	8	Scotland
283	Liam Henderson	9	21	Midfielder	53	Scotland
284	Regan Hendry	9	19	Midfielder	62	Scotland
285	Mark Hill	9	19	Midfielder	58	Scotland
286	Eboue Kouassi	9	20	Midfielder	88	Ivory Coast
287	Gary Mackay-Steven	9	27	Midfielder	16	Scotland
288	Callum McGregor	9	24	Midfielder	42	Scotland
289	Conor McManus	9	21	Midfielder	\N	Scotland
290	Patrick Roberts	9	20	Midfielder	27	England
291	Tom Rogić	9	25	Midfielder	18	Australia
292	Scott Sinclair	9	28	Midfielder	11	England
293	Boli Bolingoli-Mbombo	10	22	Defender	63	Belgium
294	Dion Cools	10	21	Defender	21	Malaysia
295	Laurens De Bock	10	25	Defender	28	Belgium
296	Stefano Denswil	10	24	Defender	24	Netherlands
297	Björn Engels	10	23	Defender	4	Belgium
298	Laurent Lemoine	10	19	Defender	89	Belgium
299	Helibelton Palacios	10	24	Defender	13	Colombia
300	Benoît Poulain	10	30	Defender	5	France
301	Ahmed Touba	10	19	Defender	23	Algeria
302	Ricardo van Rhijn	10	26	Defender	2	Netherlands
303	Niels Verburgh	10	19	Defender	80	Belgium
304	Fran Brodić	10	20	Forward	14	Croatia
305	Abdoulay Diaby	10	26	Forward	10	Mali
306	José Izquierdo	10	25	Forward	11	Colombia
307	Anthony Limbombe	10	23	Forward	17	Belgium
308	Terry Osei-Berkoe	10	19	Forward	90	Belgium
309	Lior Refaelov	10	31	Forward	8	Israel
310	Dorin Rotariu	10	22	Forward	29	Romania
311	Thibault Vlietinck	10	20	Forward	93	Belgium
312	Jelle Vossen	10	28	Forward	9	Belgium
313	Wesley	10	21	Forward	7	Brazil
314	Ludovic Butelle	10	34	Goalkeeper	1	France
315	Ethan Horvath	10	22	Goalkeeper	22	USA
316	Jens Teunckens	10	19	Goalkeeper	41	Belgium
317	Claudemir	10	29	Midfielder	6	Brazil
318	Lex Immers	10	31	Midfielder	27	Netherlands
319	Pina	10	30	Midfielder	15	Spain
320	Timmy Simons	10	41	Midfielder	3	Belgium
321	Hans Vanaken	10	25	Midfielder	20	Belgium
322	Ruud Vormer	10	29	Midfielder	25	Netherlands
323	Mutalip Alibekov	11	20	Defender	\N	Russia
324	Aleksey Berezutskiy	11	35	Defender	6	Russia
325	Vasiliy Berezutskiy	11	35	Defender	24	Russia
326	Sergey Ignashevich	11	38	Defender	4	Russia
327	Ivan Maklakov	11	19	Defender	\N	Russia
328	Mário Fernandes	11	27	Defender	2	Russia
329	Kirill Nababkin	11	31	Defender	14	Russia
330	Georgiy Shchennikov	11	26	Defender	42	Russia
331	Viktor Vasin	11	29	Defender	5	Russia
332	Fedor Chalov	11	19	Forward	63	Russia
333	Aaron Olanare	11	23	Forward	99	Nigeria
334	Vitinho	11	24	Forward	20	Brazil
335	Timur Zhamaletdinov	11	20	Forward	75	Russia
336	Igor Akinfeev	11	31	Goalkeeper	35	Russia
337	Sergey Chepchugov	11	32	Goalkeeper	1	Russia
338	Pavel Ovchinnikov	11	19	Goalkeeper	84	Russia
339	Ilya Pomazun	11	21	Goalkeeper	45	Russia
340	Alan Dzagoev	11	27	Midfielder	10	Russia
341	Roman Eremenko	11	30	Midfielder	25	Finland
342	Aleksandr Golovin	11	21	Midfielder	17	Russia
343	Astemir Gordyushenko	11	20	Midfielder	72	Russia
344	Aleksey Ionov	11	28	Midfielder	11	Russia
345	Khetag Khosonov	11	19	Midfielder	80	Russia
346	Konstantin Kuchaev	11	19	Midfielder	89	Russia
347	Georgi Milanov	11	25	Midfielder	8	Bulgaria
348	Bibras Natcho	11	29	Midfielder	66	Israel
349	Ivan Oleynikov	11	19	Midfielder	82	Russia
350	Timur Pukhov	11	19	Midfielder	\N	Russia
351	Zoran Tošić	11	30	Midfielder	7	Serbia
352	Pontus Wernbloom	11	31	Midfielder	3	Sweden
353	Antunes	12	30	Defender	5	Portugal
354	Mykyta Burda	12	22	Defender	6	Ukraine
355	Tamás Kádár	12	27	Defender	44	Hungary
356	Yevhen Khacheridi	12	30	Defender	34	Ukraine
357	Pavlo Lukyanchuk	12	21	Defender	42	Ukraine
358	Bogdan Mykhaylychenko	12	20	Defender	22	Ukraine
359	Zurab Ochihava	12	22	Defender	14	Ukraine
360	Aleksandar Pantić	12	25	Defender	4	Serbia
361	Oleksandr Tymchyk	12	20	Defender	40	Ukraine
362	Domagoj Vida	12	28	Defender	24	Croatia
363	Artem Besedin	12	21	Forward	41	Ukraine
364	Derlis González	12	23	Forward	25	Paraguay
365	Viktor Tsygankov	12	20	Forward	15	Ukraine
366	Roman Yaremchuk	12	22	Forward	20	Ukraine
367	Andrey Yarmolenko	12	28	Forward	10	Ukraine
368	Maksim Koval	12	25	Goalkeeper	35	Ukraine
369	Artur Rudko	12	25	Goalkeeper	72	Ukraine
370	Vitaliy Buyalskyi	12	24	Midfielder	29	Ukraine
371	Valeriy Fedorchuk	12	29	Midfielder	32	Ukraine
372	Denys Garmash	12	27	Midfielder	19	Ukraine
373	Nikita Korzun	12	22	Midfielder	18	Belarus
374	Mykyta Kravchenko	12	20	Midfielder	21	Ukraine
375	Mikola Morozyuk	12	29	Midfielder	9	Ukraine
376	Pavlo Orikhovskyi	12	21	Midfielder	48	Ukraine
377	Serhiy Rybalka	12	27	Midfielder	17	Ukraine
378	Volodymyr Shepelyev	12	20	Midfielder	8	Ukraine
379	Sergiy Sydorchuk	12	26	Midfielder	16	Ukraine
380	Filip Benković	13	20	Defender	26	Croatia
381	Marko Lešković	13	26	Defender	31	Croatia
382	Alexandru Măţel	13	28	Defender	77	Romania
383	Darrick-Kobie Morris	13	22	Defender	4	Croatia
384	Dino Perić	13	23	Defender	55	Croatia
385	Josip Pivarić	13	28	Defender	19	Croatia
386	Gordon Schildenfeld	13	32	Defender	23	Croatia
387	Leonardo Sigali	13	30	Defender	22	Argentina
388	Vinko Soldo	13	19	Defender	6	Croatia
389	Borna Sosa	13	19	Defender	35	Croatia
390	Petar Stojanović	13	22	Defender	30	Slovenia
391	Filip Uremović	13	20	Defender	4	Croatia
392	Ángelo Henríquez	13	23	Forward	9	Chile
393	Armin Hodžić	13	23	Forward	15	Bosnia-Herzegovina
394	Marcos Guilherme	13	22	Forward	11	Brazil
395	Hillal Soudani	13	30	Forward	2	Algeria
396	Dominik Kotarski	13	17	Goalkeeper	12	Croatia
397	Dominik Livaković	13	22	Goalkeeper	40	Croatia
398	Marko Mikulić	13	23	Goalkeeper	33	Croatia
399	Danijel Zagorac	13	30	Goalkeeper	1	Croatia
400	Arijan Ademi	13	26	Midfielder	16	North Macedonia
401	Domagoj Antolić	13	27	Midfielder	8	Croatia
402	Ante Ćorić	13	20	Midfielder	24	Croatia
403	Dani Olmo	13	19	Midfielder	21	Spain
404	Matija Fintić	13	20	Midfielder	28	Croatia
405	Ivan Fiolić	13	21	Midfielder	29	Croatia
406	Amer Gojak	13	20	Midfielder	14	Bosnia-Herzegovina
407	Jorge Sammir	13	30	Midfielder	20	Croatia
408	Bojan Knežević	13	20	Midfielder	25	Croatia
409	Nikola Moro	13	19	Midfielder	27	Croatia
410	Zvonko Pamić	13	26	Midfielder	28	Croatia
411	Paulo Machado	13	31	Midfielder	10	Portugal
412	Domagoj Pavičić	13	23	Midfielder	18	Croatia
413	Aleix Vidal	14	28	Defender	22	Spain
414	Borja López	14	23	Defender	35	Spain
415	Lucas Digne	14	24	Defender	19	France
416	Jordi Alba	14	28	Defender	18	Spain
417	Marlon	14	22	Defender	33	Brazil
418	Javier Mascherano	14	33	Defender	14	Argentina
419	Jérémy Mathieu	14	34	Defender	24	France
420	Nili	14	23	Defender	31	Spain
421	Piqué	14	30	Defender	3	Spain
422	Samuel Umtiti	14	24	Defender	23	France
423	Álex Carbonell	14	20	Forward	30	Spain
424	Cristian Tello	14	26	Forward	\N	Spain
425	Marc Cardona	14	22	Forward	39	Spain
426	Lionel Messi	14	30	Forward	10	Argentina
427	Neymar	14	25	Forward	11	Brazil
428	Paco Alcácer	14	24	Forward	17	Spain
429	Luis Suárez	14	30	Forward	9	Uruguay
430	Jasper Cillessen	14	28	Goalkeeper	13	Netherlands
431	Jordi Masip	14	28	Goalkeeper	25	Spain
432	Marc-André ter Stegen	14	25	Goalkeeper	1	Germany
433	André Gomes	14	24	Midfielder	21	Portugal
434	Busquets	14	29	Midfielder	5	Spain
435	Carles Aleñá	14	19	Midfielder	28	Spain
436	Denis Suárez	14	23	Midfielder	6	Spain
437	Iniesta	14	33	Midfielder	8	Spain
438	Wilfrid Kaptoum	14	21	Midfielder	27	Cameroon
439	Rafinha	14	24	Midfielder	12	Brazil
440	Ivan Rakitić	14	29	Midfielder	4	Croatia
441	Sergi Roberto	14	25	Midfielder	20	Spain
442	Arda Turan	14	30	Midfielder	7	Turkey
443	Manuel Akanji	15	22	Defender	36	Switzerland
444	Éder Balanta	15	24	Defender	23	Colombia
445	Omar Gaber	15	25	Defender	4	Egypt
446	Daniel Høegh	15	26	Defender	26	Denmark
447	Michael Lang	15	26	Defender	5	Switzerland
448	Pedro Pacheco	15	20	Defender	32	Portugal
449	Raoul Petretta	15	20	Defender	28	Italy
450	Blas Riveros	15	19	Defender	25	Paraguay
451	Marek Suchý	15	29	Defender	17	Czech Republic
452	Adama Traoré	15	27	Defender	3	Ivory Coast
453	Seydou Doumbia	15	30	Forward	88	Ivory Coast
454	Mohamed Elyounoussi	15	23	Forward	24	Norway
455	Marc Janko	15	34	Forward	21	Austria
456	Neftali Manzambi	15	20	Forward	14	Switzerland
457	Andraž Šporar	15	23	Forward	9	Slovenia
458	Đorđe Nikolić	15	20	Goalkeeper	13	Serbia
459	Tomáš Vaclík	15	28	Goalkeeper	1	Czech Republic
460	Germano Vailati	15	37	Goalkeeper	18	Switzerland
461	Kevin Bua	15	24	Midfielder	33	Switzerland
462	Davide Callà	15	33	Midfielder	39	Switzerland
463	Matías Delgado	15	35	Midfielder	10	Argentina
464	Alexander Fransson	15	23	Midfielder	15	Sweden
465	Robin Huser	15	19	Midfielder	28	Switzerland
466	Dereck Kutesa	15	20	Midfielder	20	Switzerland
467	Dominik Schmid	15	19	Midfielder	31	Switzerland
468	Geoffroy Serey Dié	15	33	Midfielder	6	Ivory Coast
469	Renato Steffen	15	26	Midfielder	11	Switzerland
470	Taulant Xhaka	15	26	Midfielder	34	Albania
471	Luca Zuffi	15	27	Midfielder	7	Switzerland
472	Peter Ankersen	16	27	Defender	22	Denmark
473	Mikael Antonsson	16	36	Defender	15	Sweden
474	Ludwig Augustinsson	16	23	Defender	3	Sweden
475	Erik Berg	16	29	Defender	5	Sweden
476	Nicolai Boilesen	16	25	Defender	20	Denmark
477	Joel Felix	16	19	Defender	30	Denmark
478	Tom Høgli	16	33	Defender	2	Norway
479	Jores Okore	16	25	Defender	26	Denmark
480	Luka Račić	16	18	Defender	39	Denmark
481	Mads Roerslev	16	18	Defender	27	Denmark
482	Zanka	16	27	Defender	25	Denmark
483	Andreas Cornelius	16	24	Forward	11	Denmark
484	Julian Kristoffersen	16	20	Forward	37	Norway
485	Andrija Pavlović	16	24	Forward	23	Serbia
486	Nicklas Røjkjær	16	19	Forward	39	Denmark
487	Federico Santander	16	26	Forward	19	Paraguay
488	Benjamin Verbič	16	24	Forward	7	Slovenia
489	Stephan Andersen	16	36	Goalkeeper	1	Denmark
490	Kim Christensen	16	38	Goalkeeper	41	Denmark
491	Robin Olsen	16	27	Goalkeeper	31	Sweden
492	Danny Amankwaa	16	23	Midfielder	32	Denmark
493	Rasmus Falk	16	25	Midfielder	33	Denmark
494	Ján Greguš	16	26	Midfielder	16	Slovakia
495	Carl Holse	16	18	Midfielder	\N	Denmark
496	Kasper Kusk	16	26	Midfielder	17	Denmark
497	William Kvist	16	32	Midfielder	6	Denmark
498	Uroš Matić	16	27	Midfielder	8	Serbia
499	Nicolaj Thomsen	16	24	Midfielder	14	Denmark
500	Youssef Toutouh	16	25	Midfielder	24	Denmark
501	Alex Telles	17	25	Defender	13	Brazil
502	Chidozie Awaziem	17	20	Defender	63	Nigeria
503	Willy Boly	17	26	Defender	4	Ivory Coast
504	Felipe Monteiro	17	28	Defender	28	Brazil
505	Fernando Fonseca	17	20	Defender	52	Portugal
506	Inácio Santos	17	21	Defender	45	Brazil
507	Miguel Layún	17	29	Defender	21	Mexico
508	Marcano	17	30	Defender	5	Spain
509	Maximiliano Pereira	17	33	Defender	2	Uruguay
510	André Silva	17	22	Forward	10	Portugal
511	Yacine Brahimi	17	27	Forward	8	Algeria
512	Laurent Depoitre	17	29	Forward	9	Belgium
513	Rui Pedro	17	19	Forward	59	Portugal
514	Tiquinho Soares	17	26	Forward	29	Brazil
515	Andorinha	17	21	Goalkeeper	24	Portugal
516	Iker Casillas	17	36	Goalkeeper	1	Spain
517	José Sá	17	24	Goalkeeper	12	Portugal
518	André André	17	28	Midfielder	20	Portugal
519	Chico Ramos	17	22	Midfielder	48	Portugal
520	Jesús Corona	17	24	Midfielder	17	Mexico
521	Danilo	17	26	Midfielder	22	Portugal
522	Diogo Jota	17	21	Midfielder	19	Portugal
523	Héctor Herrera	17	27	Midfielder	16	Mexico
524	João Carlos Teixeira	17	24	Midfielder	18	Portugal
525	Óliver Torres	17	23	Midfielder	30	Spain
526	Otávio	17	22	Midfielder	25	Portugal
527	Tomás Podstawski	17	22	Midfielder	56	Portugal
528	Rúben Neves	17	20	Midfielder	6	Portugal
529	César Navas	18	37	Defender	44	Spain
530	Vladimir Granat	18	30	Defender	4	Russia
531	Dmitriy Khristis	18	21	Defender	40	Russia
532	Fedor Kudryashov	18	30	Defender	30	Russia
533	Miha Mevlja	18	27	Defender	23	Slovenia
534	Nandinho	18	19	Defender	18	Angola
535	Marko Simić	18	30	Defender	22	Montenegro
536	Andrey Sorokin	18	21	Defender	21	Russia
537	Denis Terentyev	18	25	Defender	5	Russia
538	Sardar Azmoun	18	22	Forward	20	Iran
539	Aleksandr Bukharov	18	32	Forward	11	Russia
540	Marko Dević	18	34	Forward	33	Ukraine
541	Dmitriy Poloz	18	26	Forward	7	Russia
542	Soslan Dzhanaev	18	30	Goalkeeper	35	Russia
543	Evgeniy Goshev	18	20	Goalkeeper	97	Russia
544	Ivan Komissarov	18	29	Goalkeeper	1	Russia
545	Nikita Medvedev	18	23	Goalkeeper	77	Russia
546	Khoren Bairamyan	18	25	Midfielder	19	Armenia
547	Aleksandr Erokhin	18	28	Midfielder	89	Russia
548	Alexandru Gaţcan	18	33	Midfielder	84	Moldova
549	Tsimafei Kalachev	18	36	Midfielder	2	Belarus
550	Roman Khodunov	18	20	Midfielder	\N	Russia
551	Igor Kireev	18	25	Midfielder	8	Russia
552	Filipp Kondryukov	18	20	Midfielder	\N	Russia
553	Nikita Kovalev	18	21	Midfielder	69	Russia
554	Pavel Mogilevets	18	24	Midfielder	18	Russia
555	Christian Noboa	18	32	Midfielder	16	Ecuador
556	Andrei Prepeliță	18	32	Midfielder	28	Romania
557	Reza Shekari	18	19	Midfielder	\N	Iran
558	Andrey Sidenko	18	22	Midfielder	70	Russia
559	Artem Sobol	18	21	Midfielder	\N	Russia
560	Dmitry Weber	18	18	Midfielder	71	Russia
561	Ilya Zakharov	18	21	Midfielder	\N	Russia
562	Alex Sandro	19	26	Defender	12	Brazil
563	Andrea Barzagli	19	36	Defender	15	Italy
564	Medhi Benatia	19	30	Defender	4	Morocco
565	Leonardo Bonucci	19	30	Defender	19	Italy
566	Giorgio Chiellini	19	33	Defender	3	Italy
567	Luca Coccolo	19	19	Defender	38	Italy
568	Dani Alves	19	34	Defender	23	Brazil
569	Paolo De Ceglie	19	31	Defender	29	Italy
570	Stephan Lichtsteiner	19	33	Defender	26	Switzerland
571	Daniele Rugani	19	23	Defender	24	Italy
572	Alessandro Semprini	19	19	Defender	43	Italy
573	Juan Cuadrado	19	29	Forward	7	Colombia
574	Paulo Dybala	19	24	Forward	21	Argentina
575	Gonzalo Higuaín	19	30	Forward	9	Argentina
576	Moise Kean	19	17	Forward	34	Italy
577	Mario Mandžukić	19	31	Forward	17	Croatia
578	Marko Pjaca	19	22	Forward	20	Croatia
579	Emil Audero	19	20	Goalkeeper	32	Italy
580	Gianluigi Buffon	19	39	Goalkeeper	1	Italy
581	Mattia Del Favero	19	19	Goalkeeper	42	Italy
582	Leonardo Loria	19	18	Goalkeeper	36	Italy
583	Neto	19	28	Goalkeeper	25	Brazil
584	Kwadwo Asamoah	19	29	Midfielder	22	Ghana
585	Sami Khedira	19	30	Midfielder	6	Germany
586	Mario Lemina	19	24	Midfielder	18	Gabon
587	Mehdi Léris	19	19	Midfielder	46	France
588	Rolando Mandragora	19	20	Midfielder	38	Italy
589	Claudio Marchisio	19	31	Midfielder	8	Italy
590	Federico Mattiello	19	22	Midfielder	14	Italy
591	Simone Muratore	19	19	Midfielder	45	Italy
592	Miralem Pjanić	19	27	Midfielder	5	Bosnia-Herzegovina
593	Tomás Rincón	19	29	Midfielder	28	Venezuela
594	Stefano Sturaro	19	24	Midfielder	27	Italy
595	Łukasz Broź	20	32	Defender	28	Poland
596	Jakub Czerwiński	20	26	Defender	4	Poland
597	Maciej Dąbrowski	20	30	Defender	5	Poland
598	Adam Hloušek	20	29	Defender	14	Czech Republic
599	Artur Jędrzejczyk	20	30	Defender	55	Poland
600	Michał Pazdan	20	30	Defender	2	Poland
601	Jakub Rzeźniczak	20	31	Defender	25	Poland
602	Daniel Chukwu	20	26	Forward	27	Nigeria
603	Michał Kucharczyk	20	26	Forward	18	Poland
604	Sandro Kulenović	20	18	Forward	26	Croatia
605	Tomasz Nawotka	20	20	Forward	51	Poland
606	Tomáš Necid	20	28	Forward	24	Czech Republic
607	Vamara Sanogo	20	22	Forward	9	France
608	Sadam Sulley	20	21	Forward	12	Ghana
609	Maciej Bąbel	20	19	Goalkeeper	90	Poland
610	Radosław Cierzniak	20	34	Goalkeeper	33	Poland
611	Radosław Majecki	20	18	Goalkeeper	30	Poland
612	Arkadiusz Malarz	20	37	Goalkeeper	1	Poland
613	Guilherme	20	26	Midfielder	6	Brazil
614	Kasper Hämäläinen	20	31	Midfielder	22	Finland
615	Tomasz Jodłowiec	20	32	Midfielder	3	Poland
616	Michał Kopczyński	20	25	Midfielder	15	Poland
617	Thibault Moulin	20	27	Midfielder	75	France
618	Dominik Nagy	20	22	Midfielder	21	Hungary
619	Vadis Odjidja-Ofoe	20	28	Midfielder	8	Belgium
620	Valeri Qazaishvili	20	24	Midfielder	9	Georgia
621	Miroslav Radović	20	33	Midfielder	32	Serbia
622	Sebastian Szymański	20	18	Midfielder	53	Poland
623	Daniel Amartey	21	23	Defender	13	Ghana
624	Yohan Benalouane	21	30	Defender	29	Tunisia
625	Ben Chilwell	21	21	Defender	3	England
626	David Domej	21	21	Defender	44	Austria
627	Christian Fuchs	21	31	Defender	28	Austria
628	Robert Huth	21	33	Defender	6	Germany
629	Elliott Moore	21	20	Defender	36	England
630	Wes Morgan	21	33	Defender	5	Jamaica
631	Danny Simpson	21	30	Defender	17	England
632	Molla Wagué	21	26	Defender	18	Mali
633	Marcin Wasilewski	21	37	Defender	27	Poland
634	Demarai Gray	21	21	Forward	22	England
635	Ahmed Musa	21	25	Forward	7	Nigeria
636	Shinji Okazaki	21	31	Forward	20	Japan
637	Islam Slimani	21	29	Forward	19	Algeria
638	Leonardo Ulloa	21	31	Forward	23	Argentina
639	Jamie Vardy	21	30	Forward	9	England
640	Ben Hamer	21	30	Goalkeeper	12	England
641	Kasper Schmeichel	21	31	Goalkeeper	1	Denmark
642	Ron-Robert Zieler	21	28	Goalkeeper	21	Germany
643	Marc Albrighton	21	28	Midfielder	11	England
644	Danny Drinkwater	21	27	Midfielder	4	England
645	Bartosz Kapustka	21	21	Midfielder	14	Poland
646	Andy King	21	29	Midfielder	10	Wales
647	Riyad Mahrez	21	26	Midfielder	26	Algeria
648	Nampalys Mendy	21	25	Midfielder	24	Senegal
649	Wilfred Ndidi	21	21	Midfielder	25	Nigeria
650	Tosin Adarabioyo	22	20	Defender	53	England
651	Gaël Clichy	22	32	Defender	22	France
652	Aleksandar Kolarov	22	32	Defender	11	Serbia
653	Vincent Kompany	22	31	Defender	4	Belgium
654	Nicolás Otamendi	22	29	Defender	30	Argentina
655	Bacary Sagna	22	34	Defender	3	France
656	John Stones	22	23	Defender	24	England
657	Pablo Zabaleta	22	32	Defender	5	Argentina
658	Sergio Agüero	22	29	Forward	10	Argentina
659	Gabriel Jesus	22	20	Forward	33	Brazil
660	Kelechi Iheanacho	22	21	Forward	72	Nigeria
661	Nolito	22	31	Forward	9	Spain
662	Leroy Sané	22	21	Forward	19	Germany
663	Raheem Sterling	22	23	Forward	7	England
664	Claudio Bravo	22	34	Goalkeeper	1	Chile
665	Willy Caballero	22	36	Goalkeeper	13	Argentina
666	Angus Gunn	22	21	Goalkeeper	54	England
667	Aleix García	22	20	Midfielder	75	Spain
668	Brahim Díaz	22	18	Midfielder	55	Spain
669	David Silva	22	31	Midfielder	21	Spain
670	Kevin De Bruyne	22	26	Midfielder	17	Belgium
671	Fabian Delph	22	28	Midfielder	18	England
672	Fernandinho	22	32	Midfielder	25	Brazil
673	Fernando	22	30	Midfielder	6	Brazil
674	Phil Foden	22	17	Midfielder	80	England
675	İlkay Gündoğan	22	27	Midfielder	8	Germany
676	Jesús Navas	22	32	Midfielder	15	Spain
677	Yaya Touré	22	34	Midfielder	42	Ivory Coast
678	Mouctar Diakhaby	23	21	Defender	5	France
679	Jordy Gaspar	23	20	Defender	23	France
680	Christophe Jallet	23	34	Defender	13	France
681	Gédéon Kalulu	23	20	Defender	46	Congo DR
682	Emanuel Mammana	23	21	Defender	4	Argentina
683	Jérémy Morel	23	33	Defender	15	Madagascar
684	Nicolas N'Koulou	23	27	Defender	3	Cameroon
685	Rafael	23	27	Defender	20	Brazil
686	Maciej Rybus	23	28	Defender	31	Poland
687	Mapou Yanga-Mbiwa	23	28	Defender	2	France
688	Maxwel Cornet	23	21	Forward	27	Ivory Coast
689	Memphis Depay	23	23	Forward	9	Netherlands
690	Alan Dzabana	23	20	Forward	45	France
691	Nabil Fekir	23	24	Forward	18	France
692	Rachid Ghezzal	23	25	Forward	11	Algeria
693	Alexandre Lacazette	23	26	Forward	10	France
694	Myziane Maolida	23	18	Forward	33	France
695	Jean-Philippe Mateta	23	20	Forward	19	France
696	Gaëtan Perrin	23	21	Forward	22	France
697	Anthony Lopes	23	27	Goalkeeper	1	Portugal
698	Mathieu Gorgelin	23	27	Goalkeeper	30	France
699	Lucas Mocio	23	23	Goalkeeper	16	France
700	Houssem Aouar	23	19	Midfielder	25	France
701	Timothé Cognat	23	19	Midfielder	33	France
702	Jordan Ferri	23	25	Midfielder	12	France
703	Maxime Gonalons	23	28	Midfielder	21	France
704	Sergi Darder	23	24	Midfielder	14	Spain
705	Corentin Tolisso	23	23	Midfielder	8	France
706	Lucas Tousart	23	20	Midfielder	29	France
707	Mathieu Valbuena	23	33	Midfielder	28	France
708	Sèrge Aurier	24	25	Defender	19	Ivory Coast
709	Fodé Ballo-Touré	24	20	Defender	33	Senegal
710	Alec Georgen	24	19	Defender	34	France
711	Presnel Kimpembe	24	22	Defender	3	France
712	Layvin Kurzawa	24	25	Defender	20	France
713	Marquinhos	24	23	Defender	5	Brazil
714	Maxwell	24	36	Defender	17	Brazil
715	Thomas Meunier	24	26	Defender	12	Belgium
716	Thiago Silva	24	33	Defender	2	Brazil
717	Jean-Kévin Augustin	24	20	Forward	29	France
718	Edinson Cavani	24	30	Forward	9	Uruguay
719	Ángel Di María	24	29	Forward	11	Argentina
720	Gonçalo Guedes	24	21	Forward	15	Portugal
721	Gaëtan Robail	24	23	Forward	33	France
722	Alphonse Aréola	24	24	Goalkeeper	16	France
723	Rémy Descamps	24	21	Goalkeeper	40	France
724	Kevin Trapp	24	27	Goalkeeper	1	Germany
725	Hatem Ben Arfa	24	30	Midfielder	21	France
726	Lorenzo Callegari	24	19	Midfielder	41	France
727	Julian Draxler	24	24	Midfielder	23	Germany
728	Grzegorz Krychowiak	24	27	Midfielder	4	Poland
729	Giovani Lo Celso	24	21	Midfielder	18	Argentina
730	Lucas Moura	24	25	Midfielder	7	Brazil
731	Blaise Matuidi	24	30	Midfielder	14	France
732	Christopher Nkunku	24	20	Midfielder	24	France
733	Javier Pastore	24	28	Midfielder	10	Argentina
734	Adrien Rabiot	24	22	Midfielder	25	France
735	Thiago Motta	24	35	Midfielder	8	Italy
736	Marco Verratti	24	25	Midfielder	6	Italy
737	Cicinho	25	29	Defender	4	Bulgaria
738	Kristian Grigorov	25	27	Defender	99	Bulgaria
739	Dimitar Iliev	25	18	Defender	58	Bulgaria
740	Atanas Karachorov	25	19	Defender	85	Bulgaria
741	Cosmin Moţi	25	33	Defender	27	Romania
742	Natanael Pimenta	25	27	Defender	6	Brazil
743	José Palomino	25	27	Defender	5	Argentina
744	Petar Petrov	25	20	Defender	2	Bulgaria
745	Igor Plastun	25	27	Defender	32	Ukraine
746	Ivan Velikov	25	19	Defender	56	Bulgaria
747	Vitinha	25	31	Defender	77	Portugal
748	Serdar Yusufov	25	19	Defender	76	Bulgaria
749	Denislav Aleksandrov	25	20	Forward	80	Bulgaria
750	Tsvetelin Chunchukov	25	23	Forward	17	Bulgaria
751	Toni Ivanov	25	18	Forward	81	Bulgaria
752	João Paulo	25	29	Forward	37	Brazil
753	Jonathan Cafú	25	26	Forward	22	Brazil
754	Juninho Quixadá	25	32	Forward	11	Brazil
755	Claudiu Keșerü	25	31	Forward	28	Romania
756	Svetoslav Kovachev	25	19	Forward	98	Bulgaria
757	Jody Lukoki	25	25	Forward	92	Congo DR
758	Virgil Misidjan	25	24	Forward	93	Netherlands
759	Wanderson	25	29	Forward	88	Bulgaria
760	Ivan Atanasov	25	18	Goalkeeper	90	Bulgaria
761	Daniel Naumov	25	19	Goalkeeper	29	Bulgaria
762	Renan	25	28	Goalkeeper	33	Brazil
763	Vasil Simeonov	25	19	Goalkeeper	51	Bulgaria
764	Vladislav Stoyanov	25	30	Goalkeeper	27	Bulgaria
765	Anicet	25	27	Midfielder	12	Madagascar
766	Oleg Dimitrov	25	21	Midfielder	34	Bulgaria
767	Svetoslav Dyakov	25	33	Midfielder	18	Bulgaria
768	Gustavo	25	25	Midfielder	10	Brazil
769	Kristiyan Kitov	25	21	Midfielder	38	Bulgaria
770	Ivaylo Klimentov	25	19	Midfielder	45	Bulgaria
771	Lucas Sasha	25	27	Midfielder	8	Brazil
772	Marcelinho	25	33	Midfielder	84	Bulgaria
773	Slavcho Shokolarov	25	28	Midfielder	14	Bulgaria
774	Tomas Tsvyatkov	25	20	Midfielder	97	Bulgaria
775	Aleksandar Vasilev	25	22	Midfielder	19	Bulgaria
776	Santiago Arias	26	25	Defender	4	Colombia
777	Joshua Brenet	26	23	Defender	20	Netherlands
778	Nicolas Isimat-Mirin	26	26	Defender	2	France
779	Menno Koch	26	23	Defender	29	Netherlands
780	Héctor Moreno	26	29	Defender	3	Mexico
781	Daniel Schwaab	26	29	Defender	5	Germany
782	Damian van Bruggen	26	21	Defender	45	Netherlands
783	Jetro Willems	26	23	Defender	15	Netherlands
784	Steven Bergwijn	26	20	Forward	27	Netherlands
785	Luuk de Jong	26	27	Forward	9	Netherlands
786	Albert Guðmundsson	26	20	Forward	40	Iceland
787	Sam Lammers	26	20	Forward	50	Netherlands
788	Jürgen Locadia	26	24	Forward	19	Netherlands
789	Gastón Pereiro	26	22	Forward	7	Uruguay
790	Matthias Verreth	26	19	Forward	49	Belgium
791	Hidde Jurjus	26	23	Goalkeeper	31	Netherlands
792	Luuk Koopmans	26	24	Goalkeeper	21	Netherlands
793	Remko Pasveer	26	34	Goalkeeper	22	Netherlands
794	Yanick van Osch	26	20	Goalkeeper	41	Netherlands
795	Jeroen Zoet	26	26	Goalkeeper	1	Netherlands
796	Siem de Jong	26	28	Midfielder	10	Netherlands
797	Andrés Guardado	26	31	Midfielder	18	Mexico
798	Jorrit Hendrix	26	22	Midfielder	8	Netherlands
799	Ramon Lundqvist	26	20	Midfielder	38	Sweden
800	Kenneth Paal	26	20	Midfielder	32	Suriname
801	Davy Pröpper	26	26	Midfielder	6	Netherlands
802	Bart Ramselaar	26	21	Midfielder	23	Netherlands
803	Dante Rigo	26	19	Midfielder	35	Belgium
804	Pablo Rosario	26	20	Midfielder	43	Netherlands
805	Marco van Ginkel	26	25	Midfielder	28	Netherlands
806	Oleksandr Zinchenko	26	21	Midfielder	25	Ukraine
807	Álvaro Tejero	27	21	Defender	27	Spain
808	Dani Carvajal	27	25	Defender	2	Spain
809	Danilo	27	26	Defender	23	Brazil
810	Fábio Coentrão	27	29	Defender	15	Portugal
811	Achraf Hakimi	27	19	Defender	32	Morocco
812	Marcelo	27	29	Defender	12	Brazil
813	Nacho	27	27	Defender	6	Spain
814	Pepe	27	34	Defender	3	Portugal
815	Sergio Ramos	27	31	Defender	4	Spain
816	Raphaël Varane	27	24	Defender	5	France
817	Álvaro Morata	27	25	Forward	21	Spain
818	Gareth Bale	27	28	Forward	11	Wales
819	Karim Benzema	27	30	Forward	9	France
820	Cristiano Ronaldo	27	32	Forward	7	Portugal
821	Lucas Vázquez	27	26	Forward	17	Spain
822	Marco Asensio	27	21	Forward	20	Spain
823	Mariano	27	24	Forward	18	Dom. Republic
824	Kiko Casilla	27	31	Goalkeeper	13	Spain
825	Keylor Navas	27	31	Goalkeeper	1	Costa Rica
826	Rubén Yáñez	27	24	Goalkeeper	25	Spain
827	Casemiro	27	25	Midfielder	14	Brazil
828	Isco	27	25	Midfielder	22	Spain
829	Mateo Kovačić	27	23	Midfielder	16	Croatia
830	Toni Kroos	27	27	Midfielder	8	Germany
831	Luka Modrić	27	32	Midfielder	19	Croatia
832	James Rodríguez	27	26	Midfielder	10	Colombia
833	Enzo Zidane	27	22	Midfielder	29	France
834	Álex Muñoz	28	23	Defender	36	Spain
835	Daniel Carriço	28	29	Defender	6	Portugal
836	David Carmona	28	20	Defender	26	Spain
837	Diego González	28	22	Defender	32	Spain
838	Sergio Escudero	28	28	Defender	18	Spain
839	Clément Lenglet	28	22	Defender	5	France
840	Mariano	28	31	Defender	3	Brazil
841	Matos	28	22	Defender	29	Spain
842	Gabriel Mercado	28	30	Defender	24	Argentina
843	Nicolás Pareja	28	33	Defender	21	Argentina
844	Adil Rami	28	32	Defender	23	France
845	Cristian Tassano	28	21	Defender	\N	Uruguay
846	Benoît Trémoulinas	28	32	Defender	2	France
847	Alejandro Pozo	28	18	Forward	39	Spain
848	Wissam Ben Yedder	28	27	Forward	12	France
849	Carlos Fernández	28	21	Forward	30	Spain
850	Stevan Jovetić	28	28	Forward	16	Montenegro
851	Luciano Vietto	28	24	Forward	9	Argentina
852	Vitolo	28	28	Forward	20	Spain
853	David Soria	28	24	Goalkeeper	13	Spain
854	José Antonio Caro	28	23	Goalkeeper	31	Spain
855	Sergio Rico	28	24	Goalkeeper	1	Spain
856	Borja Lasso	28	23	Midfielder	38	Spain
857	Joaquín Correa	28	23	Midfielder	11	Argentina
858	Cotán	28	22	Midfielder	27	Spain
859	Ganso	28	28	Midfielder	19	Brazil
860	Iborra	28	29	Midfielder	8	Spain
861	Matías Kranevitter	28	24	Midfielder	4	Argentina
862	Michael Krohn-Dehli	28	34	Midfielder	7	Denmark
863	Walter Montoya	28	24	Midfielder	14	Argentina
864	Steven N'Zonzi	28	29	Midfielder	15	France
865	Samir Nasri	28	30	Midfielder	10	France
866	Pablo Sarabia	28	25	Midfielder	17	Spain
867	Pepe Mena	28	19	Midfielder	38	Spain
868	Franco Vázquez	28	28	Midfielder	22	Argentina
869	Álex Grimaldo	29	22	Defender	3	Spain
870	André Almeida	29	27	Defender	34	Portugal
871	Eliseu	29	34	Defender	19	Portugal
872	Jardel	29	31	Defender	33	Brazil
873	Branimir Kalaica	29	19	Defender	16	Croatia
874	Victor Lindelöf	29	23	Defender	14	Sweden
875	Lisandro López	29	28	Defender	2	Argentina
876	Luisão	29	36	Defender	4	Brazil
877	Marcelo Hermes	29	22	Defender	38	Brazil
878	Nélson Semedo	29	24	Defender	50	Portugal
879	Pedro Pereira	29	19	Defender	23	Portugal
880	Rúben Dias	29	20	Defender	66	Portugal
881	Yuri Ribeiro	29	20	Defender	95	Portugal
882	Raúl Jiménez	29	26	Forward	9	Mexico
883	Jonas	29	33	Forward	10	Brazil
884	Luka Jović	29	20	Forward	35	Serbia
885	Kostas Mitroglou	29	29	Forward	11	Greece
886	Rafa Silva	29	24	Forward	27	Portugal
887	Iván Šaponjić	29	20	Forward	26	Serbia
888	Zé Gomes	29	18	Forward	70	Portugal
889	Ederson	29	24	Goalkeeper	1	Brazil
890	Júlio César	29	38	Goalkeeper	12	Brazil
891	Paulo Lopes	29	39	Goalkeeper	13	Portugal
892	André Horta	29	21	Midfielder	8	Portugal
893	André Carrillo	29	26	Midfielder	15	Peru
894	Franco Cervi	29	23	Midfielder	22	Argentina
895	Ljubomir Fejsa	29	29	Midfielder	5	Serbia
896	Filipe Augusto	29	24	Midfielder	6	Brazil
897	Pizzi	29	28	Midfielder	21	Portugal
898	Eduardo Salvio	29	27	Midfielder	18	Argentina
899	Andreas Samaris	29	28	Midfielder	7	Greece
900	Andrija Živković	29	21	Midfielder	17	Serbia
901	Sebastián Coates	30	27	Defender	13	Uruguay
902	Douglas	30	29	Defender	19	Netherlands
903	Geraldes	30	26	Defender	20	Portugal
904	Jefferson	30	29	Defender	4	Brazil
905	Paulo Oliveira	30	25	Defender	15	Portugal
906	Ricardo Esgaio	30	24	Defender	47	Portugal
907	Rúben Semedo	30	23	Defender	35	Portugal
908	Ezequiel Schelotto	30	28	Defender	2	Argentina
909	Marvin Zeegelaar	30	27	Defender	31	Netherlands
910	Joel Campbell	30	25	Forward	7	Costa Rica
911	Luc Castaignos	30	25	Forward	20	Netherlands
912	Daniel Podence	30	22	Forward	56	Portugal
913	Bas Dost	30	28	Forward	28	Netherlands
914	Gelson Martins	30	22	Forward	77	Portugal
915	Lukas Spalvis	30	23	Forward	\N	Lithuania
916	Beto	30	35	Goalkeeper	34	Portugal
917	Ažbe Jug	30	25	Goalkeeper	26	Slovenia
918	Rui Patrício	30	29	Goalkeeper	1	Portugal
919	Vladimir Stojković	30	21	Goalkeeper	88	Serbia
920	Adrien Silva	30	28	Midfielder	23	Portugal
921	Bruno César	30	29	Midfielder	11	Brazil
922	Bruno Paulista	30	22	Midfielder	30	Brazil
923	Ryan Gauld	30	22	Midfielder	\N	Scotland
924	Gelson Dala	30	21	Midfielder	57	Angola
925	Francisco Geraldes	30	22	Midfielder	18	Portugal
926	João Palhinha	30	22	Midfielder	66	Portugal
927	Matheus Pereira	30	21	Midfielder	73	Brazil
928	Mattheus Oliveira	30	23	Midfielder	21	Brazil
929	Alan Ruíz	30	24	Midfielder	99	Argentina
930	Bryan Ruiz	30	32	Midfielder	10	Costa Rica
931	William Carvalho	30	25	Midfielder	14	Portugal
932	Vlad Chiricheş	31	28	Defender	21	Romania
933	Faouzi Ghoulam	31	26	Defender	31	Algeria
934	Elseid Hysaj	31	23	Defender	2	Albania
935	Kalidou Koulibaly	31	26	Defender	26	Senegal
936	Christian Maggio	31	35	Defender	11	Italy
937	Nikola Maksimović	31	26	Defender	19	Serbia
938	Raúl Albiol	31	32	Defender	33	Spain
939	Ivan Strinić	31	30	Defender	3	Croatia
940	Lorenzo Tonelli	31	27	Defender	62	Italy
941	Lorenzo Insigne	31	26	Forward	24	Italy
942	José Callejón	31	30	Forward	7	Spain
943	Leandrinho	31	19	Forward	18	Brazil
944	Dries Mertens	31	30	Forward	14	Belgium
945	Arkadiusz Milik	31	23	Forward	99	Poland
946	Leonardo Pavoletti	31	29	Forward	32	Italy
947	Pepe Reina	31	35	Goalkeeper	25	Spain
948	Rafael Cabral	31	27	Goalkeeper	1	Brazil
949	Luigi Sepe	31	26	Goalkeeper	22	Italy
950	Allan	31	26	Midfielder	5	Brazil
951	Amadou Diawara	31	20	Midfielder	42	Guinea
952	Emanuele Giaccherini	31	32	Midfielder	4	Italy
953	Marek Hamšík	31	30	Midfielder	17	Slovakia
954	Jorginho	31	26	Midfielder	8	Italy
955	Marco Milanese	31	19	Midfielder	98	Italy
956	Marko Rog	31	22	Midfielder	30	Croatia
957	Alessio Zerbin	31	18	Midfielder	23	Italy
958	Piotr Zieliński	31	23	Midfielder	20	Poland
959	Toby Alderweireld	32	28	Defender	4	Belgium
960	Cameron Carter-Vickers	32	20	Defender	38	USA
961	Ben Davies	32	24	Defender	33	Wales
962	Eric Dier	32	23	Defender	15	England
963	Danny Rose	32	27	Defender	3	England
964	Kieran Trippier	32	27	Defender	16	England
965	Jan Vertonghen	32	30	Defender	5	Belgium
966	Kyle Walker	32	27	Defender	2	England
967	Kyle Walker-Peters	32	20	Defender	37	England
968	Kevin Wimmer	32	25	Defender	27	Austria
969	Vincent Janssen	32	23	Forward	9	Netherlands
970	Harry Kane	32	24	Forward	10	England
971	Érik Lamela	32	25	Forward	11	Argentina
972	Georges-Kévin N'Koudou	32	22	Forward	14	Cameroon
973	Heung-min Son	32	25	Forward	7	South Korea
974	Tom Glover	32	20	Goalkeeper	40	Australia
975	Hugo Lloris	32	31	Goalkeeper	1	France
976	Pau López	32	23	Goalkeeper	30	Spain
977	Michel Vorm	32	34	Goalkeeper	13	Netherlands
978	Alfie Whiteman	32	19	Goalkeeper	41	England
979	Dele Alli	32	21	Midfielder	20	England
980	Mousa Dembélé	32	30	Midfielder	19	Belgium
981	Marcus Edwards	32	19	Midfielder	48	England
982	Christian Eriksen	32	25	Midfielder	23	Denmark
983	Filip Lesniak	32	21	Midfielder	44	Slovakia
984	Josh Onomah	32	20	Midfielder	25	England
985	Samuel Shashoua	32	18	Midfielder	43	England
986	Moussa Sissoko	32	28	Midfielder	17	France
987	Victor Wanyama	32	26	Midfielder	12	Kenya
988	Harry Winks	32	21	Midfielder	8	England
989	Manolo Gabbiadini	31	26	Centre Forward	23	Italy
990	Júnior Moraes	12	30	Centre Forward	18	Ukraine
991	Luciano Narsingh	26	27	Right Winger	9	Netherlands
992	Lacina Traoré	11	27	Centre Forward	\N	Ivory Coast
993	Adrián Ramos	8	31	Centre Forward	20	Colombia
994	Aleksandar Prijović	20	27	Centre Forward	99	Serbia
995	Bartosz Bereszyński	20	25	Right Back	\N	Poland
996	Nemanja Nikolić	20	30	Centre Forward	22	Hungary
997	Thomas Delaney	16	26	Central Midfielder	\N	Denmark
998	Brandon Mechele	16	24	Centre Back	44	Belgium
\.


--
-- Data for Name: scores; Type: TABLE DATA; Schema: public; Owner: hunglai
--

COPY public.scores (id, scorer_id, assist_id, own_goal, match_id) FROM stdin;
1	753	772	f	1
2	469	\N	f	1
3	718	708	f	2
4	15	\N	f	2
5	17	15	f	3
6	17	15	f	3
7	742	\N	f	4
8	731	736	f	4
9	718	719	f	4
10	718	730	f	4
11	15	14	f	5
12	17	28	f	5
13	14	\N	f	5
14	28	31	f	5
15	28	13	f	5
16	28	13	f	5
17	719	718	f	6
18	730	\N	f	6
19	718	718	f	6
20	731	715	f	7
21	471	470	f	7
22	715	734	f	7
23	753	759	f	8
24	755	753	f	8
25	33	28	f	8
26	11	29	f	8
27	28	26	f	8
28	718	731	f	9
29	11	15	f	9
30	736	\N	t	9
31	12	\N	t	9
32	13	3	f	11
33	13	3	f	11
34	13	15	f	11
35	12	28	f	11
36	453	455	f	11
37	758	742	f	12
38	718	\N	f	12
39	759	753	f	12
40	719	712	f	12
41	372	365	f	13
42	945	933	f	13
43	945	\N	f	13
44	894	\N	f	14
45	185	\N	f	14
46	178	\N	f	15
47	365	377	f	15
48	953	933	f	16
49	944	\N	f	16
50	945	942	f	16
51	944	945	f	16
52	720	\N	f	16
53	898	870	f	16
54	898	\N	f	17
55	894	885	f	17
56	161	178	f	18
57	944	942	f	18
58	173	\N	f	18
59	989	\N	f	18
60	173	178	f	18
61	178	\N	f	19
62	953	944	f	19
63	898	876	f	20
64	720	898	f	21
65	878	898	f	21
66	895	898	f	21
67	180	163	f	21
68	178	\N	f	21
69	173	178	f	21
70	363	367	f	23
71	367	\N	f	23
72	370	\N	f	23
73	364	367	f	23
74	379	370	f	23
75	990	367	f	23
76	942	944	f	24
77	944	933	f	24
78	882	\N	f	24
79	426	427	f	25
80	426	427	f	25
81	427	\N	f	25
82	437	427	f	25
83	426	429	f	25
84	429	427	f	25
85	429	426	f	25
86	658	652	f	26
87	658	675	f	26
88	658	663	f	26
89	660	662	f	26
90	210	221	f	27
91	442	427	f	27
92	421	\N	f	27
93	269	265	f	28
94	672	652	f	28
95	663	\N	t	28
96	663	669	f	28
97	269	\N	f	28
98	661	\N	f	28
99	227	209	f	29
100	209	227	f	29
101	426	\N	f	30
102	426	437	f	30
103	426	429	f	30
104	427	426	f	30
105	227	210	f	31
106	269	269	f	31
107	426	427	f	32
108	675	663	f	32
109	670	\N	f	32
110	675	658	f	32
111	213	227	f	33
112	669	670	f	33
113	426	427	f	34
114	426	429	f	34
115	426	442	f	35
116	442	436	f	35
117	442	413	f	35
118	442	428	f	35
119	290	262	f	36
120	660	661	f	36
121	143	143	f	37
122	144	132	f	37
123	154	142	f	37
124	154	138	f	37
125	138	145	f	37
126	100	\N	f	38
127	91	82	f	39
128	541	547	f	40
129	801	785	f	40
130	541	538	f	40
131	785	\N	f	40
132	144	\N	f	41
133	154	132	f	41
134	991	789	f	41
135	143	\N	f	41
136	146	158	f	41
137	91	72	f	42
138	82	91	f	43
139	538	541	f	43
140	82	\N	f	43
141	776	\N	f	44
142	143	\N	f	44
143	143	132	f	44
144	142	\N	f	45
145	538	541	f	45
146	541	555	f	45
147	138	145	f	45
148	555	\N	f	45
149	81	82	f	46
150	82	101	f	46
151	143	\N	f	47
152	116	127	f	49
153	127	129	f	49
154	340	344	f	49
155	341	992	f	49
156	61	\N	f	50
157	52	\N	f	50
158	959	971	f	50
159	114	116	f	51
160	37	49	f	51
161	973	971	f	52
162	992	\N	f	54
163	61	\N	f	54
164	51	\N	f	55
165	50	41	f	55
166	50	51	f	55
167	129	\N	f	56
168	118	129	f	57
169	348	328	f	57
170	45	41	f	58
171	970	979	f	58
172	52	45	f	58
173	131	111	f	59
174	126	127	f	59
175	56	\N	t	59
176	340	351	f	60
177	979	982	f	60
178	970	963	f	60
179	336	\N	t	60
180	250	240	f	61
181	234	233	f	61
182	229	\N	f	61
183	233	\N	f	61
184	249	243	f	61
185	238	249	f	61
186	921	\N	f	62
187	820	\N	f	62
188	817	832	f	62
189	820	818	f	63
190	238	\N	f	63
191	816	\N	f	63
192	244	243	f	63
193	930	\N	f	64
194	913	920	f	64
195	818	521	f	65
196	615	\N	t	65
197	621	621	f	65
198	822	820	f	65
199	821	817	f	65
200	817	820	f	65
201	238	250	f	66
202	257	\N	f	66
203	921	931	f	66
204	993	232	f	67
205	818	820	f	68
206	819	818	f	68
207	619	613	f	68
208	621	617	f	68
209	617	994	f	68
210	829	808	f	68
211	994	619	f	69
212	251	240	f	69
213	251	240	f	69
214	256	\N	f	69
215	994	995	f	69
216	240	254	f	69
217	254	251	f	69
218	254	240	f	69
219	603	621	f	69
220	253	244	f	69
221	996	621	f	69
222	601	\N	t	69
223	816	820	f	70
224	920	\N	f	70
225	819	815	f	70
226	613	994	f	71
227	819	808	f	72
228	819	832	f	72
229	238	237	f	72
230	254	238	f	72
231	643	\N	f	73
232	647	\N	f	73
233	647	\N	f	73
234	526	510	f	74
235	483	\N	f	74
236	296	\N	t	75
237	997	488	f	75
238	487	474	f	75
239	482	474	f	75
240	637	647	f	76
241	312	322	f	77
242	507	526	f	77
243	510	520	f	77
244	647	637	f	78
245	510	501	f	80
246	636	627	f	82
247	647	643	f	82
248	306	\N	f	82
249	998	\N	t	83
250	482	474	f	83
251	510	520	f	84
252	520	501	f	84
253	511	509	f	84
254	510	510	f	84
255	522	510	f	84
256	705	685	f	86
257	702	688	f	86
258	688	705	f	86
259	592	\N	f	87
260	575	592	f	87
261	574	568	f	87
262	568	\N	f	87
263	848	851	f	88
264	865	823	f	89
265	573	568	f	90
266	575	577	f	91
267	705	692	f	91
268	851	868	f	92
269	838	852	f	92
270	864	866	f	92
271	848	823	f	92
272	693	685	f	93
273	843	\N	f	94
274	589	565	f	94
275	565	\N	f	94
276	577	589	f	94
277	575	586	f	95
278	571	592	f	95
279	885	876	f	97
280	719	\N	f	98
281	727	736	f	98
282	719	727	f	98
283	718	715	f	98
284	941	953	f	99
285	819	808	f	99
286	830	820	f	99
287	827	\N	f	99
288	146	142	f	100
289	15	\N	f	100
290	143	139	f	100
291	158	143	f	100
292	158	\N	f	100
293	144	158	f	100
294	663	662	f	101
295	50	64	f	101
296	53	64	f	101
297	658	663	f	101
298	50	52	f	101
299	658	669	f	101
300	656	677	f	101
301	662	658	f	101
302	100	\N	f	102
303	82	81	f	102
304	113	106	f	102
305	81	81	f	102
306	74	\N	t	102
307	80	76	f	102
308	578	\N	f	103
309	568	562	f	103
310	866	838	f	104
311	857	850	f	104
312	639	644	f	104
313	944	953	f	105
314	815	830	f	105
315	944	\N	t	105
316	817	\N	f	105
317	17	11	f	106
318	143	143	f	106
319	146	\N	f	106
320	142	140	f	106
321	159	160	f	106
322	159	142	f	106
323	238	243	f	107
324	243	236	f	107
325	238	237	f	107
326	238	231	f	107
327	429	\N	f	108
328	712	\N	t	108
329	426	427	f	108
330	718	712	f	108
331	427	\N	f	108
332	427	429	f	108
333	441	427	f	108
334	574	\N	f	109
335	630	647	f	110
336	643	\N	f	110
337	53	61	f	111
338	64	41	f	111
339	662	\N	f	111
340	59	52	f	111
341	574	573	f	113
342	574	577	f	113
343	566	592	f	113
344	53	52	f	114
345	230	\N	t	114
346	240	251	f	114
347	53	\N	f	114
348	251	256	f	114
349	82	82	f	115
350	159	158	f	116
351	820	808	f	116
352	820	822	f	116
353	100	68	f	117
354	639	\N	f	117
355	143	146	f	118
356	820	827	f	118
357	815	\N	t	118
358	820	815	f	118
359	820	168	f	118
360	822	\N	f	118
361	53	41	f	120
362	50	52	f	120
363	254	240	f	120
364	51	52	f	120
365	820	827	f	121
366	820	\N	f	121
367	820	821	f	121
368	575	568	f	122
369	575	568	f	122
370	577	568	f	123
371	568	\N	f	123
372	53	65	f	123
373	100	97	f	124
374	82	\N	f	124
375	828	\N	f	124
376	820	808	f	125
377	577	575	f	125
378	827	\N	f	125
379	820	831	f	125
380	822	168	f	125
\.


--
-- Data for Name: stadiums; Type: TABLE DATA; Schema: public; Owner: hunglai
--

COPY public.stadiums (id, name, team_id, capacity, address) FROM stdin;
1	Emirates Stadium	1	60704	Drayton Park 75 Highbury N5 1BU London England
2	Stade Louis II	2	18524	Stade Louis II BP 698 98014 Monaco France
3	Cívitas Metropolitano	3	68456	Paseo Virgen del Puerto, 67 28005 Madrid Spain
4	BayArena	4	30210	Bismarckstraße 122-124 51373 Leverkusen Germany
5	Allianz Arena	5	75024	Säbener Str. 51-57 Postfach 900451 81547 München Germany
6	Vodafone Park	6	41903	BJK Plaza Akaretler Süleyman Seba Caddesi No. 92 Beşiktaş 80680 Istanbul Turkey
7	Borussia-Park	7	54057	Hennes-Weisweiler-Allee 1 41179 Mönchengladbach Germany
8	Signal Iduna Park	8	81365	Strobelallee 50 Postfach 100509 44005 Dortmund Germany
9	Celtic Park	9	60832	Parkhead 95 Kerrydale Street G40 3RE Glasgow Scotland
10	Jan Breydel Stadion	10	29042	Olympialaan 74 8200 Brugge Belgium
11	VEB Arena	11	30000	Leningradskiy prospekt 39 125167 Moskva Russia
12	Olimpiyskyi	12	70050	Ulica Grushevskogo 3 01001 Kiev Ukraine
13	Maksimir	13	38079	Maksimirska 128 10000 Zagreb Croatia
14	Spotify Camp Nou	14	99354	Avenida Arístides Maillol 08028 Barcelona Spain
15	St. Jakob-Park	15	38512	FC Basel 1893 Gellertstrasse 235 4052 Basel Switzerland
16	Parken	16	38076	F.C. København Øster Allé 50 2100 København Denmark
17	Estádio do Dragão	17	54378	Torre das Antas Avenida Fernão de Magalhães 4300 Porto Portugal
18	Rostov Arena	18	45000	6a Pervoi Konnoi Armii St. 344029 Rostov Russia
19	Allianz Stadium	19	41254	Corso Galileo Ferraris 32 10128 Torino Italy
20	Stadion Wojska Polskiego	20	31103	Lazienkowska 3 00-449 Warszawa Poland
21	King Power Stadium	21	32500	Filbert Street LE2 7FL Leicester England
22	Etihad Stadium	22	55097	Sportcity, Rowsley Street M11 3FF Manchester England
23	Groupama Stadium	23	59186	350, Avenue Jean-Jaurès 69007 Lyon France
24	Parc des Princes	24	48712	24, Rue du Commandant-Guilbaud 75016 Paris France
25	Huvepharma Arena	25	9000	Bulgaria
26	Philips Stadion	26	35000	Frederiklaan 10 a 5616 Eindhoven Netherlands
27	Santiago Bernabéu	27	81044	Real Madrid  Avenida Concha Espina 1 28036 Madrid Spain
28	Ramón Sánchez Pizjuán	28	43883	Calle Sevilla Fútbol Club 41005 Sevilla Spain
29	Estádio da Luz	29	65272	Avenida General Norton de Matos 1500 Apartado Nº 4100 1501-805 Lisboa Portugal
30	Estádio José Alvalade	30	52000	Edifício Visconde de Alvalade Rua Professor Fernando da Fonseca 1600-616 Lisboa Portugal
31	Diego Maradona	31	60240	Via del Maio di Porto 9 80133 Napoli Italy
32	Tottenham Hotspur Stadium	32	62062	Bill Nicholson Way 748 High Road Tottenham N17 0AP London England
33	Vasil Levski	\N	43632	Sofia Bulgaria
34	Vicente Calderón	\N	54851	Madrid Spain
35	Olimp – 2	\N	15840	Rostov-na-Donu Russia
36	Wembley Stadium	\N	90000	London England
37	Arena Khimki	\N	18636	Khimki Russia
38	Millennium	\N	74500	Cardiff Wales
\.


--
-- Data for Name: team_links; Type: TABLE DATA; Schema: public; Owner: hunglai
--

COPY public.team_links (id, team_name, info_team_url, squad_url) FROM stdin;
1	Arsenal FC	https://www.worldfootball.net/teams/arsenal-fc/1/	https://www.worldfootball.net/teams/arsenal-fc/2017/2/
2	AS Monaco	https://www.worldfootball.net/teams/as-monaco/1/	https://www.worldfootball.net/teams/as-monaco/2017/2/
3	Atlético Madrid	https://www.worldfootball.net/teams/atletico-madrid/1/	https://www.worldfootball.net/teams/atletico-madrid/2017/2/
4	Bayer Leverkusen	https://www.worldfootball.net/teams/bayer-leverkusen/1/	https://www.worldfootball.net/teams/bayer-leverkusen/2017/2/
5	Bayern München	https://www.worldfootball.net/teams/bayern-muenchen/1/	https://www.worldfootball.net/teams/bayern-muenchen/2017/2/
6	Beşiktaş	https://www.worldfootball.net/teams/besiktas/1/	https://www.worldfootball.net/teams/besiktas/2017/2/
7	Bor. Mönchengladbach	https://www.worldfootball.net/teams/bor-moenchengladbach/1/	https://www.worldfootball.net/teams/bor-moenchengladbach/2017/2/
8	Borussia Dortmund	https://www.worldfootball.net/teams/borussia-dortmund/1/	https://www.worldfootball.net/teams/borussia-dortmund/2017/2/
9	Celtic FC	https://www.worldfootball.net/teams/celtic-fc/1/	https://www.worldfootball.net/teams/celtic-fc/2017/2/
10	Club Brugge KV	https://www.worldfootball.net/teams/club-brugge-kv/1/	https://www.worldfootball.net/teams/club-brugge-kv/2017/2/
11	CSKA Moskva	https://www.worldfootball.net/teams/cska-moskva/1/	https://www.worldfootball.net/teams/cska-moskva/2017/2/
12	Dinamo Kiev	https://www.worldfootball.net/teams/dinamo-kiev/1/	https://www.worldfootball.net/teams/dinamo-kiev/2017/2/
13	Dinamo Zagreb	https://www.worldfootball.net/teams/dinamo-zagreb/1/	https://www.worldfootball.net/teams/dinamo-zagreb/2017/2/
14	FC Barcelona	https://www.worldfootball.net/teams/fc-barcelona/1/	https://www.worldfootball.net/teams/fc-barcelona/2017/2/
15	FC Basel	https://www.worldfootball.net/teams/fc-basel/1/	https://www.worldfootball.net/teams/fc-basel/2017/2/
16	FC København	https://www.worldfootball.net/teams/fc-koebenhavn/1/	https://www.worldfootball.net/teams/fc-koebenhavn/2017/2/
17	FC Porto	https://www.worldfootball.net/teams/fc-porto/1/	https://www.worldfootball.net/teams/fc-porto/2017/2/
18	FK Rostov	https://www.worldfootball.net/teams/fk-rostov/1/	https://www.worldfootball.net/teams/fk-rostov/2017/2/
19	Juventus	https://www.worldfootball.net/teams/juventus/1/	https://www.worldfootball.net/teams/juventus/2017/2/
20	Legia Warszawa	https://www.worldfootball.net/teams/legia-warszawa/1/	https://www.worldfootball.net/teams/legia-warszawa/2017/2/
21	Leicester City	https://www.worldfootball.net/teams/leicester-city/1/	https://www.worldfootball.net/teams/leicester-city/2017/2/
22	Manchester City	https://www.worldfootball.net/teams/manchester-city/1/	https://www.worldfootball.net/teams/manchester-city/2017/2/
23	Olympique Lyon	https://www.worldfootball.net/teams/olympique-lyon/1/	https://www.worldfootball.net/teams/olympique-lyon/2017/2/
24	Paris Saint-Germain	https://www.worldfootball.net/teams/paris-saint-germain/1/	https://www.worldfootball.net/teams/paris-saint-germain/2017/2/
25	PFC Ludogorets Razgrad	https://www.worldfootball.net/teams/pfc-ludogorets-razgrad/1/	https://www.worldfootball.net/teams/pfc-ludogorets-razgrad/2017/2/
26	PSV Eindhoven	https://www.worldfootball.net/teams/psv-eindhoven/1/	https://www.worldfootball.net/teams/psv-eindhoven/2017/2/
27	Real Madrid	https://www.worldfootball.net/teams/real-madrid/1/	https://www.worldfootball.net/teams/real-madrid/2017/2/
28	Sevilla FC	https://www.worldfootball.net/teams/sevilla-fc/1/	https://www.worldfootball.net/teams/sevilla-fc/2017/2/
29	SL Benfica	https://www.worldfootball.net/teams/sl-benfica/1/	https://www.worldfootball.net/teams/sl-benfica/2017/2/
30	Sporting CP	https://www.worldfootball.net/teams/sporting-cp/1/	https://www.worldfootball.net/teams/sporting-cp/2017/2/
31	SSC Napoli	https://www.worldfootball.net/teams/ssc-napoli/1/	https://www.worldfootball.net/teams/ssc-napoli/2017/2/
32	Tottenham Hotspur	https://www.worldfootball.net/teams/tottenham-hotspur/1/	https://www.worldfootball.net/teams/tottenham-hotspur/2017/2/
\.


--
-- Data for Name: team_results; Type: TABLE DATA; Schema: public; Owner: hunglai
--

COPY public.team_results (id, team_id, win_match, draw_match, lost_match, goal_scored, goal_against) FROM stdin;
8	8	5	2	3	28	16
26	26	0	2	4	4	11
18	18	1	2	3	6	12
2	2	6	2	4	22	20
3	3	8	2	2	15	9
19	19	9	3	1	22	7
27	27	9	3	1	36	18
15	15	0	2	4	3	12
25	25	0	3	3	6	15
32	32	2	1	3	6	6
11	11	0	3	3	5	11
13	13	0	0	6	0	15
23	23	2	2	2	5	3
12	12	1	2	3	8	6
6	6	1	4	1	9	14
20	20	1	1	4	9	24
30	30	1	0	5	5	8
31	31	3	2	3	13	14
1	1	4	2	2	20	16
29	29	3	2	3	11	14
7	7	1	2	3	5	12
9	9	0	3	3	5	16
24	24	4	3	1	18	13
17	17	3	2	3	9	6
28	28	4	2	2	9	6
22	22	3	3	2	18	16
4	4	2	5	1	10	8
10	10	0	0	6	2	14
16	16	2	3	1	7	2
21	21	5	2	3	11	10
5	5	6	0	4	27	14
14	14	6	1	3	26	12
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: hunglai
--

COPY public.teams (id, coach_names, team_name, color_kit, team_logo, head_coach_name) FROM stdin;
1	{"Neil Banfield","Steve Bould","Boro Primorac","Jan van Loon"}	Arsenal FC	red-white	https://s.hs-data.com/bilder/wappen/mittel/555.gif?fallback=png	Arsène Wenger
2	{"António Vieira","José Barros"}	AS Monaco	red-white	https://s.hs-data.com/bilder/wappen/mittel/562.gif?fallback=png	Leonardo Jardim
3	{"Germán Burgos",Vizcaíno}	Atlético Madrid	red-white-blue	https://s.hs-data.com/bilder/wappen/mittel/737.gif?fallback=png	Diego Simeone
4	{"Lars Kornetka","Xaver Zembrod"}	Bayer Leverkusen	red-black	https://s.hs-data.com/bilder/wappen/mittel/236.gif?fallback=png	Tayfun Korkut
5	{"Davide Ancelotti","Hermann Gerland"}	Bayern München	red-white	https://s.hs-data.com/bilder/wappen/mittel/222.gif?fallback=png	Carlo Ancelotti
6	\N	Beşiktaş	black-white	https://s.hs-data.com/bilder/wappen/mittel/794.gif?fallback=png	Şenol Güneş
7	{"Dirk Bremser","Frank Geideck"}	Bor. Mönchengladbach	green-white-black	https://s.hs-data.com/bilder/wappen/mittel/221.gif?fallback=png	Dieter Hecking
8	\N	Borussia Dortmund	black-yellow	https://s.hs-data.com/bilder/wappen/mittel/210.gif?fallback=png	\N
9	{"Chris Davies"}	Celtic FC	green-white	https://s.hs-data.com/bilder/wappen/mittel/1287.gif?fallback=png	Brendan Rodgers
10	\N	Club Brugge KV	blue-black	https://s.hs-data.com/bilder/wappen/mittel/1248.gif?fallback=png	Michel Preud'homme
11	{"Viktor Onopko","Ruslan Zubik"}	CSKA Moskva	red-blue	https://s.hs-data.com/bilder/wappen/mittel/1413.gif?fallback=png	Viktor Goncharenko
12	{"Oleg Luzhniy","Maksim Shatskikh"}	Dinamo Kiev	blue-white	https://s.hs-data.com/bilder/wappen/mittel/1365.gif?fallback=png	Serhiy Rebrov
13	\N	Dinamo Zagreb	blue-white	https://s.hs-data.com/bilder/wappen/mittel/1199.gif?fallback=png	Ivaylo Petev
14	{Barbarà,"Jesús Casas","Robert Moreno",Unzué}	FC Barcelona	blue-red	https://s.hs-data.com/bilder/wappen/mittel/530.gif?fallback=png	Luis Enrique
15	{"Markus Hoffmann","Marco Walker"}	FC Basel	red-blue	https://s.hs-data.com/bilder/wappen/mittel/606.gif?fallback=png	Urs Fischer
16	{"Brian Priske"}	FC København	blue-white	https://s.hs-data.com/bilder/wappen/mittel/1347.gif?fallback=png	Ståle Solbakken
17	\N	FC Porto	blue-white	https://s.hs-data.com/bilder/wappen/mittel/808.gif?fallback=png	\N
18	{"Dmitriy Kirichenko","Volodymyr Kulaev","Yakub Urazsakhatov"}	FK Rostov	yellow-blue	https://s.hs-data.com/bilder/wappen/mittel/3095.gif?fallback=png	Ivan Daniliants
19	{"Marco Landucci"}	Juventus	white-black	https://s.hs-data.com/bilder/wappen/mittel/511.gif?fallback=png	Massimiliano Allegri
20	\N	Legia Warszawa	red-white-green-black	https://s.hs-data.com/bilder/wappen/mittel/1155.gif?fallback=png	Jacek Magiera
21	{"Paolo Benetti"}	Leicester City	blue-white	https://s.hs-data.com/bilder/wappen/mittel/549.gif?fallback=png	Craig Shakespeare
22	{"Domènec Torrent","Brian Kidd","Mikel Arteta","Rodolfo Borrell"}	Manchester City	light blue-white	https://s.hs-data.com/bilder/wappen/mittel/750.gif?fallback=png	Pep Guardiola
23	{"Gérald Baticle",Caçapa}	Olympique Lyon	blue-red	https://s.hs-data.com/bilder/wappen/mittel/567.gif?fallback=png	Bruno Génésio
24	{"Zoumana Camara",Carcedo,"Victor Mañas",Villa}	Paris Saint-Germain	blue-red	https://s.hs-data.com/bilder/wappen/mittel/563.gif?fallback=png	Unai Emery
25	{"Petko Petkov"}	PFC Ludogorets Razgrad	\N	https://s.hs-data.com/bilder/wappen/mittel/15547.gif?fallback=png	Georgi Dermendjiev
26	{"Ruud Brood","Chris van der Weerden"}	PSV Eindhoven	red-white	https://s.hs-data.com/bilder/wappen/mittel/1425.gif?fallback=png	Phillip Cocu
27	{"David Bettoni","Hamidou Msaidie"}	Real Madrid	white-blue	https://s.hs-data.com/bilder/wappen/mittel/532.gif?fallback=png	Zinédine Zidane
28	{Lillo}	Sevilla FC	red-white	https://s.hs-data.com/bilder/wappen/mittel/529.gif?fallback=png	\N
29	{"Arnaldo Teixeira",Pietra,Serginho}	SL Benfica	red-white	https://s.hs-data.com/bilder/wappen/mittel/811.gif?fallback=png	Rui Vitória
30	{"Raúl José"}	Sporting CP	green-white	https://s.hs-data.com/bilder/wappen/mittel/809.gif?fallback=png	Jorge Jesus
31	{"Francesco Calzona"}	SSC Napoli	blue-white	https://s.hs-data.com/bilder/wappen/mittel/732.gif?fallback=png	Maurizio Sarri
32	{"Miguel D'Agostino","Jesús Pérez"}	Tottenham Hotspur	blue-white	https://s.hs-data.com/bilder/wappen/mittel/552.gif?fallback=png	Mauricio Pochettino
\.


--
-- Name: match_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hunglai
--

SELECT pg_catalog.setval('public.match_results_id_seq', 125, true);


--
-- Name: matches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hunglai
--

SELECT pg_catalog.setval('public.matches_id_seq', 125, true);


--
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hunglai
--

SELECT pg_catalog.setval('public.players_id_seq', 998, true);


--
-- Name: scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hunglai
--

SELECT pg_catalog.setval('public.scores_id_seq', 380, true);


--
-- Name: stadiums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hunglai
--

SELECT pg_catalog.setval('public.stadiums_id_seq', 38, true);


--
-- Name: team_links_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hunglai
--

SELECT pg_catalog.setval('public.team_links_id_seq', 32, true);


--
-- Name: team_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hunglai
--

SELECT pg_catalog.setval('public.team_results_id_seq', 32, true);


--
-- Name: teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hunglai
--

SELECT pg_catalog.setval('public.teams_id_seq', 32, true);


--
-- Name: match_results match_results_pkey; Type: CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.match_results
    ADD CONSTRAINT match_results_pkey PRIMARY KEY (id);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: scores scores_pkey; Type: CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_pkey PRIMARY KEY (id);


--
-- Name: stadiums stadiums_pkey; Type: CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.stadiums
    ADD CONSTRAINT stadiums_pkey PRIMARY KEY (id);


--
-- Name: team_links team_links_pkey; Type: CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.team_links
    ADD CONSTRAINT team_links_pkey PRIMARY KEY (id);


--
-- Name: team_results team_results_pkey; Type: CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.team_results
    ADD CONSTRAINT team_results_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: matches match_insert_trigger; Type: TRIGGER; Schema: public; Owner: hunglai
--

CREATE TRIGGER match_insert_trigger AFTER INSERT ON public.matches FOR EACH ROW EXECUTE FUNCTION public.match_insert();


--
-- Name: teams team_delete_trigger; Type: TRIGGER; Schema: public; Owner: hunglai
--

CREATE TRIGGER team_delete_trigger AFTER DELETE ON public.teams FOR EACH ROW EXECUTE FUNCTION public.team_delete();


--
-- Name: match_results trigger_auto_insert_teamresult; Type: TRIGGER; Schema: public; Owner: hunglai
--

CREATE TRIGGER trigger_auto_insert_teamresult AFTER INSERT ON public.match_results FOR EACH ROW EXECUTE FUNCTION public.func_handle_action();


--
-- Name: match_results match_results_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.match_results
    ADD CONSTRAINT match_results_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id);


--
-- Name: matches matches_awayteam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_awayteam_id_fkey FOREIGN KEY (awayteam_id) REFERENCES public.teams(id);


--
-- Name: matches matches_hometeam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_hometeam_id_fkey FOREIGN KEY (hometeam_id) REFERENCES public.teams(id);


--
-- Name: matches matches_stadium_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_stadium_id_fkey FOREIGN KEY (stadium_id) REFERENCES public.stadiums(id);


--
-- Name: players players_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: scores scores_assist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_assist_id_fkey FOREIGN KEY (assist_id) REFERENCES public.players(id);


--
-- Name: scores scores_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id);


--
-- Name: scores scores_scorer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_scorer_id_fkey FOREIGN KEY (scorer_id) REFERENCES public.players(id);


--
-- Name: stadiums stadiums_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.stadiums
    ADD CONSTRAINT stadiums_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: team_results team_results_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hunglai
--

ALTER TABLE ONLY public.team_results
    ADD CONSTRAINT team_results_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- PostgreSQL database dump complete
--

