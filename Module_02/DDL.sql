
-- ************************************** Calendar_dim
drop table Calendar_dim cascade

create table Calendar_dim
(
 date     date not null,
 year     int not null,
 quarter  varchar(9) not null,
 month    int not null,
 week     int not null,
 dow	  int not null,
 constraint PK_5 primary key (date)
);

truncate table Calendar_dim

with dates as (
select
	generate_series(to_date('01.01.2016', 'dd.mm.yyyy'),
            to_date('31.12.2020', 'dd.mm.yyyy'),
            '1 day') as date)

insert into Calendar_dim
select
	date,
	extract(year from date),
	extract(quarter from date),
	extract(month from date),
	extract(week from date),
	extract(day from date)
from
	dates

select * from Calendar_dim limit 100           
          

-- ************************************** Categories_dim
drop table Categories_dim cascade

create table Categories_dim
(
 category_id serial not null,
 name        varchar(150) not null,
 constraint PK_32 primary key ( category_id )
);

truncate table Categories_dim

insert into Categories_dim
select 	row_number() over (),
		cd.name
from 
	(select
		distinct category as name
	from
		orders_old) as cd
	
select * from Categories_dim  


-- ************************************** Subcategories_dim
drop table Subcategories_dim cascade

create table Subcategories_dim
(
 subcategory_id serial not null,
 category_id    serial not null,
 name           varchar(150) not null,
 constraint PK_27 primary key ( subcategory_id ),
 constraint FK_181 foreign key ( category_id ) references Categories_dim ( category_id )
);

create index FK_183 on Subcategories_dim
(
 category_id
);

truncate table Subcategories_dim

insert into Subcategories_dim
select 	row_number() over (),
		sd.category_id,
		sd.name
from 
	(select
		distinct oo.subcategory as name,
		cd.category_id
	from
		orders_old as oo
	left join
		Categories_dim as cd on oo.category = cd.name) as sd
	
select * from Subcategories_dim 


-- ************************************** Products_dim
drop table Products_dim cascade

create table Products_dim
(
 product_id     serial not null,
 subcategory_id serial not null,
 name           varchar(150) not null,
 id     		varchar(15) not null,
 constraint PK_17 primary key ( product_id ),
 constraint FK_184 foreign key ( subcategory_id ) references Subcategories_dim ( subcategory_id )
);

create index FK_186 on Products_dim
(
 subcategory_id
);

truncate table Products_dim

insert into Products_dim
select 	row_number() over (),
		pd.subcategory_id,
		pd.product_name,
		pd.product_id
from 
	(select
		distinct oo.product_id as product_id,
		oo.product_name,
		sd.subcategory_id
	from
		orders_old as oo
	left join
		Subcategories_dim as sd on oo.subcategory = sd.name) as pd
	
select * from Products_dim


-- ************************************** Countries_dim
drop table Countries_dim cascade

create table Countries_dim
(
 country_id   	serial not null,
 name 			varchar(100) not null,
 constraint PK_79 primary key ( country_id )
);

truncate table Countries_dim

insert into Countries_dim
select 	row_number() over (),
		cd.name
from 
	(select
		distinct country as name
	from
		orders_old) as cd
	
select * from Countries_dim


-- ************************************** Regions_dim
drop table Regions_dim cascade

create table Regions_dim
(
 region_id	serial not null,
 country_id serial not null,
 name       varchar(100) not null,
 constraint PK_84 primary key ( region_id ),
 constraint FK_134 foreign key ( country_id ) references Countries_dim ( country_id )
);

create index FK_136 on Regions_dim
(
 country_id
);

truncate table Regions_dim

insert into Regions_dim
select 	row_number() over (),
		rd.country_id,
		rd.name
from 
	(select
		distinct oo.region as name,
		cd.country_id
	from
		orders_old as oo
	left join
		Countries_dim as cd on oo.country = cd.name) as rd
	
select * from Regions_dim 


-- ************************************** States_dim
drop table States_dim cascade

create table States_dim
(
 state_id    serial not null,
 region_id serial not null,
 name  varchar(100) not null,
 constraint PK_74 primary key ( state_id ),
 constraint FK_130 foreign key ( region_id ) references Regions_dim ( region_id )
);

create index FK_132 on States_dim
(
 region_id
);

truncate table States_dim

insert into States_dim
select 	row_number() over (),
		sd.region_id,
		sd.name
from 
	(select
		distinct oo.state as name,
		rd.region_id
	from
		orders_old as oo
	left join
		Regions_dim as rd on oo.region = rd.name) as sd
	
select * from States_dim 


-- ************************************** Cities_dim
drop table Cities_dim cascade

create table Cities_dim
(
 city_id    serial not null,
 state_id 	serial not null,
 name       varchar(100) not null,
 constraint PK_68 primary key ( city_id ),
 constraint FK_127 foreign key ( state_id ) references States_dim ( state_id )
);

create index FK_129 on Cities_dim
(
 state_id
);

truncate table Cities_dim

insert into Cities_dim
select 	row_number() over (),
		cd.state_id,
		cd.name
