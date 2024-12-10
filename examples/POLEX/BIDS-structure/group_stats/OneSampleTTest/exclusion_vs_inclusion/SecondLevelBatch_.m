matlabbatch{1}.spm.stats.factorial_design.dir = {'F:\POLEX\derivatives\group_stats\standard\exclusion_vs_inclusion'};
%%
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {
                                                          'F:\POLEX\derivatives\stats\sub-POL1015\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1023\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1065\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1078\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1093\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1099\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1108\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1113\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1140\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1165\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1174\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1181\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1192\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1210\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1237\ratemeper\con_0002.nii'
                                                          'F:\POLEX\derivatives\stats\sub-POL1276\ratemeper\con_0002.nii'
                                                          };
%%
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {'W:\_SPM_\masks\brainmask_05.nii'};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat = {'F:\POLEX\derivatives\group_stats\standard\exclusion_vs_inclusion\SPM.mat'};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat = {'F:\POLEX\derivatives\group_stats\standard\exclusion_vs_inclusion\SPM.mat'};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'more';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'less';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = -1;
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
