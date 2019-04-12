elapsedtime on;

select first,last,address,zip, total,rank() over (partition by zip order by total desc) as rnk from (select patient, sum(cost) as total from (select patient, cost from encounters  union  select patient, cost from immunizations union select patient, cost from medications   union  select patient, cost from procedures) a group by patient) b  join patients p on id = patient having rnk < 11 order by zip,total desc;

-- 3121 rows

SELECT * FROM (SELECT concat(p.first, ' ', p.LAST) AS name,p.address,m.total_cost AS expenses, p.zip,RANK() OVER (PARTITION BY zip ORDER BY m.total_cost DESC ) AS RANK  FROM patients p JOIN (SELECT patient, SUM(cost) AS total_cost  FROM ((SELECT patient, totalcost AS cost  FROM medications)  UNION ALL (SELECT patient, cost FROM immunizations )  UNION ALL (SELECT patient,cost FROM encounters)  UNION ALL (SELECT patient, cost FROM procedures))  GROUP BY patient ) m ON p.id = m.patient )  WHERE RANK <= 10;

-- 3121 rows

select * from (select rank() over (order by tot_expense desc) as rank,  tot_expense,address,patname,zip from(select sum(expense) tot_expense, address,patname,zip from(select sum(enc.cost) as expense,pat.address,  concat(pat.first,' ',pat.last) as PatName,pat.zip from patients as pat inner join encounters as enc on pat.id =  enc.patient   group by pat.first,pat.last,pat.address,pat.zip union  select sum(proc.cost) as expense,pat.address, concat(pat.first,' ',pat.last) as PatName, pat.zip from patients as pat inner join procedures as proc on pat.id =  proc.patient  group by pat.first,pat.last,pat.address,pat.zip union  select sum(imm.cost) as expense,pat.address, concat(pat.first,' ',pat.last) as PatName, pat.zip from patients as pat inner join immunizations as imm on pat.id =  imm.patient   group by pat.first,pat.last,pat.address,pat.zip union  select sum(med.cost) as expense,pat.address, concat(pat.first,' ',pat.last) as PatName, pat.zip from patients as pat  inner join medications as med on pat.id =  med.patient   group by pat.first,pat.last,pat.address,pat.zip)  group by address,patname,zip)) as res where rank <=10;

-- 10 rows

select zip, id, tot_cost, rank  from (select zip, id, tot_cost, dense_rank() over (partition by zip order by tot_cost desc) as rank  from (select p.id, p.zip, (e.cost + i.cost + m.cost + pr.cost) tot_cost  from patients p, encounters e, immunizations i, medications m, procedures pr  where p.id = e.patient and e.patient = i.patient and i.patient = m.patient  and m.patient = pr.patient and e.id = i.encounter and e.id = m.encounter and e.id = pr.encounter))  where rank < 11;

-- 3445 rows

SELECT * FROM (SELECT PREFIX,FIRST,LAST,SUFFIX,MAIDEN,ZIP,EXPENSES,row_number()  over(partition by t1.ZIP order by EXPENSES desc) as RANK FROM PATIENTS t1 INNER JOIN (SELECT  p.patient, sum(p.cost) AS EXPENSES   FROM (SELECT COST, PATIENT FROM Immunizations   UNION  SELECT COST, PATIENT FROM Encounters   UNION   SELECT COST, PATIENT FROM Medications UNION SELECT COST, PATIENT FROM Procedures) as p  group by p.patient) ON t1.ID = p.PATIENT)  where RANK <= 10 ORDER BY ZIP;

-- 3121 rows

With patients_with_totalcost as(select p.*, (e.Ecost+i.Icost+m.Mcost+pr.Pcost) as TotalCost  from patients p inner join (select patient, sum(cost) as Ecost  from Encounters group by patient) e on p.ID = e.patient inner join (select patient, sum(cost) as Icost  from Immunizations group by patient) i on p.ID = i.patient inner join (select patient, sum(cost) as Mcost  from Medications group by patient) m on p.ID = m.patient inner join (select patient, sum(cost) as Pcost  from Procedures group by patient) pr on p.ID = pr.patient), Topten as(SELECT *, RANK() over (PARTITION BY zip  order by totalcost desc) AS RowNo  FROM patients_with_totalcost)  select zip,first,last,address,city,totalcost from Topten WHERE RowNo <= 10;

-- 3116 rows

