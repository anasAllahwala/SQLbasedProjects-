create table employee(
emp_id int Primary key, 
first_name varchar(50),
last_name varchar(50),
birth_date date,
sex varchar(1),
salary int,
super_id int,
branch_id int 
);

create table branch(
branch_id int Primary key,
branch_name varchar(50),
mgr_id int,
mgr_start_date date,
Foreign Key (mgr_id) references employee(emp_id) on delete set null 
)

alter table employee
add foreign key(branch_id)
references branch(branch_id)
on delete set null;

ALTER TABLE employee
ADD FOREIGN KEY(super_id)
REFERENCES employee(emp_id)
ON DELETE SET NULL;


create table client (
client_id int Primary key,
client_name varchar(50),
branch_id int,
foreign key(branch_id) references branch(branch_id) 
on delete set null
);

create table works_with(
emp_id int,
client_id int, 
total_sales int,
primary key(emp_id, client_id),
foreign key(emp_id) references employee(emp_id) on delete cascade,
foreign key(client_id) references client(client_id) on delete cascade
);


create table branch_supplier(
branch_id int,
supplier_name varchar(40), 
supply_type varchar(40),
primary key (branch_id, supplier_name),
foreign key (branch_id) references branch(branch_id) on delete cascade 
);


insert into employee values(100, 'David', 'Wallace', '1967-11-17', 'M', 250000, null, null);
insert into branch values(1, 'Corporate', 100, '2006-02-09');

update employee
set branch_id = 1 
where emp_id = 100;

insert into employee values(101, 'Jan','Levinson', '1961-05-11', 'F', 111000, 100, 1);

INSERT INTO employee VALUES(102, 'Michael', 'Scott', '1964-03-15', 'M', 75000, 100, null);

insert into branch values(2, 'Scranton', 102, '1992-04-06');

update employee 
set branch_id = 2 where emp_id=102;

insert into employee values(103, 'Angela', 'Martin', '1971-07-25','F', 63000,102,2);
insert into employee values(104, 'Kelly', 'Kapoor', '1980-02-05', 'F', 55000, 102,2);
insert into employee values(105, 'Stanley', 'Hudson', '1958-02-19', 'M', 69000, 102,2);

insert into employee values(106, 'Josh', 'Porter', '1969-09-05', 'M', 78000, 100, null);

insert into branch values(3, 'Stamford',106, '1998-02-13');

update employee
set branch_id = 3 
where emp_id = 106;

insert into employee values(107, 'Andy','Bernard','1973-07-22', 'M', 65000, 106, 3);
insert into employee values(108, 'Jim', 'Halpart', '1978-10-01', 'M', 71000, 106, 3);

select * from client;
-- now lets populate client table:
INSERT INTO client VALUES(400, 'Dunmore Highschool', 2);
INSERT INTO client VALUES(401, 'Lackawana Country', 2);
INSERT INTO client VALUES(402, 'FedEx', 3);
INSERT INTO client VALUES(403, 'John Daly Law, LLC', 3);
INSERT INTO client VALUES(404, 'Scranton Whitepages', 2);
INSERT INTO client VALUES(405, 'Times Newspaper', 3);
INSERT INTO client VALUES(406, 'FedEx', 2);

-- now lets populate the works_with table 
insert into works_with values(105,400,55000);
insert into works_with values(102,401,267000);
insert into works_with values(108, 402, 22500);
insert into works_with values(107, 403, 5000);
insert into works_with values(108,403, 12000);
insert into works_with values(105,404,33000);
insert into works_with values(107, 405, 26000);
insert into works_with values(102,406,15000);
insert into works_with values(105, 406, 130000);


insert into branch_supplier values(2, 'Hammer Mill', 'Paper');
insert into branch_supplier values(2, 'Uni-ball', 'Writing Utensils');
insert into branch_supplier values(3, 'Patriot  Paper', 'Paper');
insert into branch_supplier values(2, 'J.T. Forms & Labels', 'Custom Forms');
insert into branch_supplier values(3, 'Uni ball', 'writing utensils');
insert into branch_supplier values(3, 'Hammer Mill', 'Paper');
insert into branch_supplier values(3, 'Stamford Lablels', 'Custom Forms');

select * from employee;
select * from client;
select * from branch;
select * from works_with;
select * from branch_supplier;


-- More basic Queries
-- Find all employees
SELECT *
FROM employee;

-- Find all clients
SELECT *
FROM client;

-- Find all employees ordered by salary
SELECT *
from employee
ORDER BY salary ASC/DESC;

-- Find all employees ordered by sex then name
SELECT *
from employee
ORDER BY sex, first_name;

-- Find the first 5 employees in the table
SELECT *
from employee
LIMIT 5;

-- Find the first and last names of all employees
SELECT first_name, employee.last_name
FROM employee;

-- Find the forename and surnames names of all employees
SELECT first_name AS forename, employee.last_name AS surname
FROM employee;

