-- Generated by Oracle SQL Developer Data Modeler 19.4.0.350.1424
--   at:        2020-04-13 19:38:57 CEST
--   site:      Oracle Database 11g
--   type:      Oracle Database 11g

prompt #---------------------#
prompt #- Pomocne procedury -#
prompt #---------------------#

create or replace procedure SMAZ_VSECHNY_TABULKY AS
-- pokud v logu bude uvedeno, ze nektery objekt nebyl zrusen, protoze na nej jiny jeste existujici objekt stavi, spust proceduru opakovane, dokud se nezrusi vse
begin
  for iRec in 
    (select distinct OBJECT_TYPE, OBJECT_NAME,
      'drop '||OBJECT_TYPE||' "'||OBJECT_NAME||'"'||
      case OBJECT_TYPE when 'TABLE' then ' cascade constraints purge' else ' ' end as PRIKAZ
    from USER_OBJECTS where OBJECT_NAME not in ('SMAZ_VSECHNY_TABULKY', 'VYPNI_CIZI_KLICE', 'ZAPNI_CIZI_KLICE', 'VYMAZ_DATA_VSECH_TABULEK')
    ) loop
        begin
          dbms_output.put_line('Prikaz: '||irec.prikaz);
        execute immediate iRec.prikaz;
        exception
          when others then dbms_output.put_line('NEPOVEDLO SE!');
        end;
      end loop;
end;
/

create or replace procedure VYPNI_CIZI_KLICE as 
begin
  for cur in (select CONSTRAINT_NAME, TABLE_NAME from USER_CONSTRAINTS where CONSTRAINT_TYPE = 'R' ) 
  loop
    execute immediate 'alter table '||cur.TABLE_NAME||' modify constraint "'||cur.CONSTRAINT_NAME||'" DISABLE';
  end loop;
end VYPNI_CIZI_KLICE;
/


create or replace procedure ZAPNI_CIZI_KLICE as 
begin
  for cur in (select CONSTRAINT_NAME, TABLE_NAME from USER_CONSTRAINTS where CONSTRAINT_TYPE = 'R' ) 
  loop
    execute immediate 'alter table '||cur.TABLE_NAME||' modify constraint "'||cur.CONSTRAINT_NAME||'" enable validate';
  end loop;
end ZAPNI_CIZI_KLICE;
/

create or replace procedure VYMAZ_DATA_VSECH_TABULEK is
begin
  -- Vymazat data vsech tabulek
  VYPNI_CIZI_KLICE;
  for v_rec in (select distinct TABLE_NAME from USER_TABLES)
  loop
    execute immediate 'truncate table '||v_rec.TABLE_NAME||' drop storage';
  end loop;
  ZAPNI_CIZI_KLICE;
  
  -- Nastavit vsechny sekvence od 1
  for v_rec in (select distinct SEQUENCE_NAME  from USER_SEQUENCES)
  loop
    execute immediate 'alter sequence '||v_rec.SEQUENCE_NAME||' restart start with 1';
  end loop;
end VYMAZ_DATA_VSECH_TABULEK;
/

prompt #------------------------#
prompt #- Zrusit stare tabulky -#
prompt #------------------------#

exec SMAZ_VSECHNY_TABULKY;

prompt #-------------------------#
prompt #- Vytvorit nove tabulky -#
prompt #-------------------------#

CREATE TABLE adresa (
    id_adresa      INTEGER NOT NULL,
    mesto          VARCHAR2(50 CHAR),
    ulice          VARCHAR2(50 CHAR),
    cislo_popisne  INTEGER
);

ALTER TABLE adresa ADD CONSTRAINT adresa_pk PRIMARY KEY ( id_adresa );

CREATE TABLE body (
    id_body             INTEGER NOT NULL,
    pocet               INTEGER,
    umisteni_v_tabulce  INTEGER,
    id_zapasy    INTEGER NOT NULL
);

CREATE UNIQUE INDEX body__idx ON
    body (
        id_zapasy
    ASC );

ALTER TABLE body ADD CONSTRAINT body_pk PRIMARY KEY ( id_body );

