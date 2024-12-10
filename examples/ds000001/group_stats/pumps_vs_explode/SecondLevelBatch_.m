matlabbatch{1}.spm.stats.factorial_design.dir = {'F:\testset_ds000001\derivatives\stats2\group_stats\default0\pumps_vs_explode'};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {
                                                          'F:\testset_ds000001\derivatives\stats2\sub-02\balloonanalogrisktask\con_0003.nii'
                                                          'F:\testset_ds000001\derivatives\stats2\sub-03\balloonanalogrisktask\con_0003.nii'
                                                          'F:\testset_ds000001\derivatives\stats2\sub-04\balloonanalogrisktask\con_0001.nii'
                                                          'F:\testset_ds000001\derivatives\stats2\sub-06\balloonanalogrisktask\con_0003.nii'
                                                          'F:\testset_ds000001\derivatives\stats2\sub-07\balloonanalogrisktask\con_0003.nii'
                                                          'F:\testset_ds000001\derivatives\stats2\sub-08\balloonanalogrisktask\con_0003.nii'
                                                          };
matlabbatch{1}.spm.stats.factorial_design.cov(1).c = [24
                                                      27
                                                      20
                                                      26
                                                      24
                                                      21];
matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'age';
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).c = [2
                                                      1
                                                      1
                                                      1
                                                      2
                                                      2];
matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'sex';
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {'W:\_SPM_\masks\brainmask_05.nii'};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat = {'F:\testset_ds000001\derivatives\stats2\group_stats\default0\pumps_vs_explode\SPM.mat'};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat = {'F:\testset_ds000001\derivatives\stats2\group_stats\default0\pumps_vs_explode\SPM.mat'};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'more';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [1 0 0];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'less';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [-1 0 0];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'age_more';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec = [0 1 0];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'age_less';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.convec = [0 -1 0];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'sex_1';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.convec = [0 0 1];
matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'sex_2';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.convec = [0 0 -1];
matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
