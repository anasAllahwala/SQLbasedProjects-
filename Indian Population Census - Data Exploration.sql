-- so we have imported our datasets into the database Indian Cencus
-- lets see how does it look

select * from [Indian Cencus (Data Exploration)]..DataSet1;
select * from [Indian Cencus (Data Exploration)]..DataSet2;

-- If I want to know the total number of rows in each data set

select count (*) from [Indian Cencus (Data Exploration)]..DataSet1;

select count (*) from [Indian Cencus (Data Exploration)]..DataSet2;

--Now I want to extract data only from the states Jharkhand and Bihar 

select * from [Indian Cencus (Data Exploration)]..DataSet1 
where State in('jharkhand', 'Bihar');

-- Lets make a use of SUM Function by calculating total population of India 

select *from [Indian Cencus (Data Exploration)]..DataSet2;
select sum(population) from [Indian Cencus (Data Exploration)]..DataSet2;

-- lets see the avg growth rate in population of the country 

select state, AVG(growth)*100 as avg_growth from [Indian Cencus (Data Exploration)]..DataSet1 group by State;

-- Avaerage sex ratio but we dont want the decimal points so lets get rid of them using round function
select state, round(AVG(Sex_ratio),0) as avg_sex_ratio from [Indian Cencus (Data Exploration)]..DataSet1 group by State;

-- wanna do the same thing but this time I want it in the order by highest to lowest sex ratio 

select state, round(avg(Sex_ratio),0) as avg_sex_ratio from [Indian Cencus (Data Exploration)]..DataSet1 group by State order by avg_sex_ratio desc;

-- now its time for average literacy rate from highest to lowest

select state, avg(Literacy) as avg_literacy_rate from [Indian Cencus (Data Exploration)]..DataSet1 group by State order by avg_literacy_rate desc;

-- now lets say I only want to fetch the the states where average literracy rate is above 90, so I will be using having clause not 'where' clause because
-- where clause is used to filter out the rows and 'having' clause is used to filter out the aggregated rows like group by function aggregate the rows so if im 
-- using group by function then I will use 'having' clause too.

select state, round(avg(Literacy),0) as avg_literzacy_rate from [Indian Cencus (Data Exploration)]..DataSet1 group by State having ROUND(avg(Literacy),0)>90
order by avg_literzacy_rate;

-- Note: please note that having clause needs to be insertef before order by else the server will throw error.

-- top 3 states showing the highest growth ratio 
select top 3 state, avg(growth)*100 as avg_growth_ratio 
from [Indian Cencus (Data Exploration)]..DataSet1 
group by State order by avg_growth_ratio desc;



--bottom 3 states showing the lowest sex ratio 
select top 3 state, ROUND(avg(sex_ratio),0) as avg_sex_ratio 
from [Indian Cencus (Data Exploration)]..DataSet1 
group by State order by avg_sex_ratio asc;

-- display the top 3 and bottom 3 states combined in a table with respect to average literacy ratio 
drop table if exists #topStates;
create table #topStates(
States varchar (255),
growth_ratio float
)

insert into #topStates
select state, ROUND(avg(Literacy),0) as avg_literacy_ratio 
from [Indian Cencus (Data Exploration)]..DataSet1 
group by State order by avg_literacy_ratio desc;

drop table if exists #bottomStates;
create table #bottomStates(
States varchar (255),
Growth_ratio float
)
insert into #bottomStates
select state, ROUND(avg(sex_ratio),0) as avg_literacy_ratio
from [Indian Cencus (Data Exploration)]..DataSet1 
group by State order by avg_literacy_ratio asc; 