CREATE TABLE druzstvo (
    id_druzstvo       INTEGER NOT NULL,
    nazev             VARCHAR2(50 CHAR),
    pocet_hracu       INTEGER,
    jmeno_vedouciho   VARCHAR2(50 CHAR),
    id_oddil    INTEGER NOT NULL,
    id_soutez  INTEGER NOT NULL
);

ALTER TABLE druzstvo ADD CONSTRAINT druzstvo_pk PRIMARY KEY ( id_druzstvo );

CREATE TABLE hrac (
    id_hrac             INTEGER NOT NULL,
    jmeno_a_prijmeni    VARCHAR2(50 CHAR),
    pohlavi             VARCHAR2(4 CHAR),
    datum_narozeni      DATE,
    telefonni_cislo     VARCHAR2(15 CHAR),
    id_postihy  INTEGER,
    id_palka      INTEGER NOT NULL
);

ALTER TABLE hrac ADD CONSTRAINT hrac_pk PRIMARY KEY ( id_hrac );

CREATE TABLE micky (
    id_vybaveni                    INTEGER NOT NULL,
    KVALITA_POCET_HVEZDICEK  INTEGER,
    prumer                         INTEGER
);

ALTER TABLE micky ADD CONSTRAINT micky_pk PRIMARY KEY ( id_vybaveni );

CREATE TABLE oddil (
    id_oddil  INTEGER NOT NULL,
    nazev     VARCHAR2(50 CHAR)
);

ALTER TABLE oddil ADD CONSTRAINT oddil_pk PRIMARY KEY ( id_oddil );

CREATE TABLE palka (
    id_palka                  INTEGER NOT NULL,
    nazev_potahu_na_forehand  VARCHAR2(50 CHAR),
    nazev_potahu_na_backhand  VARCHAR2(50 CHAR),
    nazev_dreva               VARCHAR2(50 CHAR)
);

ALTER TABLE palka ADD CONSTRAINT palka_pk PRIMARY KEY ( id_palka );

CREATE TABLE postihy (
    id_postihy                      INTEGER NOT NULL,
    pocet_cervenych_karet           INTEGER,
    pocet_zlutych_karet             INTEGER,
    suma_penezitych_trestu          INTEGER,
    pocet_pozitivnich_testu_doping  INTEGER
);

ALTER TABLE postihy ADD CONSTRAINT postihy_pk PRIMARY KEY ( id_postihy );

CREATE TABLE prepazky (
    id_vybaveni  INTEGER NOT NULL,
    barva        VARCHAR2(20 CHAR),
    rozmery      VARCHAR2(20 CHAR)
);

ALTER TABLE prepazky ADD CONSTRAINT prepazky_pk PRIMARY KEY ( id_vybaveni );

CREATE TABLE HALA_TO_MICKY (
    id_treninkova_hala  INTEGER NOT NULL,
    id_vybaveni        INTEGER NOT NULL
);

ALTER TABLE HALA_TO_MICKY ADD CONSTRAINT d_pk PRIMARY KEY ( id_treninkova_hala,
                                                         id_vybaveni );

CREATE TABLE STOLY_TO_SPONZOR (
    id_vybaveni   INTEGER NOT NULL,
    id_sponzor  INTEGER NOT NULL
);

ALTER TABLE STOLY_TO_SPONZOR ADD CONSTRAINT relation_12_pk PRIMARY KEY ( id_vybaveni,
                                                                    id_sponzor );

CREATE TABLE MICKY_TO_SPONZOR (
    id_vybaveni   INTEGER NOT NULL,
    id_sponzor  INTEGER NOT NULL
);

ALTER TABLE MICKY_TO_SPONZOR ADD CONSTRAINT relation_13_pk PRIMARY KEY ( id_vybaveni,
                                                                    id_sponzor );

CREATE TABLE PREPAZKY_TO_SPONZOR (
    id_vybaveni  INTEGER NOT NULL,
    id_sponzor    INTEGER NOT NULL
);

ALTER TABLE PREPAZKY_TO_SPONZOR ADD CONSTRAINT relation_14_pk PRIMARY KEY ( id_vybaveni,
                                                                    id_sponzor );

