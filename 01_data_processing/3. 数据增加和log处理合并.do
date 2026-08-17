do "G:/3 city and conflict/3 experiment/1 stata_code/4. 儿童发烧/预处理/1 数据前的加载_clean_global.do"
* ============================================================
* 总控 do 文件：依次运行补充数据处理与 log 变量构造
* 带日志版本
* ============================================================

clear all
set more off
set linesize 255

* ------------------------------------------------------------
* 1. 设置目录
* ------------------------------------------------------------

global supp_code "G:\3 city and conflict\3 experiment\1 stata_code\4. 儿童发烧\补充数据"
global prep_code "G:\3 city and conflict\3 experiment\1 stata_code\4. 儿童发烧\预处理"

global log_dir "G:\3 city and conflict\3 experiment\1 stata_code\4. 儿童发烧\运行日志"

cap mkdir "$log_dir"


* ------------------------------------------------------------
* 2. 依次运行 do 文件
* ------------------------------------------------------------

do "$supp_code\补充数据1-洪水数据重新处理.do"
do "$supp_code\补充数据2-DHS附近30公里hospital.do"
do "$supp_code\补充数据3-道路是否中断数据.do"
do "$supp_code\补充数据4-uban_centre.do"
do "$supp_code\补充数据5-hours_boundary_dis.do"
do "$supp_code\补充数据6-hospital_vars.do"
do "$supp_code\补充数据7-地形起伏urban.do"
do "$supp_code\补充数据8-重新计算catchment以及医院数量计算.do"
do "$supp_code\补充数据9-CRU重新处理.do"

display as text "============================================================"
display as text "开始运行：2. log_变量构造.do"
display as text "============================================================"

do "$prep_code\2. log_变量构造.do"