select p.zip,p.FIRST,p.ADDRESS,m.TOTALCOST from PATIENTS p , medications m where p.ID = m.PATIENT  group by p.zip,p.FIRST,p.ADDRESS,m.totalcost order by m.totalcost desc limit 10;

-- 10 rows

SELECT DISTINCT sqei.ID,sqei.Zip,(TotalEICost+m.cost) as TotalEMICost  FROM Medications m JOIN (select DISTINCT p.ID,p.Zip,(e.cost + i.cost ) as TotalEICost  FROM Patients p  JOIN Encounters e ON p.ID=e.Patient  JOIN Immunizations i ON i.Patient=p.ID) sqei ON sqei.ID=m.Patient  ORDER BY TotalEMICost DESC;

select description, sum(cost) as total from medications group by description order by total desc limit 10;
-- 10 rows

SELECT * FROM (SELECT code, expenses, RANK() OVER ( ORDER BY expenses DESC ) AS RANK  FROM  (SELECT code, SUM(TOTALCOST) AS expenses   FROM medications   GROUP BY code )) WHERE RANK <= 10;

select description,sum(cost) as totcost  from medications group by description  order by totcost  desc  limit 10;

select code,sum(cost) as totcost  from medications group by code  order by totcost  desc  limit 10;

select sum(TOTALCOST) , DESCRIPTION  from medications group by DESCRIPTION  order by 1 desc limit 10;

select description, sum(totalcost) as total_cost, count(totalcost) as cnt  from medications group by description  order by total_cost desc limit 10;

SELECT CODE, DESCRIPTION, COUNT(CODE) AS SPEND_COUNT  FROM MEDICATIONS GROUP BY CODE, DESCRIPTION  ORDER BY SPEND_COUNT DESC LIMIT 10;

select code, description, sum(cost) medcosts  from medications group by code, description  order by medcosts desc limit 10;

select code, sum(cost) as total_cost  from medications group by code  order by sum(cost) desc limit 10;

SELECT CAST(sum(m.TOTALCOST) as int) as medicost,m.DESCRIPTION  from MEDICATIONS m ,PATIENTS p  where p.ID=m.PATIENT  group by m.DESCRIPTION order by medicost desc limit 10;

select code,description, max(totalcost) costs  from medications  group by code,description order by costs desc limit 10;

SELECT DISTINCT code,description,sum(cost) OVER (PARTITION BY code) AS sum FROM Medications ORDER BY sum DESC LIMIT 10;

select medi.description, max(medi.cost) amount  from patients p, medications medi  where p.id=medi.patient group by medi.description order by amount desc limit 10;

create table weak_hearts as
select patient from (
  select
    patient,
    case when description = 'Major depression  single episode' then 1 else 0 end as attack_once,
    case when description = 'Major depression disorder'        then 1 else 0 end as attacked
  from conditions
) c
group by patient
having
  sum(attack_once) = 0 and
  sum(attacked)    > 0;

with disordered_ethnics as (select p.ethnicity, count(1) as disordered from weak_hearts t join patients p on t.patient = p.id group by ethnicity)
select * from (
  select * from disordered_ethnics order by disordered desc limit 10
  union
  select * from disordered_ethnics order by disordered asc  limit 5
)
order by disordered desc;

-- 15 rows

CREATE VIEW IF NOT EXISTS depression_patients_group_by_ethnicity  AS SELECT p.ethnicity,COUNT(1)  AS COUNT FROM conditions c  JOIN patients p ON p.id = c.patient  WHERE description LIKE '%Major depression disorder%' GROUP BY p.ethnicity;

SELECT * FROM  ( (SELECT * FROM (SELECT ethnicity, COUNT,RANK() OVER (ORDER BY COUNT DESC)  AS RANK FROM depression_patients_group_by_ethnicity) WHERE RANK <= 10)  UNION ALL  (SELECT * FROM (SELECT ethnicity,COUNT,- RANK() OVER (ORDER BY COUNT ASC)  AS RANK FROM depression_patients_group_by_ethnicity ) WHERE RANK >= -5 ))  ORDER BY RANK;


select * from (select count(pat.id) numppl,ethnicity
from encounters enc
inner join patients pat on pat.id = enc.patient
where REASONDESCRIPTION = 'Major depression disorder'
group by ethnicity order by numppl desc limit 10
union  select count(pat.id) numppl,ethnicity
from encounters enc
inner join patients pat on pat.id = enc.patient
where REASONDESCRIPTION = 'Major depression disorder'
group by ethnicity order by numppl  limit 5 )  as res order by numppl desc;

