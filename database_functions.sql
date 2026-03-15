-- Postgres Conversion of Stored Procedures and Triggers

-- Functions (Stored Procedures replacements)

CREATE OR REPLACE FUNCTION todays_service_count(today_date varchar(50))
RETURNS TABLE (amount bigint, type text) AS $$
BEGIN
    RETURN QUERY
    SELECT count(*)::bigint as amount, 'laundry'::text as type FROM laundry_service WHERE laundry_date = today_date
    UNION ALL
    SELECT count(*)::bigint as amount, 'massage'::text as type FROM massage_service WHERE massage_date = today_date
    UNION ALL
    SELECT count(*)::bigint as amount, 'roomservice'::text as type FROM get_roomservice WHERE roomservice_date = today_date
    UNION ALL
    SELECT count(*)::bigint as amount, 'medicalservice'::text as type FROM get_medicalservice WHERE medicalservice_date = today_date
    UNION ALL
    SELECT count(*)::bigint as amount, 'sport'::text as type FROM do_sport WHERE dosport_date = today_date
    UNION ALL
    SELECT count(*)::bigint as amount, 'restaurant'::text as type FROM restaurant_booking WHERE book_date = today_date;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_available_rooms(o_room_type varchar(50), o_checkin_date varchar(50), o_checkout_date varchar(50))
