matlabbatch{1}.spm.stats.factorial_design.dir = {'F:\POLEX\derivatives\group_stats\fullFactorial'};
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'factor1';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = false;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'factor2';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = false;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans = {
                                                                   'F:\POLEX\derivatives\stats\sub-POL1015\ratemeper\con_0001.nii'
                                                                   'F:\POLEX\derivatives\stats\sub-POL1023\ratemeper\con_0001.nii'
                                                                   'F:\POLEX\derivatives\stats\sub-POL1065\ratemeper\con_0001.nii'
                                                                   'F:\POLEX\derivatives\stats\sub-POL1078\ratemeper\con_0001.nii'
                                                                   };
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans = {
                                                                   'F:\POLEX\derivatives\stats\sub-POL1093\ratemeper\con_0001.nii'
                                                                   'F:\POLEX\derivatives\stats\sub-POL1099\ratemeper\con_0001.nii'
                                                                   'F:\POLEX\derivatives\stats\sub-POL1108\ratemeper\con_0001.nii'
                                                                   'F:\POLEX\derivatives\stats\sub-POL1113\ratemeper\con_0001.nii'
                                                                   };
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [2
                                                                    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans = {
                                                                   'F:\POLEX\derivatives\stats\sub-POL1140\ratemeper\con_0001.nii'
                                                                   'F:\POLEX\derivatives\stats\sub-POL1165\ratemeper\con_0001.nii'
                                                                   'F:\POLEX\derivatives\stats\sub-POL1174\ratemeper\con_0001.nii'
                                                                   'F:\POLEX\derivatives\stats\sub-POL1181\ratemeper\con_0001.nii'
                                                                   };
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [2
                                                                    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = {
                                                                   'F:\POLEX\derivatives\stats\sub-POL1192\ratemeper\con_0001.nii'
                                                                   'F:\POLEX\derivatives\stats\sub-POL1210\ratemeper\con_0001.nii'
                                                                   'F:\POLEX\derivatives\stats\sub-POL1237\ratemeper\con_0001.nii'
                                                                   'F:\POLEX\derivatives\stats\sub-POL1276\ratemeper\con_0001.nii'
                                                                   };
matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {'W:\_SPM_\masks\brainmask_05.nii'};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat = {'F:\POLEX\derivatives\group_stats\fullFactorial\SPM.mat'};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat = {'F:\POLEX\derivatives\group_stats\fullFactorial\SPM.mat'};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'factor1var';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [-0.5 -0.5 0.5 0.5];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'factor2var';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [-0.5 0.5 -0.5 0.5];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