create view hview as select p.id, p.ETHNICITY from patients p, conditions c  where p.id = c.patient and c.description = 'Hypertension';
create view hviewethgroup as select count(*) cnt, ETHNICITY  from hview  group by ETHNICITY order by cnt desc;
select ethnicity, cnt  from (select * from hviewethgroup limit 10  union select * from (select * from hviewethgroup order by cnt) limit 5)  order by cnt desc;

select Ethnicity,count(*) Count  from patients where id  in (select PATIENT from conditions where DESCRIPTION like 'Major depression disorder' and DESCRIPTION not like 'Major depression  single episode') group by Ethnicity order by 2 desc limit 10 Union select Ethnicity,count(*) Count from patients where id in (select PATIENT from conditions where DESCRIPTION like  'Major depression disorder' and DESCRIPTION not like 'Major depression  single episode') group by Ethnicity order by 2 asc limit 5;

SELECT * FROM ((SELECT Ethnicity, COUNT(Ethnicity) AS Ethnicity_Count  FROM PATIENTS AS P
INNER JOIN (select PATIENT FROM CONDITIONS WHERE DESCRIPTION='Major depression disorder') AS C
ON  C.PATIENT=P.ID  GROUP BY  Ethnicity ORDER BY Ethnicity_Count DESC  LIMIT 10)
UNION
(SELECT Ethnicity, COUNT(Ethnicity) AS Ethnicity_Count FROM PATIENTS AS P
INNER JOIN (select PATIENT FROM CONDITIONS WHERE DESCRIPTION='Major depression disorder') AS C
ON  C.PATIENT=P.ID
GROUP BY  Ethnicity ORDER BY Ethnicity_Count ASC LIMIT 5)) AS V  ORDER BY V.Ethnicity_Count;

drop view if exists top_ethnicity_with_major_depression;
create view ethnicity_count_with_major_depression  as select p.ETHNICITY, count(1) as count
from PATIENTS as p, CONDITIONS as c
where p.ID = c.PATIENT and c.DESCRIPTION like 'Major depression disorder' group by 1;
drop view if exists ethnicity_without_single_episode;
create view ethnicity_without_single_episode  as select distinct(p2.ETHNICITY)
from PATIENTS as p2, CONDITIONS as c2
where p2.ID = c2.PATIENT and c2.DESCRIPTION not like 'Major depression  single episode';
select * from  (select * from ETHNICITY_COUNT_WITH_MAJOR_DEPRESSION
where ETHNICITY in (select ETHNICITY from ETHNICITY_WITHOUT_SINGLE_EPISODE)
order by count desc limit 10
union
select * from ETHNICITY_COUNT_WITH_MAJOR_DEPRESSION
where ETHNICITY in (select ETHNICITY from ETHNICITY_WITHOUT_SINGLE_EPISODE)
order by count asc limit 5)
order by count;

SELECT ethnicity,max FROM(SELECT p.ethnicity,count(p.ID) as max  FROM PATIENTS p,conditions c  where p.ID = c.PATIENT AND c.description='Major depression disorder'  group by p.ethnicity order by max desc limit 10 UNION SELECT p.ethnicity,count(p.ID)  as min FROM PATIENTS p,conditions c  where p.ID = c.PATIENT AND c.description='Major depression disorder'  group by p.ethnicity order by min asc limit 5)  group by ethnicity,max order by max desc;

(SELECT COUNT(ethnicity) as PATIENT_COUNT, ethnicity  FROM patients  WHERE id IN (SELECT patient FROM conditions WHERE description = 'Major depression disorder')  GROUP BY ethnicity ORDER BY COUNT(ethnicity) DESC LIMIT 10)  UNION  (SELECT COUNT(ethnicity) as PATIENT_COUNT, ethnicity  FROM patients  WHERE id IN (SELECT patient FROM conditions WHERE description = 'Major depression disorder')  GROUP BY ethnicity ORDER BY COUNT(ethnicity) ASC LIMIT 5);

SELECT * FROM  (SELECT * FROM (SELECT COUNT(1) as eth_count,p.Ethnicity  FROM Patients p JOIN Conditions c ON c.Patient=p.ID  WHERE c.description='Major depression disorder' AND c.Description<>'Major depression  single episode'  GROUP BY p.Ethnicity ORDER BY eth_count DESC LIMIT 10) a  union  SELECT * FROM (SELECT COUNT(1) as eth_count,p.Ethnicity  FROM Patients p  JOIN Conditions c ON c.Patient=p.ID  WHERE c.description='Major depression disorder' AND c.Description<>'Major depression  single episode'  GROUP BY p.Ethnicity ORDER BY eth_count ASC LIMIT 5) b) ORDER BY eth_count DESC;

