#!/bin/bash

mkdir transducers

################# Arabics2Romans Transducer ################
###### Uni
fstcompile --isymbols=syms.sym --osymbols=syms.sym r2a_uni.txt | fstarcsort > transducers/r2a_uni.fst
#fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait transducers/r2a_uni.fst | dot -Tpdf  > transducers/r2a_uni.pdf

###### Dec
fstcompile --isymbols=syms.sym --osymbols=syms.sym r2a_dec.txt | fstarcsort > transducers/r2a_dec.fst
#fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait transducers/r2a_dec.fst | dot -Tpdf  > transducers/r2a_dec.pdf

###### Cent
fstcompile --isymbols=syms.sym --osymbols=syms.sym r2a_cen.txt | fstarcsort > transducers/r2a_cen.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait transducers/r2a_cen.fst | dot -Tpdf  > transducers/r2a_cen.pdf

###### Zero
fstcompile --isymbols=syms.sym --osymbols=syms.sym r2a_zero.txt | fstarcsort > transducers/r2a_zero.fst
#fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait transducers/r2a_zero.fst | dot -Tpdf  > transducers/r2a_zero.pdf

### Concatenation e Union operation for final transducer generation
fstunion transducers/r2a_uni.fst transducers/r2a_zero.fst > transducers/r2a_uni_zero.fst
fstconcat transducers/r2a_dec.fst transducers/r2a_uni_zero.fst > transducers/r2a_dec_zero_uni.fst

fstconcat transducers/r2a_cen.fst transducers/r2a_zero.fst > transducers/r2a_cen_zero.fst
fstconcat transducers/r2a_cen_zero.fst transducers/r2a_zero.fst  > transducers/r2a_hundred.fst

fstunion transducers/r2a_hundred.fst transducers/r2a_dec_zero_uni.fst > transducers/r2a_almost_final.fst
fstunion transducers/r2a_almost_final.fst transducers/r2a_uni.fst > transducers/r2a.fst
#fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait transducers/r2a.fst | dot -Tpdf  > transducers/r2a.pdf

### Inverting Romans2Arabics --> Arabics2Romans
fstinvert transducers/r2a.fst > transducers/a2r.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait transducers/a2r.fst | dot -Tpdf  > transducers/a2r.pdf

#############################################################

######################### Transducer 1 ######################
python compact2fst.py letters.txt > transducers/letters_transducer.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym transducers/letters_transducer.txt | fstarcsort > transducers/letters_transducer.fst
fstcompile --isymbols=syms.sym --osymbols=syms.sym underline.txt | fstarcsort > transducers/underline.fst

###Transducers operations
fstunion transducers/a2r.fst transducers/letters_transducer.fst > transducers/transducer1_union.fst
fstconcat transducers/transducer1_union.fst transducers/underline.fst > transducers/transducer1_almost_final.fst
fstclosure transducers/transducer1_almost_final.fst > transducers/transducer1.fst

###Printing Transducer 1
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait transducers/transducer1.fst | dot -Tpdf  > transducers/transducer1.pdf

######################### Transducer 2 ######################
python compact2fst.py transducer2.txt > transducers/transducer2_final.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym transducers/transducer2_final.txt | fstarcsort > transducers/transducer2_final.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait transducers/transducer2_final.fst | dot -Tpdf  > transducers/transducer2_final.pdf

######################### Transducer 3 #######################
python compact2fst.py transducer3.txt > transducers/transducer3_final.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym transducers/transducer3_final.txt | fstarcsort > transducers/transducer3_final.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait transducers/transducer3_final.fst | dot -Tpdf  > transducers/transducer3_final.pdf

##################### Codifier Transducer ####################
fstarcsort --sort_type=ilabel transducers/transducer1.fst > transducers/transducer1_sort.fst
fstcompose transducers/transducer1_sort.fst transducers/transducer2_final.fst > transducers/transducer1_2.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait transducers/transducer1_2.fst | dot -Tpdf  > transducers/transducer1_2.pdf

fstcompose transducers/transducer1_2.fst transducers/transducer3_final.fst | fstarcsort > transducers/tranducer_cod.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait transducers/tranducer_cod.fst | dot -Tpdf  > transducers/tranducer_cod.pdf

################### Decodifier Transducer ####################
fstinvert transducers/transducer1_sort.fst > transducers/transducer1_invert.fst
fstinvert transducers/transducer2_final.fst > transducers/transducer2_invert.fst
fstinvert transducers/transducer3_final.fst > transducers/transducer3_invert.fst

fstcompose transducers/transducer3_invert.fst transducers/transducer2_invert.fst > transducers/transducer3_2_invert.fst
fstcompose transducers/transducer3_2_invert.fst transducers/transducer1_invert.fst | fstarcsort > transducers/tranducer_decod.fst

fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait transducers/tranducer_decod.fst | dot -Tpdf  > transducers/tranducer_decod.pdf

##############################################################
##############################################################
#                ___________              __                 #
#                \__    ___/___   _______/  |_               #
#                  |    |_/ __ \ /  ___/\   __\              #
#                  |    |\  ___/ \___ \  |  |                #
#                  |____| \___  >____  > |__|                #
##############################################################
##############################################################

mkdir tests
mkdir results

####################### Tests Generation #####################
python word2fst.py 99_ > tests/test_99_.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym  tests/test_99_.txt | fstarcsort > tests/test_99_.fst

python word2fst.py 99_aa_ > tests/test_99_aa_.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym  tests/test_99_aa_.txt | fstarcsort > tests/test_99_aa_.fst

python word2fst.py batata_28_ > tests/test_batata_28_.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym  tests/test_batata_28_.txt | fstarcsort > tests/test_batata_28_.fst

python word2fst.py ir_tambem_ > tests/test_ir_tambem_.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym  tests/test_ir_tambem_.txt | fstarcsort > tests/test_ir_tambem_.fst

python word2fst.py 3513_ > tests/test_3513_.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym  tests/test_3513_.txt | fstarcsort > tests/test_3513_.fst

python word2fst.py 3513_XX_ > tests/test_3513_XX_.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym  tests/test_3513_XX_.txt | fstarcsort > tests/test_3513_XX_.fst

python word2fst.py bXtXtX_332111_ > tests/test_bXtXtX_332111_.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym  tests/test_bXtXtX_332111_.txt | fstarcsort > tests/test_bXtXtX_332111_.fst

python word2fst.py Vr_tX79m_ > tests/test_Vr_tX79m_.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym  tests/test_Vr_tX79m_.txt | fstarcsort > tests/test_Vr_tX79m_.fst

python word2fst.py iiimmmbii_iirirriiri_ > tests/test_iiimmmbii_iirirriiri_.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym  tests/test_iiimmmbii_iirirriiri_.txt | fstarcsort > tests/test_iiimmmbii_iirirriiri_.fst

python word2fst.py biblioteca_do_palacio_de_monserrate_na_estante_a_esquerda_no_dia_14_de_novembro_pelas_10_23_de_maio_ > tests/test_cod_email.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym  tests/test_cod_email.txt | fstarcsort > tests/test_cod_email.fst

python word2fst.py Xs_21_pm_32111_d9_d9z97r0_3332111_3412_312_n_13_32111_31_0_ > tests/test_decod1_email.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym  tests/test_decod1_email.txt | fstarcsort > tests/test_decod1_email.fst

python word2fst.py 3332111_3412_321_n_13_2111_321_0_3311_d9_jXn9Vr0_p9lXs_312_h_ > tests/test_decod2_email.txt
fstcompile --isymbols=syms.sym --osymbols=syms.sym  tests/test_decod2_email.txt | fstarcsort > tests/test_decod2_email.fst


#################### Testing Transducer 1 ####################
fstcompose tests/test_99_.fst transducers/transducer1.fst | fstrmepsilon > results/result_t1_XCIX_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_t1_XCIX_.fst | dot -Tpdf  > results/result_t1_XCIX_.pdf

fstcompose tests/test_99_aa_.fst transducers/transducer1.fst | fstrmepsilon > results/result_t1_XCIX_aa_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_t1_XCIX_aa_.fst | dot -Tpdf  > results/result_t1_XCIX_aa_.pdf

fstcompose tests/test_batata_28_.fst transducers/transducer1.fst | fstrmepsilon > results/result_t1_batata_XXVIII_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_t1_batata_XXVIII_.fst | dot -Tpdf  > results/result_t1_batata_XXVIII_.pdf

fstcompose tests/test_ir_tambem_.fst transducers/transducer1.fst | fstrmepsilon > results/result_t1_ir_tambem_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_t1_ir_tambem_.fst | dot -Tpdf  > results/result_t1_ir_tambem_.pdf


#################### Testing Transducer 2 ####################
fstcompose results/result_t1_XCIX_aa_.fst transducers/transducer2_final.fst | fstrmepsilon > results/result_t2_3513_aa_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_t2_3513_aa_.fst | dot -Tpdf  > results/result_t2_3513_aa_.pdf

fstcompose results/result_t1_XCIX_.fst transducers/transducer2_final.fst | fstrmepsilon > results/result_t2_3513_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_t2_3513_.fst | dot -Tpdf  > results/result_t2_3513_.pdf

fstcompose results/result_t1_batata_XXVIII_.fst transducers/transducer2_final.fst | fstrmepsilon > results/result_t2_batata_332111_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_t2_batata_332111_.fst | dot -Tpdf  > results/result_t2_batata_332111_.pdf