CREATE TABLE HALA_TO_PREPAZKY (
    id_treninkova_hala  INTEGER NOT NULL,
    id_vybaveni     INTEGER NOT NULL
);

ALTER TABLE HALA_TO_PREPAZKY ADD CONSTRAINT qq_pk PRIMARY KEY ( id_treninkova_hala,
                                                          id_vybaveni );

CREATE TABLE HALA_TO_STOLY (
    id_treninkova_hala  INTEGER NOT NULL,
    id_vybaveni        INTEGER NOT NULL
);

ALTER TABLE HALA_TO_STOLY ADD CONSTRAINT relation_20_pk PRIMARY KEY ( id_treninkova_hala,
                                                                    id_vybaveni );

CREATE TABLE DRUZSTVO_TO_HRAC (
    id_druzstvo  INTEGER NOT NULL,
    id_hrac          INTEGER NOT NULL
);

ALTER TABLE DRUZSTVO_TO_HRAC ADD CONSTRAINT relation_3_pk PRIMARY KEY ( id_druzstvo,
                                                                  id_hrac );

CREATE TABLE DRUZSTVO_TO_HALA (
    id_druzstvo     INTEGER NOT NULL,
    id_treninkova_hala  INTEGER NOT NULL
);

ALTER TABLE DRUZSTVO_TO_HALA ADD CONSTRAINT relation_7_pk PRIMARY KEY ( id_druzstvo,
                                                                  id_treninkova_hala );

CREATE TABLE soutez (
    id_soutez  INTEGER NOT NULL,
    nazev      VARCHAR2(50 CHAR)
);

ALTER TABLE soutez ADD CONSTRAINT soutez_pk PRIMARY KEY ( id_soutez );

CREATE TABLE sponzor (
    id_sponzor  INTEGER NOT NULL,
    nazev       VARCHAR2(50 CHAR)
);

ALTER TABLE sponzor ADD CONSTRAINT sponzor_pk PRIMARY KEY ( id_sponzor );

CREATE TABLE stoly (
    id_vybaveni    INTEGER NOT NULL,
    barva_povrchu  VARCHAR2(20 CHAR),
    rozmery        VARCHAR2(20 CHAR),
    vaha           INTEGER
);

ALTER TABLE stoly ADD CONSTRAINT stoly_pk PRIMARY KEY ( id_vybaveni );

CREATE TABLE treninkova_hala (
    id_treninkova_hala      INTEGER NOT NULL,
    rozloha                 VARCHAR2(10 CHAR),
    cena_pronajmu_za_mesic  INTEGER,
    id_adresa        INTEGER NOT NULL
);

ALTER TABLE treninkova_hala ADD CONSTRAINT treninkova_hala_pk PRIMARY KEY ( id_treninkova_hala );

CREATE TABLE vybaveni (
    id_vybaveni    INTEGER NOT NULL,
    pocet          INTEGER,
    znacka         VARCHAR2(30 CHAR),
    vybaveni_type  VARCHAR2(8 CHAR) NOT NULL
);

ALTER TABLE vybaveni
    ADD CONSTRAINT ch_inh_vybaveni CHECK ( vybaveni_type IN (
        'MICKY',
        'PREPAZKY',
        'STOLY'
    ) );

ALTER TABLE vybaveni ADD CONSTRAINT vybaveni_pk PRIMARY KEY ( id_vybaveni );

CREATE TABLE zapasy (
    id_zapasy                     INTEGER NOT NULL,
    pocet_za_sezonu               INTEGER,
    BILANCE_VYHER_PROHER_REMIZ  VARCHAR2(10 CHAR),
    uspesnost                     VARCHAR2(4 CHAR),
    id_hrac                  INTEGER NOT NULL,
    id_body                  INTEGER NOT NULL,
    id_soutez              INTEGER NOT NULL
);

CREATE UNIQUE INDEX zapasy__idx ON
    zapasy (
        id_body
    ASC );

CREATE UNIQUE INDEX zapasy__idxv1 ON
    zapasy (
        id_soutez
    ASC );