select p1.ethnicity from patients p1  join conditions c1 on p1.id=c1.patient  where c1.Description='Major depression disorder' AND c1.patient not in  (select c1.patient from conditions c1 where c1.description='Major depression  single episode') group by ethnicity order by count(ID) desc limit 10;

select count(1) as count, p.ethnicity from patients p, conditions condi  where p.id=condi.patient and condi.description='Major depression disorder'   group by ethnicity order by count desc limit 10  union   select count(1) as count, p.ethnicity from patients p, conditions condi  where p.id=condi.patient and condi.description='Major depression disorder'   group by ethnicity order by count  limit 5;

SELECT ethnicity, patients_count FROM ((select count(*) as patients_count, ethnicity from patients  where id in (select patient from conditions   where description LIKE 'Major depression%' AND description <> 'Major depression  single episode')  group by ethnicity order by count(ethnicity) desc limit 10) union (select count(*) as patients_count, ethnicity from patients  where id in (select patient from conditions where description LIKE 'Major depression%' AND description <> 'Major depression  single episode') group by ethnicity order by count(ethnicity) asc limit 5)) ORDER BY patients_count desc;

select * from (select count(1) numberOfPatient, p.ethnicity, concat('1',' Top 10 ethnicities') as filter  from Patients p ,encounters e, careplans ca, conditions c where p.id=e.patient and p.id = ca.patient and p.id=c.patient and  e.reasoncode=370143000 and e.reasoncode<>36923009 and ca.reasoncode=370143000 and  ca.reasoncode<>36923009 and c.code = 370143000 and c.code<>36923009  group by p.ethnicity order by numberOfPatient desc limit 10  union select count(1) numberOfPatient, p.ethnicity, concat('2',' Bottom 5 Ethnicities') as filter  from Patients p ,encounters e, careplans ca, conditions c  where p.id=e.patient and p.id = ca.patient and p.id=c.patient and e.reasoncode=370143000  and e.reasoncode<>36923009 and ca.reasoncode=370143000 and ca.reasoncode<>36923009 and  c.code = 370143000 and c.code<>36923009 group by p.ethnicity  order by numberOfPatient asc limit 5) order by filter asc,numberOfPatient desc;

select description, count(1) as uses from medications where reasondescription = 'Hypertension' group by description order by uses desc;

--2 rows

SELECT code, description, SUM(dispenses) AS dispenses  FROM MEDICATIONS  WHERE reasondescription = 'Hypertension'  GROUP BY code, description ORDER BY DISPENSES LIMIT 10;

create table q using column as select patient from
(select  *, case when description in ('Anti-suicide psychotherapy', 'Psychiatry care plan', 'Major depressive disorder clinical management plan') then 1 else 0 end  as coverage
from careplans) c
group by patient having sum(coverage) = 0;
select p.first, p.last from q join patients p on id = patient where id in (select patient from weak_hearts);
-- 39 rows


SELECT c.patient FROM (SELECT DISTINCT patient FROM CONDITIONS WHERE description = 'Major depression disorder') c
LEFT JOIN (SELECT DISTINCT patient FROM careplans
WHERE description  IN ('Anti-suicide psychotherapy','Psychiatry care plan','Major depressive disorder clinical management plan')
AND reasondescription = 'Major depression disorder') cp  ON c.patient = cp.patient WHERE cp.patient IS NULL;
--48 rows

select zip, sum(expired) as unshielded from patients p
join (select patient,  case when stop is null then 0 else 1 end as expired from careplans) c
on c.patient = p.id  where deathdate is null group by zip order by unshielded desc limit 10;
-- 10 rows

SELECT * FROM (SELECT city, state , zip, RANK() OVER (ORDER BY COUNT DESC) AS RANK, COUNT
FROM (SELECT COUNT(id) AS COUNT, zip, city, state FROM  (SELECT DISTINCT p.id, p.zip, p.city, p.STATE
FROM PATIENTS p
LEFT JOIN (SELECT DISTINCT patient FROM careplans WHERE stop IS NULL) c
ON p.id = c.patient WHERE c.patient IS NULL AND p.deathdate IS NULL )
GROUP BY zip, city, state ) )  WHERE RANK <= 10;

