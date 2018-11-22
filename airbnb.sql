CREATE OR REPLACE TRIGGER restraunt_full 
BEFORE INSERT ON booking_order FOR EACH ROW 
DECLARE
available_seat_count VARCAHR(30);
BEGIN
  IF(:new.property_type="restaurant") THEN
      select available_seats into available_seat_count from restaurant r 
        where :new.property_id = r.property_id and 
              :new.property_type = r.property_type; 
        IF (:new.booking_count - available_seat_count) = :new.booking_count THEN
            RAISE_APPLICATION_ERROR(20001,'No seats are available, recheck booking');
        ELSIF ((0 < (:new.booking_count - available_seat_count)) AND 
                ((:new.booking_count - available_seat_count) < :new.booking_count)) THEN
            RAISE_APPLICATION_ERROR(20002,'Only '||available_seat_count||'seats are available, recheck booking');
        END IF;
  END IF;
END;

CREATE OR REPLACE TRIGGER cust_payment_detail_check 
BEFORE INSERT ON booking_order FOR EACH ROW 
BEGIN
     select payment_details INTO payment from CUSTOMER c
     where c.user_id = :new.customer_user_id;
     IF payment is NULL THEN 
        RAISE_APPLICATION_ERROR(20003,'Add payment details for customer'|| :new.custoemr_user_id);
     END IF;
END;