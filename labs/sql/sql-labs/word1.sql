-- Problem Statement 1
-- Jimmy, from the healthcare department, has requested a report that shows how the number of treatments each age category of patients 
-- has gone through in the year 2022. The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years)
-- Seniors (65 years and over).Assist Jimmy in generating the report. 
select count(*) 'Number of treatment',category from 
(select gender,age,if(age<15,'Child',if(age<25,'Youth',(if(age<65,'Adult','Senior')))) category,treatmentid from 
(select gender,timestampdiff(year,dob,date) age,treatmentID from patient inner join person on personID=patientid
natural join treatment where year(date)=2022)s)t group by category;

-- Problem Statement 2:  
-- Jimmy, from the healthcare department, wants to know which disease is infecting people of which gender more often.
-- Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio. Sort 
-- the data in a way that is helpful for Jimmy.
create view dc as select gender,diseasename from disease d,treatment t,patient p,person pe where pe.personid=p.patientid and p.patientid=t.patientid 
and t.diseaseid=d.diseaseid;
select male/female male_female_ratio,diseasename from
((select count(*) male,diseasename from dc where gender='male' group by diseasename)t1
natural join
(select count(*) female,diseasename from dc where gender='female' group by diseasename)t2); 

-- Problem Statement 3: 
-- Jacob, from insurance management, has noticed that insurance claims are not made for all the treatments.
-- He also wants to figure out if the gender of the patient has any impact on the insurance claim. Assist Jacob in this situation 
-- by generating a report that finds for each gender the number of treatments, number of claims, and treatment-to-claim ratio. 
-- And notice if there is a significant difference between the treatment-to-claim ratio of male and female patients.
with cte as 
(select gender,t.claimid claimid from treatment t,patient p,person pe where pe.personid=p.patientid and p.patientid=t.patientid)
select gender,treatment,claim,claim/treatment ratio from ((select count(*) treatment,gender from cte where gender='male' group by gender)a natural join 
(select count(*) claim,gender from cte where gender='male' and claimid is not null group by gender)b)
union 
select gender,treatment,claim,claim/treatment ratio from ((select count(*) treatment,gender from cte where gender='female' group by gender)c natural join 
(select count(*) claim,gender from cte where gender='female' and claimid is not null group by gender)d);

-- Problem Statement 4: 
-- The Healthcare department wants a report about the inventory of pharmacies. Generate a report on their behalf that 
-- shows how many units of medicine each pharmacy has in their inventory, the total maximum retail price of those medicines, and the total 
-- price of all the medicines after discount. 
-- Note: discount field in keep signifies the percentage of discount on the maximum price.
with cte as
(select pharmacyname,medicineid,maxprice,maxprice*((100-discount)/100) discount_price from keep natural join medicine natural join pharmacy)
select pharmacyname,count(medicineid) 'count',sum(maxprice) 'total price',sum(discount_price)'discounted price' from cte group by pharmacyname;

-- Problem Statement 5:  
-- The healthcare department suspects that some pharmacies prescribe more medicines than others in a single prescription, for them, generate a 
-- report that finds for each pharmacy the maximum, minimum and average number of medicines prescribed in their prescriptions. 
with cte as
(select prescriptionid,sum(quantity) total,pharmacyid from prescription natural join contain group by prescriptionid)
select pharmacyname,max(total)'maximum',min(total)'minimum',avg(total)'average' from pharmacy natural join cte group by pharmacyname; 