from 
	(select
		distinct oo.city as name,
		sd.state_id
	from
		orders_old as oo
	left join
		States_dim as sd on oo.state = sd.name) as cd
	
select * from Cities_dim 


-- ************************************** Segments_dim
drop table Segments_dim cascade

create table Segments_dim
(
 segment_id serial not null,
 name       varchar(50) not null,
 constraint PK_190 primary key ( segment_id )
);

truncate table Segments_dim

insert into Segments_dim
select 	row_number() over (),
		sd.name
from 
	(select
		distinct oo.segment as name
	from
		orders_old as oo) as sd
	
select * from Segments_dim 


-- ************************************** Customer_dim
drop table Customers_dim cascade

create table Customers_dim
(
 customer_id varchar(8) not null,
 segment_id  serial not null,
 name        varchar(150) not null,
 constraint PK_56 primary key ( customer_id ),
 constraint FK_192 foreign key ( segment_id ) references Segments_dim ( segment_id )
);

create index FK_194 on Customers_dim
(
 segment_id
);

truncate table Customers_dim

insert into Customers_dim
select 	cd.customer_id,
		cd.segment_id,
		cd.name
from 
	(select
		distinct oo.customer_id,
		oo.customer_name as name,
		sd.segment_id
	from
		orders_old as oo
	left join
		Segments_dim as sd on oo.segment = sd.name) as cd
	
select * from Customers_dim 


-- ************************************** Orders
drop table Orders cascade

create table Orders
(
 Order_id   varchar(14) not null,
 order_date date not null,
 constraint PK_49 primary key ( Order_id ),
 constraint FK_157 foreign key ( order_date ) references Calendar_dim ( "date" )
);

create index FK_159 on Orders
(
 order_date
);

insert into Orders
select 	distinct Order_id,
		order_date
from 
		orders_old
	
select * from Orders 


-- ************************************** Persons_dim
drop table Persons_dim cascade

create table Persons_dim
(
 person_id serial not null,
 region_id serial not null,
 name      varchar(100) not null,
 constraint PK_168 primary key ( person_id ),
 constraint FK_170 foreign key ( region_id ) references Regions_dim ( region_id )
);

create index FK_172 on Persons_dim
(
 region_id
);

insert into Persons_dim
select 	row_number() over (),
		p.region_id,
		p.person
from 
	(select
		rd.region_id,
		po.person
	from
		people_old as po
	left join
		Regions_dim as rd on po.region = rd.name) as p
		
select * from Persons_dim 


-- ************************************** Ship_modes_dim
drop table Ship_modes_dim cascade

create table Ship_modes_dim
(
 ship_mode_id serial not null,
 name          varchar(100) not null,
 constraint PK_198 primary key ( ship_mode_id )
);

truncate table Ship_modes_dim

insert into Ship_modes_dim
select 	row_number() over (),
		smd.name
from 
	(select
		distinct ship_mode as name
	from
		orders_old) as smd
	
select * from Ship_modes_dim


-- ************************************** Sales
drop table Sales cascade

create table Sales
(
 sales_id      	serial not null,
 ship_mode_id	serial not null,
 ship_date     	date not null,
 product_id    	serial not null,
 customer_id 	varchar(8) not null,
 order_id    	varchar(14) not null,
 city_id     	serial not null,
 postal_code   	int,
 sales         	numeric not null,
 quantity      	numeric not null,
 discount      	numeric not null,
 profit        	numeric not null,
 constraint PK_44 primary key ( sales_id ),
 constraint FK_109 foreign key ( city_id ) references Cities_dim ( city_id ),
 constraint FK_138 foreign key ( order_id ) references Orders ( order_id ),
 constraint FK_141 foreign key ( customer_id ) references Customers_dim ( customer_id ),
 constraint FK_145 foreign key ( product_id ) references Products_dim ( product_id ),
 constraint FK_154 foreign key ( ship_date ) references Calendar_dim ( date ),
 constraint FK_200 foreign key ( ship_mode_id ) references Ship_modes_dim ( ship_mode_id )
);

create index FK_111 on Sales
(
 city_id
);

create index FK_140 on Sales
(
 Order_id
);

create index FK_143 on Sales
(
 customer_id
);

create index FK_147 on Sales
(
 product_id
);

create index FK_156 on Sales
(
 ship_date
);

create index FK_202 on Sales
(
 ship_mode_id
);

truncate table Sales

insert into Sales
select 	oo.row_id,
		smd.ship_mode_id,
		oo.ship_date,
		pd.product_id,
		cd.customer_id,
		oo.order_id,
		cid.city_id,
		oo.postal_code,
		oo.sales,
		oo.quantity,
		oo.discount,
		oo.profit
from orders_old as oo
	left join ship_modes_dim as smd on oo.ship_mode = smd.name
	left join products_dim as pd on oo.product_id = pd.id and oo.product_name = pd.name
	left join customers_dim as cd on oo.customer_id = cd.customer_id
	left join states_dim as sd on oo.state = sd.name	
	left join cities_dim as cid on oo.city = cid.name and sd.state_id = cid.state_id	
	
	
select count(*) from Sales 	
select * from Sales limit 10
