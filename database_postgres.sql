-- Postgres Conversion of Hotel Management Database

-- Tables

CREATE TABLE "customer" (
  "customer_id" SERIAL PRIMARY KEY,
  "customer_firstname" varchar(50) NOT NULL,
  "customer_lastname" varchar(50) NOT NULL,
  "customer_TCno" varchar(11) NOT NULL,
  "customer_city" varchar(50) DEFAULT NULL,
  "customer_country" varchar(50) DEFAULT NULL,
  "customer_telephone" varchar(50) NOT NULL,
  "customer_email" varchar(50) NOT NULL
);

CREATE TABLE "department" (
  "department_id" SERIAL PRIMARY KEY,
  "department_name" varchar(50) NOT NULL,
  "department_budget" float DEFAULT NULL
);

CREATE TABLE "employee" (
  "employee_id" SERIAL PRIMARY KEY,
  "employee_username" varchar(50) NOT NULL UNIQUE,
  "employee_password" varchar(50) NOT NULL,
  "employee_firstname" varchar(50) NOT NULL,
  "employee_lastname" varchar(50) NOT NULL,
  "employee_telephone" varchar(50) DEFAULT NULL,
  "employee_email" varchar(50) DEFAULT NULL UNIQUE,
  "department_id" int DEFAULT NULL REFERENCES "department" ("department_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "employee_type" varchar(50) NOT NULL,
  "employee_salary" float DEFAULT NULL,
  "employee_hiring_date" varchar(50) DEFAULT NULL
);

CREATE TABLE "laundry" (
  "laundry_id" SERIAL PRIMARY KEY,
  "laundry_open_time" varchar(50) DEFAULT NULL,
  "laundry_close_time" varchar(50) DEFAULT NULL,
  "laundry_details" text
);

CREATE TABLE "laundry_service" (
  "customer_id" int NOT NULL REFERENCES "customer" ("customer_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "laundry_id" int NOT NULL REFERENCES "laundry" ("laundry_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "employee_id" int DEFAULT NULL REFERENCES "employee" ("employee_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "laundry_date" varchar(50) DEFAULT NULL,
  "laundry_amount" int DEFAULT NULL,
  "laundry_price" float DEFAULT NULL,
  PRIMARY KEY ("customer_id", "laundry_id")
);

CREATE TABLE "massage_room" (
  "massageroom_id" SERIAL PRIMARY KEY,
  "massageroom_open_time" varchar(10) DEFAULT NULL,
  "massageroom_close_time" varchar(10) DEFAULT NULL,
  "massageroom_details" text
);

CREATE TABLE "massage_service" (
  "customer_id" int NOT NULL REFERENCES "customer" ("customer_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "massageroom_id" int NOT NULL REFERENCES "massage_room" ("massageroom_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "employee_id" int DEFAULT NULL REFERENCES "employee" ("employee_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "massage_date" varchar(50) DEFAULT NULL,
  "massage_details" text,
  "massage_price" float DEFAULT NULL,
  PRIMARY KEY ("customer_id", "massageroom_id")
);

CREATE TABLE "medical_service" (
  "medicalservice_id" SERIAL PRIMARY KEY,
  "medicalservice_open_time" varchar(50) DEFAULT NULL,
  "medicalservice_close_time" varchar(50) DEFAULT NULL,
  "medicalservice_details" text
);

CREATE TABLE "room_type" (
  "room_type" varchar(50) PRIMARY KEY,
  "room_price" int DEFAULT NULL,
  "room_details" text,
  "room_quantity" int DEFAULT NULL
);

CREATE TABLE "room" (
  "room_id" SERIAL PRIMARY KEY,
  "room_type" varchar(50) DEFAULT NULL REFERENCES "room_type" ("room_type") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "reservation" (
  "customer_id" int NOT NULL REFERENCES "customer" ("customer_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "room_id" int NOT NULL REFERENCES "room" ("room_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "checkin_date" varchar(50) NOT NULL,
  "checkout_date" varchar(50) DEFAULT NULL,
  "employee_id" int DEFAULT NULL REFERENCES "employee" ("employee_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "reservation_date" varchar(50) DEFAULT NULL,
  "reservation_price" float DEFAULT NULL,
  "status" int DEFAULT NULL,
  PRIMARY KEY ("customer_id", "room_id", "checkin_date")
);

CREATE TABLE "restaurant" (
  "restaurant_name" varchar(50) PRIMARY KEY,
  "restaurant_open_time" varchar(10) DEFAULT NULL,
  "restaurant_close_time" varchar(10) DEFAULT NULL,
  "restaurant_details" text,
  "table_count" int DEFAULT NULL
);

CREATE TABLE "restaurant_booking" (
  "restaurant_name" varchar(50) NOT NULL REFERENCES "restaurant" ("restaurant_name") ON DELETE CASCADE ON UPDATE CASCADE,
  "customer_id" int NOT NULL REFERENCES "customer" ("customer_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "book_date" varchar(50) NOT NULL,
  "table_number" int DEFAULT NULL,
  "book_price" float DEFAULT NULL,
  PRIMARY KEY ("restaurant_name", "customer_id", "book_date")
);

CREATE TABLE "room_sales" (
  "customer_id" int NOT NULL REFERENCES "customer" ("customer_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "room_id" int NOT NULL REFERENCES "room" ("room_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "checkin_date" varchar(50) NOT NULL,
  "checkout_date" varchar(50) DEFAULT NULL,
  "employee_id" int DEFAULT NULL REFERENCES "employee" ("employee_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "room_sales_price" float DEFAULT NULL,
  "total_service_price" float DEFAULT NULL,
  PRIMARY KEY ("customer_id", "room_id", "checkin_date")
);

CREATE TABLE "room_service" (
  "roomservice_id" SERIAL PRIMARY KEY,
  "roomservice_open_time" varchar(50) DEFAULT NULL,
  "roomservice_close_time" varchar(50) DEFAULT NULL,
  "roomservice_floor" varchar(50) DEFAULT NULL,
  "roomservice_details" text
);

CREATE TABLE "do_sport" (
  "customer_id" int NOT NULL REFERENCES "customer" ("customer_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "sportfacility_id" int NOT NULL, -- will add FK after table creation
  "dosport_date" varchar(50) NOT NULL,
  "employee_id" int DEFAULT NULL REFERENCES "employee" ("employee_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "dosport_details" text,
  "dosport_price" float DEFAULT NULL,
  PRIMARY KEY ("customer_id", "sportfacility_id", "dosport_date")
);

CREATE TABLE "sport_facilities" (
  "sportfacility_id" SERIAL PRIMARY KEY,
  "sportfacility_open_time" varchar(50) DEFAULT NULL,
  "sportfacility_close_time" varchar(50) DEFAULT NULL,
  "sportfacility_details" text
);

ALTER TABLE "do_sport" ADD CONSTRAINT "do_sport_sportfacility_fk" FOREIGN KEY ("sportfacility_id") REFERENCES "sport_facilities" ("sportfacility_id") ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE "get_medicalservice" (
  "customer_id" int NOT NULL REFERENCES "customer" ("customer_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "medicalservice_id" int NOT NULL REFERENCES "medical_service" ("medicalservice_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "medicalservice_date" varchar(50) NOT NULL,
  "employee_id" int DEFAULT NULL REFERENCES "employee" ("employee_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "getmedicalservice_details" text,
  "medicalservice_price" float DEFAULT NULL,
  PRIMARY KEY ("customer_id", "medicalservice_id", "medicalservice_date")
);

CREATE TABLE "get_roomservice" (
  "customer_id" int NOT NULL REFERENCES "customer" ("customer_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "roomservice_id" int NOT NULL REFERENCES "room_service" ("roomservice_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "roomservice_date" varchar(50) NOT NULL,
  "employee_id" int DEFAULT NULL REFERENCES "employee" ("employee_id") ON DELETE CASCADE ON UPDATE CASCADE,
  "getroomservice_details" text,
  "roomservice_price" float DEFAULT NULL,
  PRIMARY KEY ("customer_id", "roomservice_id", "roomservice_date")
);