fstcompose results/result_t1_ir_tambem_.fst transducers/transducer2_final.fst | fstrmepsilon > results/result_t2_ir_tambem_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_t2_ir_tambem_.fst | dot -Tpdf  > results/result_t2_ir_tambem_.pdf


#################### Testing Transducer 3 ####################
fstcompose results/result_t2_3513_aa_.fst transducers/transducer3_final.fst | fstrmepsilon > results/result_t3_3513_XX_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_t3_3513_XX_.fst | dot -Tpdf  > results/result_t3_3513_XX_.pdf

fstcompose results/result_t2_3513_.fst transducers/transducer3_final.fst | fstrmepsilon > results/result_t3_3513_1.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_t3_3513_1.fst | dot -Tpdf  > results/result_t3_3513_1.pdf

fstcompose results/result_t2_batata_332111_.fst transducers/transducer3_final.fst | fstrmepsilon > results/result_t3_bXtXtX_332111_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_t3_bXtXtX_332111_.fst | dot -Tpdf  > results/result_t3_bXtXtX_332111_.pdf

fstcompose results/result_t2_ir_tambem_.fst transducers/transducer3_final.fst | fstrmepsilon > results/result_t3_Vr_tX79m_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_t3_Vr_tX79m_.fst | dot -Tpdf  > results/result_t3_Vr_tX79m_.pdf

fstcompose tests/test_iiimmmbii_iirirriiri_.fst transducers/transducer3_final.fst | fstrmepsilon > results/result_t3_LLLmm7LL_LVrVrrLVrL_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_t3_LLLmm7LL_LVrVrrLVrL_.fst | dot -Tpdf  > results/result_t3_LLLmm7LL_LVrVrrLVrL_.pdf

################# Testing Codifier Transducer ################
fstcompose tests/test_99_aa_.fst transducers/tranducer_cod.fst | fstrmepsilon > results/result_cod_3513_XX_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_cod_3513_XX_.fst | dot -Tpdf  > results/result_cod_3513_XX_.pdf

fstcompose tests/test_99_.fst transducers/tranducer_cod.fst | fstrmepsilon > results/result_cod_3513_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_cod_3513_.fst | dot -Tpdf  > results/result_cod_3513_.pdf

fstcompose tests/test_batata_28_.fst transducers/tranducer_cod.fst | fstrmepsilon > results/result_cod_bXtXtX_332111_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_cod_bXtXtX_332111_.fst | dot -Tpdf  > results/result_cod_bXtXtX_332111_.pdf

fstcompose tests/test_ir_tambem_.fst transducers/tranducer_cod.fst | fstrmepsilon > results/result_cod_Vr_tX79m_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_cod_Vr_tX79m_.fst | dot -Tpdf  > results/result_cod_Vr_tX79m_.pdf

fstcompose tests/test_cod_email.fst transducers/tranducer_cod.fst | fstproject --project_output | fstrmepsilon > results/result_cod_email.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_cod_email.fst | dot -Tpdf  > results/result_cod_email.pdf

################ Testing Decodifier Transducer ###############
fstcompose tests/test_3513_.fst transducers/tranducer_decod.fst | fstrmepsilon > results/result_decod_3513_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_decod_3513_.fst | dot -Tpdf  > results/result_decod_3513_.pdf

fstcompose tests/test_3513_XX_.fst transducers/tranducer_decod.fst | fstrmepsilon > results/result_decod_3513_XX_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_decod_3513_XX_.fst | dot -Tpdf  > results/result_decod_3513_XX_.pdf

fstcompose tests/test_bXtXtX_332111_.fst transducers/tranducer_decod.fst | fstrmepsilon > results/result_decod_batata_28_.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_decod_batata_28_.fst | dot -Tpdf  > results/result_decod_batata_28_.pdf

fstcompose tests/test_Vr_tX79m_.fst transducers/tranducer_decod.fst | fstrmepsilon > results/result_decod_ir_tambem.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_decod_ir_tambem.fst | dot -Tpdf  > results/result_decod_ir_tambem.pdf

fstcompose tests/test_decod1_email.fst transducers/tranducer_decod.fst | fstproject --project_output | fstrmepsilon > results/result_decod1_email.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_decod1_email.fst | dot -Tpdf  > results/result_decod1_email.pdf

fstcompose tests/test_decod2_email.fst transducers/tranducer_decod.fst | fstproject --project_output | fstrmepsilon > results/result_decod2_email.fst
fstdraw    --isymbols=syms.sym --osymbols=syms.sym --portrait results/result_decod2_email.fst | dot -Tpdf  > results/result_decod2_email.pdf

##############################################################
