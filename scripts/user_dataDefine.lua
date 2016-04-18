
--사용자 타입 정의
__DIRECTOR__        = "1"   --원장


__TEACHER__         = "2"   --교사
__TEACHER_CLASS__   = "1"   --교사(반지정된)
__TEACHER_NOCLASS__ = "2"   --교사(반지정 안된)


__PARENT__          = "3"    --학부모
__PARENT_MOM__      = "1"    -- 엄마
__PARENT_DAD__      = "2"    -- 아빠
__PARENT_UNCLE__    = "3"    -- 삼촌
__PARENT_GMOM__     = "4"    -- 할배
__PARENT_GDAD__     = "5"    -- 할매
--사용자 타입 정의 끝



--권한 상수 정의
__MEAL_MENU_WRITE           = "mealMenuWrite"
__MEAL_MENU_DELETE__        = "mealMenuDelete"

__NOTICE_WRITE__            = "noticeWrite"
__NOTICE_DELETE__           = "noticeDelete"
__NOTICE_EDIT__             = "noticeEdit"
__VIEW_COMFIRMED_COUNT__    = "viewConfirmedCount"
__SELECT_CLASS__            = "selectClass"


--새소식 타입 시작 1:notice, 2:message, 3:event, 4:approve, 6:mamatalk, 7:mealmenu, 9:attendance
__NOTICE_THREAD_TYPE__      = "1"
__MESSAGE_THREAD_TYPE__     = "2"
__EVENT_THREAD_TYPE__       = "3"
__APPROVE_THERAD_TYPE__     = "4"
__MAMATALK_THREAD_TYPE__    = "6"
__MEALMENU_THREAD_TYPE__    = "7"
__KIDS_ATTENDANCE_TYPE__    = "9"

__COMMENT_SUB_TYPE__        = "2"
--새소식 타입 끝

__AVAILABLE_STATUS__ = "0" --이용가능한 상태

__ATTENDANCE_TYPE__ = "1" --출석 타입

__BOY_TYPE__ = "1" --남자
__GIRL_TYPE__ = "2" --여자

__TOUR_ACCOUNTS__ = {
    {
        languageName = "ja", --일본어
        director_account = {"encho14@kidsup.net", "kidsup4321" },
        teacher_account = {"teacher8@kidsup.net", "kidsup4321" },
        parent_account = {"mother1238@kidsup.net", "kidsup4321" },
    },
    {
        languageName = "ko", --한국어
--        director_account = {"encho16@kidsup.net", "kidsup4321" },
--        teacher_account = {"teacher3@kidsup.net", "kidsup4321" },
--        parent_account = {"mother1262@kidsup.net", "kidsup4321" },
        director_account = {"encho14@kidsup.net", "kidsup4321" }, --일본어로 통일 2015.04.03
        teacher_account = {"teacher8@kidsup.net", "kidsup4321" },
        parent_account = {"mother1238@kidsup.net", "kidsup4321" },
    },
    {
        languageName = "en", --영어
--        director_account = {"encho15@kidsup.net", "kidsup4321" },
--        teacher_account = {"teacher1@kidsup.net", "kidsup4321" },
--        parent_account = {"mother1235@kidsup.net", "kidsup4321" },
        director_account = {"encho14@kidsup.net", "kidsup4321" },--일본어로 통일 2015.04.03
        teacher_account = {"teacher8@kidsup.net", "kidsup4321" },
        parent_account = {"mother1238@kidsup.net", "kidsup4321" },
    },
}