CREATE UNIQUE INDEX zapasy__idxv2 ON
    zapasy (
        id_hrac
    ASC );

ALTER TABLE zapasy ADD CONSTRAINT zapasy_pk PRIMARY KEY ( id_zapasy );

ALTER TABLE body
    ADD CONSTRAINT body_zapasy_fk FOREIGN KEY ( id_zapasy )
        REFERENCES zapasy ( id_zapasy );

ALTER TABLE HALA_TO_MICKY
    ADD CONSTRAINT d_micky_fk FOREIGN KEY ( id_vybaveni )
        REFERENCES micky ( id_vybaveni );

ALTER TABLE HALA_TO_MICKY
    ADD CONSTRAINT d_treninkova_hala_fk FOREIGN KEY ( id_treninkova_hala )
        REFERENCES treninkova_hala ( id_treninkova_hala );

ALTER TABLE druzstvo
    ADD CONSTRAINT druzstvo_oddil_fk FOREIGN KEY ( id_oddil )
        REFERENCES oddil ( id_oddil );

ALTER TABLE druzstvo
    ADD CONSTRAINT druzstvo_soutez_fk FOREIGN KEY ( id_soutez )
        REFERENCES soutez ( id_soutez );

ALTER TABLE hrac
    ADD CONSTRAINT hrac_palka_fk FOREIGN KEY ( id_palka )
        REFERENCES palka ( id_palka );

ALTER TABLE hrac
    ADD CONSTRAINT hrac_postihy_fk FOREIGN KEY ( id_postihy )
        REFERENCES postihy ( id_postihy );

ALTER TABLE micky
    ADD CONSTRAINT micky_vybaveni_fk FOREIGN KEY ( id_vybaveni )
        REFERENCES vybaveni ( id_vybaveni );

ALTER TABLE prepazky
    ADD CONSTRAINT prepazky_vybaveni_fk FOREIGN KEY ( id_vybaveni )
        REFERENCES vybaveni ( id_vybaveni );

ALTER TABLE HALA_TO_PREPAZKY
    ADD CONSTRAINT qq_prepazky_fk FOREIGN KEY ( id_vybaveni )
        REFERENCES prepazky ( id_vybaveni );

ALTER TABLE HALA_TO_PREPAZKY
    ADD CONSTRAINT qq_treninkova_hala_fk FOREIGN KEY ( id_treninkova_hala )
        REFERENCES treninkova_hala ( id_treninkova_hala );

ALTER TABLE STOLY_TO_SPONZOR
    ADD CONSTRAINT relation_12_sponzor_fk FOREIGN KEY ( id_sponzor )
        REFERENCES sponzor ( id_sponzor );

ALTER TABLE STOLY_TO_SPONZOR
    ADD CONSTRAINT relation_12_stoly_fk FOREIGN KEY ( id_vybaveni )
        REFERENCES stoly ( id_vybaveni );

ALTER TABLE MICKY_TO_SPONZOR
    ADD CONSTRAINT relation_13_micky_fk FOREIGN KEY ( id_vybaveni )
        REFERENCES micky ( id_vybaveni );

ALTER TABLE MICKY_TO_SPONZOR
    ADD CONSTRAINT relation_13_sponzor_fk FOREIGN KEY ( id_sponzor )
        REFERENCES sponzor ( id_sponzor );

ALTER TABLE PREPAZKY_TO_SPONZOR
    ADD CONSTRAINT relation_14_prepazky_fk FOREIGN KEY ( id_vybaveni )
        REFERENCES prepazky ( id_vybaveni );

ALTER TABLE PREPAZKY_TO_SPONZOR
    ADD CONSTRAINT relation_14_sponzor_fk FOREIGN KEY ( id_sponzor )
        REFERENCES sponzor ( id_sponzor );

ALTER TABLE HALA_TO_STOLY
    ADD CONSTRAINT relation_20_stoly_fk FOREIGN KEY ( id_vybaveni )
        REFERENCES stoly ( id_vybaveni );

ALTER TABLE HALA_TO_STOLY
    ADD CONSTRAINT relation_20_treninkova_hala_fk FOREIGN KEY ( id_treninkova_hala )
        REFERENCES treninkova_hala ( id_treninkova_hala );