select *, rank() over(partition by description order by allergics desc) as rnk
from (select zip, description, count(*) as allergics from patients p
join allergies a on a.patient = p.id
where description in ('Allergy to tree pollen', 'House dust mite allergy')
group by zip, a.description) q  having rnk < 3 order by description, rnk;
-- 4 rows

SELECT * FROM ( SELECT COUNT, description, zip, city, state, RANK()  OVER ( PARTITION BY description ORDER BY COUNT DESC) AS RANK  FROM (SELECT COUNT(patient) COUNT, description, zip, city, state  FROM (SELECT a.patient, a.description, p.zip, p.city, p.state  FROM allergies a JOIN patients p ON a.patient = p.id  WHERE a.description IN ('Allergy to tree pollen', 'House dust mite allergy') )  GROUP BY description, zip, city, state)) WHERE RANK <= 2;

select *, dense_rank() over(distribute by age_group order by diseasecount desc) as rnk
from (select age_group, c.description, count(1) as diseasecount
from conditions c
join (select  *, cast((year(coalesce(deathdate, current_timestamp())) - year(birthdate))/10 as int)  as age_group from patients) p
on c.patient = p.id
group by age_group, c.description) q having rnk < 4
order by age_group;
-- 44 rows

SELECT condition_code, description, CONCAT(age_range, '0 to ', age_range + 1, '0')  AS age_range, COUNT, RANK
FROM  ( SELECT code AS condition_code, description, age_range, COUNT,  RANK() OVER (PARTITION BY age_range ORDER BY COUNT DESC) AS RANK
FROM (SELECT COUNT(*) COUNT, code, description, age_range
FROM (SELECT p.id, c.description, c.code,  CEIL(datediff(COALESCE( p.DEATHDATE, CURRENT_DATE()), p.birthdate)/ 3650) AS age_range
FROM conditions c
JOIN patients p ON p.id = c.patient)
WHERE age_range >= 0
GROUP BY code, description, age_range))
WHERE RANK <= 3;
-- 39 rows

with temp as (select c.description as condition, avg(pr.cost) as procedure_avg_cost
from patients p
join conditions c on c.patient = p.id
join procedures pr on p.id = pr.patient  group by c.description)
select *, procedure_avg_cost - avg_cost as deviation   from temp t cross join (select avg(procedure_avg_cost) as avg_cost from temp) q;
-- 158 rows

SELECT condition_code, CONDITION, average_cost_per_condition, average_cost_per_condition - average_cost  FROM  (SELECT reasoncode AS condition_code,reasondescription AS CONDITION,   total_cost / patient_count AS average_cost_per_condition, (SELECT SUM(totalcost) AS total_cost FROM MEDICATIONS)/(SELECT COUNT(DISTINCT patient) AS patient_count  FROM conditions) AS average_cost  FROM (SELECT reasoncode, reasondescription, SUM(totalcost) AS total_cost  FROM medications  GROUP BY reasoncode, reasondescription) m  JOIN (SELECT code, COUNT (DISTINCT patient) AS  patient_count  FROM conditions GROUP BY code) c ON m.reasoncode = c.code);
-- 39 rows

SELECT code,YEAR(start), DESCRIPTION, dispenses, AVG(dispenses) OVER (PARTITION BY code ORDER BY year(start) ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) FROM medications;

CREATE VIEW IF NOT EXISTS patient_expenses AS SELECT concat(p.first, ' ', p.LAST) AS name, p.city,m.total_cost AS expenses  FROM patients p  JOIN (SELECT patient, SUM(cost) AS total_cost  FROM ((SELECT patient, totalcost AS cost FROM medications) UNION ALL  (SELECT patient, cost FROM immunizations ) UNION ALL  (SELECT patient, cost FROM encounters)  UNION ALL (SELECT patient,cost FROM procedures))  GROUP BY patient ) m ON p.id = m.patient;
SELECT * FROM patient_expenses pe WHERE expenses > (SELECT AVG(expenses) FROM patient_expenses WHERE city = pe.city);
-- 32591 rows

SELECT code, dispenses, description FROM (SELECT SUM(dispenses) AS dispenses,code, description  FROM MEDICATIONS GROUP BY code, description) WHERE dispenses > (SELECT approx_percentile(dispenses, 1.0, 100) FROM medications);
-- 66 rows
