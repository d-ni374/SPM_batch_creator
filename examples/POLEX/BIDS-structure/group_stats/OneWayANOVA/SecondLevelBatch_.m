matlabbatch{1}.spm.stats.factorial_design.dir = {'F:\POLEX\derivatives\group_stats\ANOVA'};
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(1).scans = {
                                                                      'F:\POLEX\derivatives\stats\sub-POL1015\ratemeper\con_0001.nii'
                                                                      'F:\POLEX\derivatives\stats\sub-POL1023\ratemeper\con_0001.nii'
                                                                      'F:\POLEX\derivatives\stats\sub-POL1065\ratemeper\con_0001.nii'
                                                                      'F:\POLEX\derivatives\stats\sub-POL1078\ratemeper\con_0001.nii'
                                                                      };
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(2).scans = {
                                                                      'F:\POLEX\derivatives\stats\sub-POL1093\ratemeper\con_0001.nii'
                                                                      'F:\POLEX\derivatives\stats\sub-POL1099\ratemeper\con_0001.nii'
                                                                      'F:\POLEX\derivatives\stats\sub-POL1108\ratemeper\con_0001.nii'
                                                                      'F:\POLEX\derivatives\stats\sub-POL1113\ratemeper\con_0001.nii'
                                                                      };
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(3).scans = {
                                                                      'F:\POLEX\derivatives\stats\sub-POL1140\ratemeper\con_0001.nii'
                                                                      'F:\POLEX\derivatives\stats\sub-POL1165\ratemeper\con_0001.nii'
                                                                      'F:\POLEX\derivatives\stats\sub-POL1174\ratemeper\con_0001.nii'
                                                                      'F:\POLEX\derivatives\stats\sub-POL1181\ratemeper\con_0001.nii'
                                                                      };
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(4).scans = {
                                                                      'F:\POLEX\derivatives\stats\sub-POL1192\ratemeper\con_0001.nii'
                                                                      'F:\POLEX\derivatives\stats\sub-POL1210\ratemeper\con_0001.nii'
                                                                      'F:\POLEX\derivatives\stats\sub-POL1237\ratemeper\con_0001.nii'
                                                                      'F:\POLEX\derivatives\stats\sub-POL1276\ratemeper\con_0001.nii'
                                                                      };
matlabbatch{1}.spm.stats.factorial_design.des.anova.dept = false;
matlabbatch{1}.spm.stats.factorial_design.des.anova.variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {'W:\_SPM_\masks\brainmask_05.nii'};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat = {'F:\POLEX\derivatives\group_stats\ANOVA\SPM.mat'};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat = {'F:\POLEX\derivatives\group_stats\ANOVA\SPM.mat'};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'group1 vs group2';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [1 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'group3 vs group4';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [0 0 1 -1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Groups_{1}';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec = [1 0 0 0];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Groups_{2}';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.convec = [0 1 0 0];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Groups_{3}';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.convec = [0 0 1 0];
matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Groups_{4}';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.convec = [0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
