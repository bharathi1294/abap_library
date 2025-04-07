"Here are some useful standard CDS system entities for 𝗴𝗲𝗻𝗲𝗿𝗮𝘁𝗶𝗻𝗴 𝘀𝗲𝗿𝗶𝗲𝘀, which can be quite handy in various scenarios:

"1.SERIES_GENERATE_DATE -> Generate Dates
SELECT * FROM series_generate_date( step       = 1,
                                    from_value = '20250101',
                                    to_value   = '20250130' )
  ORDER BY element_number
  INTO TABLE @DATA(date_series_gen).

"2.SERIES_GENERATE_INTEGER - Generate Integer
SELECT * FROM series_generate_integer( step       = 1,
                                       from_value = 1,
                                       to_value   = 100 )
  ORDER BY element_number
  INTO TABLE @DATA(integer_series_gen).

"3. SERIES_GENERATE_TIME - Generate Time
DATA(time) = cl_demo_date_time=>get_user_time( ).
DATA(seconds_added) = time + 20.

SELECT * FROM series_generate_time( step       = 2,
                                    from_value = @time,
                                    to_value   = @seconds_added )
  ORDER BY element_number
  INTO TABLE @DATA(time_series_gen).

"4.SERIES_GENERATE_TIMESTAMP - Generate Timestamp
DATA(ts_from) = utclong_current( ).
DATA(ts_to) = utclong_add( val  = ts_from seconds = 10 ).

SELECT * FROM series_generate_timestamp( step       = 2,
                                         from_value = @ts_from,
                                         to_value   = @ts_to )
  ORDER BY element_number
  INTO TABLE @DATA(timestamp_series_gen).