select * from (
select top 3 * from #topstates order by #topstates.growth_ratio desc) a

union

select * from (
select top 3 * from #bottomstates order by #bottomstates.Growth_ratio asc) b;

-- states starting with letter a
select Distinct State from [Indian Cencus (Data Exploration)]..DataSet1 where LOWER(state) like 'a%' or  lower(state)like'b%' order by State;

-- states starting with letter a and ending with letter m
select Distinct state from [Indian Cencus (Data Exploration)]..DataSet1 
where LOWER(state) like 'a%' and lower(state) like '%m';

--Joinning both tables 
-- So in this query we are going to join the tables and also perform some statistical calculation first to calcualte the total nmber of males and females 
-- but first lets use the join

select a.District,a.State, a.Sex_Ratio, b.Population from [Indian Cencus (Data Exploration)]..DataSet1 a inner join 
[Indian Cencus (Data Exploration)]..DataSet2 b on 
a.District=b.District;

-- so two tables have been joined successfully and now what we need to so is use the statistical formula to find out the number of males and females 
-- cuz we are only given the total population for each state and the sex ratio only
-- so sex ration = females/males  ----- eq 1
-- population = males + females ------- eq 2
-- females = population - males ------- eq 3

-- substituting eq 3 in eq 1
-- sex ratio = (population - males)/males
-- sex ratio * males = population - males 
-- population = males(sex ration +1)
-- males = population/(sex ratio +1)------ eq 4 

-- females = population - ((population/(sex ratio +1))

-- so we have derived the two equations for males and femaels respesctively
-- lets rewrite the query first 
-- we will be making use of sub queires too to find out this insigh 

select d.state, sum(d.NumberOfMales) as total_males, sum(d.NumberOfFemales) as total_females from (
select District, State, round((population/(sex_ratio +1)),0) as NumberOfMales, round(population -(population/(sex_ratio+1)),0) NumberOfFemales, Population from(
select a.District, a.State, a.Sex_ratio/1000 as sex_ratio, b.population from [Indian Cencus (Data Exploration)]..DataSet1 a inner join
[Indian Cencus (Data Exploration)]..DataSet2 b  on a.District=b.District) c)d group by State;

-- now we need to calcualate the total number of literate people and total number of illiterate people 
-- but we are only given the population and literacy ratio 
-- so we need to derive the statistical formula to calculate the total number of literate people
-- and total number of illiterate people
-- number_literate_people = population*literacy_rate
-- number of illiteraete_people = 1 - populationn*illiteracy_Rate


select d.State, sum(d.Total_Literate_people) as Sum_of_LiteratePeople, sum(d.Total_IlliteratePeopel) as SumOfIlliteratePeople from(
select c.District, c.State, round((c.Population*(c.Literacy_rate/100)),0) as Total_Literate_people, 
round((c.Population-(c.Population*(c.Literacy_rate/100))),0) as Total_IlliteratePeopel from(
select a.District, a.State, a.Literacy/100 as Literacy_rate, b.population from [Indian Cencus (Data Exploration)]..DataSet1 a 
inner join [Indian Cencus (Data Exploration)]..DataSet2 b  on a.District=b.District) c)d group by State order by State;

-- Now we need to know the population of India in the previous census
-- the only thing we have in our table is population and the growth rate 
-- so once again we need to derive the formula to get the previous population

-- Population = previous_population*growthRate + previous population 
-- Population = previous_population(growthRate +1)
-- previous Population = population/(growthRate +1)

-- so we have the formula now 
-- we will have to use the Join again to join the two tables

select sum(m.Total_PreviousPopulation) as Total_Population_Of_India_Previously, sum(m.Total_Current_Population) as Total_Population_Of_India from(
select d.state, sum(d.PreviousPopulation) as Total_PreviousPopulation, sum(d.Current_Population) as Total_Current_Population from(
select c.district, c.State, round((c.population/(1+c.Growth)),0) as PreviousPopulation, c.Population as Current_Population from(
select a.District, a.State, a.Growth, b.Population from [Indian Cencus (Data Exploration)]..DataSet1 a inner join 
[Indian Cencus (Data Exploration)]..DataSet2 b on a.District=b.District)c)d group by State) m;

-- Window Function
-- Output top 3 districts from each state with highest literacy rate 

 select a.* from(
 select state, district, Literacy, rank() over (partition by state order by literacy desc) as rnk
 from [Indian Cencus (Data Exploration)]..DataSet1) a
 where a.rnk <= 3;








	




























