-- Допустимая задержка актуализации
-- В предметной области оценки выставляются в основном в период сессии:
-- В период сессии: раз в день
-- В течении семестра раз в неделю

-- Политика обновления
-- В период сессии: обновлять представление каждый рабочий день после завершения ввода оценок
-- Вне сессии: обновлять раз в неделю и дополнительно перед формированием важных отчётов.
-- Во время рабочего дня использовать REFRESH MATERIALIZED VIEW CONCURRENTLY


REFRESH MATERIALIZED VIEW mv_offering_statistics;

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_offering_statistics;


SELECT offering_id, grades_count, grade_sum, avg_grade
FROM mv_offering_statistics
WHERE offering_id = 1;

BEGIN;

UPDATE grades
SET grade = 4
WHERE student_id = 7 AND offering_id = 1;

SELECT offering_id, grades_count, grade_sum, avg_grade
FROM mv_offering_statistics
WHERE offering_id = 1;

REFRESH MATERIALIZED VIEW mv_offering_statistics;

SELECT offering_id, grades_count, grade_sum, avg_grade
FROM mv_offering_statistics
WHERE offering_id = 1;

ROLLBACK;

SELECT offering_id, grades_count, grade_sum, avg_grade
FROM mv_offering_statistics
WHERE offering_id = 1;