RETURNS SETOF room AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM "room" WHERE room_type = o_room_type AND NOT EXISTS (
        SELECT 1 FROM reservation WHERE reservation.room_id = room.room_id AND checkout_date >= o_checkin_date AND checkin_date <= o_checkout_date
        UNION ALL
        SELECT 1 FROM room_sales WHERE room_sales.room_id = room.room_id AND checkout_date >= o_checkin_date AND checkin_date <= o_checkout_date
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_customers(today_date varchar(50))
RETURNS TABLE (
    customer_id int,
    room_id int,
    checkin_date varchar(50),
    checkout_date varchar(50),
    employee_id int,
    room_sales_price float,
    total_service_price float,
    customer_firstname varchar(50),
    customer_lastname varchar(50),
    customer_TCno varchar(11),
    customer_city varchar(50),
    customer_country varchar(50),
    customer_telephone varchar(50),
    customer_email varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rs.customer_id, rs.room_id, rs.checkin_date, rs.checkout_date, rs.employee_id, rs.room_sales_price, rs.total_service_price,
        c.customer_firstname, c.customer_lastname, c.customer_TCno, c.customer_city, c.customer_country, c.customer_telephone, c.customer_email
    FROM room_sales rs
    JOIN customer c ON rs.customer_id = c.customer_id
    WHERE rs.checkout_date >= today_date AND rs.checkin_date <= today_date;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_all_customers(id int)
RETURNS bigint AS $$
DECLARE
    row_count bigint;
BEGIN
    SELECT count(*) INTO row_count FROM customer;
    RETURN row_count;
END;
$$ LANGUAGE plpgsql;

-- Trigger Functions

CREATE OR REPLACE FUNCTION update_total_service_price() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE room_sales 
        SET total_service_price = COALESCE(total_service_price, 0) + 
            CASE 
                WHEN TG_TABLE_NAME = 'do_sport' THEN NEW.dosport_price
                WHEN TG_TABLE_NAME = 'get_medicalservice' THEN NEW.medicalservice_price
                WHEN TG_TABLE_NAME = 'get_roomservice' THEN NEW.roomservice_price
                WHEN TG_TABLE_NAME = 'laundry_service' THEN NEW.laundry_price
                WHEN TG_TABLE_NAME = 'restaurant_booking' THEN NEW.book_price
                WHEN TG_TABLE_NAME = 'massage_service' THEN NEW.massage_price
                ELSE 0
            END
        WHERE customer_id = NEW.customer_id 
          AND checkin_date <= 
            CASE 
                WHEN TG_TABLE_NAME = 'do_sport' THEN NEW.dosport_date
                WHEN TG_TABLE_NAME = 'get_medicalservice' THEN NEW.medicalservice_date
                WHEN TG_TABLE_NAME = 'get_roomservice' THEN NEW.roomservice_date
                WHEN TG_TABLE_NAME = 'laundry_service' THEN NEW.laundry_date
                WHEN TG_TABLE_NAME = 'restaurant_booking' THEN NEW.book_date
                WHEN TG_TABLE_NAME = 'massage_service' THEN NEW.massage_date
                ELSE NULL
            END
          AND checkout_date >= 
            CASE 
                WHEN TG_TABLE_NAME = 'do_sport' THEN NEW.dosport_date
                WHEN TG_TABLE_NAME = 'get_medicalservice' THEN NEW.medicalservice_date
                WHEN TG_TABLE_NAME = 'get_roomservice' THEN NEW.roomservice_date
                WHEN TG_TABLE_NAME = 'laundry_service' THEN NEW.laundry_date
                WHEN TG_TABLE_NAME = 'restaurant_booking' THEN NEW.book_date
                WHEN TG_TABLE_NAME = 'massage_service' THEN NEW.massage_date
                ELSE NULL
            END;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE room_sales 
        SET total_service_price = COALESCE(total_service_price, 0) - 
            CASE 
                WHEN TG_TABLE_NAME = 'do_sport' THEN OLD.dosport_price
                WHEN TG_TABLE_NAME = 'get_medicalservice' THEN OLD.medicalservice_price
                WHEN TG_TABLE_NAME = 'get_roomservice' THEN OLD.roomservice_price
                WHEN TG_TABLE_NAME = 'laundry_service' THEN OLD.laundry_price
                WHEN TG_TABLE_NAME = 'restaurant_booking' THEN OLD.book_price
                WHEN TG_TABLE_NAME = 'massage_service' THEN OLD.massage_price
                ELSE 0
            END
        WHERE customer_id = OLD.customer_id 
          AND checkin_date <= 
            CASE 
                WHEN TG_TABLE_NAME = 'do_sport' THEN OLD.dosport_date
                WHEN TG_TABLE_NAME = 'get_medicalservice' THEN OLD.medicalservice_date
                WHEN TG_TABLE_NAME = 'get_roomservice' THEN OLD.roomservice_date
                WHEN TG_TABLE_NAME = 'laundry_service' THEN OLD.laundry_date
                WHEN TG_TABLE_NAME = 'restaurant_booking' THEN OLD.book_date
                WHEN TG_TABLE_NAME = 'massage_service' THEN OLD.massage_date
                ELSE NULL
            END
          AND checkout_date >= 
            CASE 
                WHEN TG_TABLE_NAME = 'do_sport' THEN OLD.dosport_date
                WHEN TG_TABLE_NAME = 'get_medicalservice' THEN OLD.medicalservice_date
                WHEN TG_TABLE_NAME = 'get_roomservice' THEN OLD.roomservice_date
                WHEN TG_TABLE_NAME = 'laundry_service' THEN OLD.laundry_date
                WHEN TG_TABLE_NAME = 'restaurant_booking' THEN OLD.book_date
                WHEN TG_TABLE_NAME = 'massage_service' THEN OLD.massage_date
                ELSE NULL
            END;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_room_quantity() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE room_type SET room_quantity = COALESCE(room_quantity, 0) + 1 WHERE room_type = NEW.room_type;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE room_type SET room_quantity = COALESCE(room_quantity, 0) - 1 WHERE room_type = OLD.room_type;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Triggers Enrollment

CREATE TRIGGER trg_sport_service AFTER INSERT OR DELETE ON do_sport FOR EACH ROW EXECUTE FUNCTION update_total_service_price();
CREATE TRIGGER trg_medical_service AFTER INSERT OR DELETE ON get_medicalservice FOR EACH ROW EXECUTE FUNCTION update_total_service_price();
CREATE TRIGGER trg_room_service AFTER INSERT OR DELETE ON get_roomservice FOR EACH ROW EXECUTE FUNCTION update_total_service_price();
CREATE TRIGGER trg_laundry_service AFTER INSERT OR DELETE ON laundry_service FOR EACH ROW EXECUTE FUNCTION update_total_service_price();
CREATE TRIGGER trg_restaurant_service AFTER INSERT OR DELETE ON restaurant_booking FOR EACH ROW EXECUTE FUNCTION update_total_service_price();
CREATE TRIGGER trg_massage_service AFTER INSERT OR DELETE ON massage_service FOR EACH ROW EXECUTE FUNCTION update_total_service_price();

CREATE TRIGGER trg_room_qty AFTER INSERT OR DELETE ON room FOR EACH ROW EXECUTE FUNCTION update_room_quantity();
