# SPM_batch_creator
Generation of SPM12 batch jobs for statistical analyses (first &amp; second level) based on BIDS Stats Models Specification (BEP002)

## Description
This project intends to standardize the statistical analysis of fMRI datasets based on the tools available in SPM12. The json object, which contains all necessary inputs to create an executable SPM batch job, relies on the "BIDS Stats Models Specification" [1]. This specification represents an extension to the The Brain Imaging Data Structure (BIDS) [2], but is not yet finally integrated. To increase flexibility, the software SPM_batch_creator accepts both, datasets that are compliant with BIDS (restricted file naming and data structure) and datasets that do not meet those requirements but shall be standardized on the level of statistical analysis. All options offered in the SPM batch editor for first and second level statistical analysis are included within the scripts. The structure of the needed inputs in the json object follows closely to the SPM batch editor to facilitate usability also for less experienced users of SPM12. To run this software, pre-processed data are required.\
Alternatively, the software bidspm (https://github.com/cpp-lln-lab/bidspm) can be used, which offers all steps of data processing starting from raw data, but is strictly limited to BIDS-compliant datasets. Not all of the second level options that are available in SPM12 are supported at this time (04 Dec 2024) by bidspm.

## Installation
Requires MATLAB 2022a or higher to run. \
The code requires the MRI data analysis package spm (version 12, https://www.fil.ion.ucl.ac.uk/spm/). \
All scripts of this software have to be in the MATLAB path. \
The (optional) user interface uses inputsdlg.m [3]

## Usage
A detailed description on how to run the software is provided in the docs folder, which contains an elaborated manual and the sequence of the (optional) user interface.

## Support
Any problems, questions or suggestions can be addressed to daniel.huber@uibk.ac.at

## Authors and acknowledgments
Daniel Huber: conceptualization, methodology, coding, testing, documentation;\
Roberto Viviani: conceptualization, methodology, supervision, funding acquisition;\
This work was conducted within the framework of the “Austrian NeuroCloud”, supported by the Austrian Federal Ministry of Education, Science and Research.

We thank Remi Gau from the BIDS maintainers group for clarifying the targets and features of the BIDS stats model specification.

## License
This code is distributed under the CC BY-NC licence.

## DISCLAIMER
THIS SOFTWARE IS PROVIDED BY THE AUTHORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## References
1. A. de la Vega et al. BIDS Extension Proposal 2 (BEP002): The BIDS Stats Models Specification (version 1.0.0-rc1) (2022), https://docs.google.com/document/d/1bq5eNDHTb6Nkx3WUiOBgKvLNnaa5OMcGtD0AZ9yms2M/edit?tab=t.0#heading=h.mqkmyp254xh6
2. A. Oliver-Taylor et al., The Brain Imaging Data Structure (BIDS) Specification (v1.10.0) (2024), https://zenodo.org/records/13754678
3. Kesh Ikuma (2024). inputsdlg: Enhanced Input Dialog Box (https://www.mathworks.com/matlabcentral/fileexchange/25862-inputsdlg-enhanced-input-dialog-box), MATLAB Central File Exchange.