-- Find out all the different genders
SELECT DISCINCT sex
FROM employee;

-- Find all male employees
SELECT *
FROM employee
WHERE sex = 'M';

-- Find all employees at branch 2
SELECT *
FROM employee
WHERE branch_id = 2;

-- Find all employee's id's and names who were born after 1969
SELECT emp_id, first_name, last_name
FROM employee
WHERE birth_date >= 1970-01-01;

-- Find all female employees at branch 2
SELECT *
FROM employee
WHERE branch_id = 2 AND sex = 'F';

-- Find all employees who are female & born after 1969 or who make over 80000
SELECT *
FROM employee
WHERE (birth_date >= '1970-01-01' AND sex = 'F') OR salary > 80000;

-- Find all employees born between 1970 and 1975
SELECT *
FROM employee
WHERE birth_date BETWEEN '1970-01-01' AND '1975-01-01';

-- Find all employees named Jim, Michael, Johnny or David
SELECT *
FROM employee
WHERE first_name IN ('Jim', 'Michael', 'Johnny', 'David');


---------------------------------------------------------------Wild Cards and Like Operators--------------------------------------------------------
-- any client that is LLC
select * from client 
where client_name LIKE '%LLC';

-- Find any branch supplier who are in label business

select * from 
branch_supplier
where supplier_name like '%labels%';

--Find any employee in the month of October

select * from employee 
where birth_date like '____-10%';

-- Find any employee in the month of February

select * from employee 
where birth_date like '____-02%';

-----------------------------------------------------------------------------Unions------------------------------------------------------------------------------

-- Find a list of employee and branch names
SELECT employee.first_name AS Employee_Branch_Names
FROM employee
UNION
SELECT branch.branch_name
FROM branch;

-- Find a list of all clients & branch suppliers' names
SELECT client_name AS 'Non-Employee_Entities', client.branch_id AS Branch_ID
FROM client
UNION
SELECT branch_supplier.supplier_name, branch_supplier.branch_id
FROM branch_supplier;

---------------------------------------------------------------------JOINS-----------------------------------------------------------------------------------
insert into branch values(4, 'buffalo', null, null);

-- find all branches and the names of their managers 
select employee.emp_id, employee.first_name as branchManager, branch.branch_name
from employee
join branch 
on emp_id=mgr_id;

-- left join
select employee.emp_id , employee.first_name as branchManager, branch.branch_name
from employee
left join 
branch 
on employee.emp_id = branch.mgr_id;

-- right join 
select employee.emp_id, employee.first_name as branchManager, branch.branch_name
from employee 
right join
branch 
on employee.emp_id=branch.mgr_id;

-----------------------------------------------------------------------------------Nested Quesries --------------------------------------------------------------------------
-- find the name of all the employees 
-- who have soled over $30000 to a single client

select employee.first_name, employee.last_name from employee 
where employee.emp_id in (select works_with.emp_id
from works_with where works_with.total_sales>30000);

-- find all the clients who are handles by the branch 
-- that Michael Scott manages


select client.client_name, client.branch_id from client
where client.branch_id in (select branch.branch_id from branch 
where branch.mgr_id = 102);

----------------------------------------------------------------------------- Trigger-----------------------------------------------------------------------

-- CREATE
--     TRIGGER `event_name` BEFORE/AFTER INSERT/UPDATE/DELETE
--     ON `database`.`table`
--     FOR EACH ROW BEGIN
-- 		-- trigger body
-- 		-- this code is applied to every
-- 		-- inserted/updated/deleted row
--     END;

CREATE TABLE trigger_test (
     message VARCHAR(100)
);




CREATE
    TRIGGER my_trigger BEFORE INSERT
    ON employee
    FOR EACH ROW BEGIN
        INSERT INTO trigger_test VALUES('added new employee');
    END$$
DELIMITER ;
INSERT INTO employee
VALUES(109, 'Oscar', 'Martinez', '1968-02-19', 'M', 69000, 106, 3);


CREATE
    TRIGGER my_trigger BEFORE INSERT
    ON employee
    FOR EACH ROW BEGIN
        INSERT INTO trigger_test VALUES(NEW.first_name);
    END$$
DELIMITER ;
INSERT INTO employee
VALUES(110, 'Kevin', 'Malone', '1978-02-19', 'M', 69000, 106, 3);


CREATE
    TRIGGER my_trigger BEFORE INSERT
    ON employee
    FOR EACH ROW BEGIN
         IF NEW.sex = 'M' THEN
               INSERT INTO trigger_test VALUES('added male employee');
         ELSEIF NEW.sex = 'F' THEN
               INSERT INTO trigger_test VALUES('added female');
         ELSE
               INSERT INTO trigger_test VALUES('added other employee');
         END IF;
    END$$
DELIMITER ;
INSERT INTO employee
VALUES(111, 'Pam', 'Beesly', '1988-02-19', 'F', 69000, 106, 3);


DROP TRIGGER my_trigger;