ALTER TABLE DRUZSTVO_TO_HRAC
    ADD CONSTRAINT relation_3_druzstvo_fk FOREIGN KEY ( id_druzstvo )
        REFERENCES druzstvo ( id_druzstvo );

ALTER TABLE DRUZSTVO_TO_HRAC
    ADD CONSTRAINT relation_3_hrac_fk FOREIGN KEY ( id_hrac )
        REFERENCES hrac ( id_hrac );

ALTER TABLE DRUZSTVO_TO_HALA
    ADD CONSTRAINT relation_7_druzstvo_fk FOREIGN KEY ( id_druzstvo )
        REFERENCES druzstvo ( id_druzstvo );

ALTER TABLE DRUZSTVO_TO_HALA
    ADD CONSTRAINT relation_7_treninkova_hala_fk FOREIGN KEY ( id_treninkova_hala )
        REFERENCES treninkova_hala ( id_treninkova_hala );

ALTER TABLE stoly
    ADD CONSTRAINT stoly_vybaveni_fk FOREIGN KEY ( id_vybaveni )
        REFERENCES vybaveni ( id_vybaveni );

ALTER TABLE treninkova_hala
    ADD CONSTRAINT treninkova_hala_adresa_fk FOREIGN KEY ( id_adresa )
        REFERENCES adresa ( id_adresa );

ALTER TABLE zapasy
    ADD CONSTRAINT zapasy_body_fk FOREIGN KEY ( id_body )
        REFERENCES body ( id_body );

ALTER TABLE zapasy
    ADD CONSTRAINT zapasy_hrac_fk FOREIGN KEY ( id_hrac )
        REFERENCES hrac ( id_hrac );

ALTER TABLE zapasy
    ADD CONSTRAINT zapasy_soutez_fk FOREIGN KEY ( id_soutez )
        REFERENCES soutez ( id_soutez );

CREATE OR REPLACE TRIGGER arc_fkarc_2_micky BEFORE
    INSERT OR UPDATE OF id_vybaveni ON micky
    FOR EACH ROW
DECLARE
    d VARCHAR2(8);
BEGIN
    SELECT
        a.vybaveni_type
    INTO d
    FROM
        vybaveni a
    WHERE
        a.id_vybaveni = :new.id_vybaveni;

    IF ( d IS NULL OR d <> 'MICKY' ) THEN
        raise_application_error(-20223, 'FK MICKY_VYBAVENI_FK in Table MICKY violates Arc constraint on Table VYBAVENI - discriminator column VYBAVENI_TYPE doesn''t have value ''MICKY''');
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER arc_fkarc_2_prepazky BEFORE
    INSERT OR UPDATE OF id_vybaveni ON prepazky
    FOR EACH ROW
DECLARE
    d VARCHAR2(8);
BEGIN
    SELECT
        a.vybaveni_type
    INTO d
    FROM
        vybaveni a
    WHERE
        a.id_vybaveni = :new.id_vybaveni;

    IF ( d IS NULL OR d <> 'PREPAZKY' ) THEN
        raise_application_error(-20223, 'FK PREPAZKY_VYBAVENI_FK in Table PREPAZKY violates Arc constraint on Table VYBAVENI - discriminator column VYBAVENI_TYPE doesn''t have value ''PREPAZKY''');
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER arc_fkarc_2_stoly BEFORE
    INSERT OR UPDATE OF id_vybaveni ON stoly
    FOR EACH ROW
DECLARE
    d VARCHAR2(8);
BEGIN
    SELECT
        a.vybaveni_type
    INTO d
    FROM
        vybaveni a
    WHERE
        a.id_vybaveni = :new.id_vybaveni;

    IF ( d IS NULL OR d <> 'STOLY' ) THEN
        raise_application_error(-20223, 'FK STOLY_VYBAVENI_FK in Table STOLY violates Arc constraint on Table VYBAVENI - discriminator column VYBAVENI_TYPE doesn''t have value ''STOLY''');
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                            23
-- CREATE INDEX                             4
-- ALTER TABLE                             52
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           3
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0