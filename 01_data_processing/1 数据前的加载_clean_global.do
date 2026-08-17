* ============================================================
* Pre setup
* ============================================================
clear all
set mem 700m
set mat 2000
set maxvar 10000
set level 95, perm
set more off

* ============================================================
* Global variable definition
* ============================================================

global dir "E:/桌面/儿童发烧-do文件"
**based on your own files organzition

global data "$dir/01_data"
global dofile "$dir/02_code"
global fig "$dir/03_figure"
global fig_data "$dir/04_parmest data"
global result "$dir/05_outreg_table"
global m_fig_data "$dir/06_figure data"