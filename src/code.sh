#!/bin/bash

# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
set -e -x -o pipefail

function wcx_command {
	# Call Wisecondor X to predict CNVs
	# Args: (input.npz, reference.npz)
    WisecondorX predict $1 $2 ${outdir}/${1%%npz} --bed --plot\
		# --minrefbins $min_ref_bins
		# --maskrepeats $mask_repeats
		# --alpha $alpha
		# --beta $beta
		# --blacklist $blacklist
		# --bed
		# --plot
}

function wcx_gender {
	# Function to check gender of WisecondorX .npz file
	# Args: input.npz
	local gender=$(WisecondorX gender $1)
	echo "$gender"
}

function wcx_run {
	# Run WisecondorX dependent on input sample gender
	# Args: input.npz
	input_npz=$1
	# Run with appropriate reference for gender
	if [[ $(wcx_gender $input_npz) =~ "female" ]]; then
		$(wcx_command $input_npz reference_female.npz)
	elif [[ $(wcx_gender $input_npz) =~ "male" ]]; then
		$(wcx_command $input_npz reference_male.npz)
	fi
} 

# Download input data
# Download BAM files for reference ; ref_bams - array of healthy male and female bams, identified by '_M_' or '_F_' in filename
# Download BAM file for sample ; input_bam - input BAM file. Must be aligned to same reference genome as reference sample bams
dx-download-all-inputs

# Install conda. Set to beginning of path variable for python calls
gzip -d Miniconda2-latest-Linux-x86_64.sh.gz
bash Miniconda2-latest-Linux-x86_64.sh -b -p $HOME/miniconda
export PATH="$HOME/miniconda/bin:$PATH"

# Install WisecondorX
conda install -f -y -c conda-forge -c bioconda wisecondorx=0.2.0

# Create output directory
male_out=out/reference_male
female_out=out/reference_female
mkdir -p $male_out $female_out

# Download reference bams
dx download -r ${project_for_newref}:/wisecondorx_reference
mv wisecondorx_reference/* $HOME

# Convert all bams to numpy zip files
for file in *.bam; do
	prefix=${file%%.bam}
	WisecondorX convert $file ${prefix}.npz # --binsize $convert_binsize --retdist $convert_retdist --retthres $convert_retthresh
done

# Create male and female sample holding directories
male_dir="$HOME/male"
female_dir="$HOME/female"
mkdir -p $male_dir $female_dir

# Separate the male and female reference sample npz files into respective directories
for file in *.npz; do
	if [[ $(wcx_gender $file) =~ "male" ]]; then mv $file $male_dir 
	elif [[ $(wcx_gender $file) =~ "female" ]]; then mv $file $female_dir
  	fi
done

# Create references for Male and Female samples
WisecondorX newref male/*.npz ${male_out}/reference_male.npz --cpus 4 # --binsize $ref_binsize --refsize $ref_refsize
WisecondorX newref female/*.npz ${female_out}/reference_female.npz --cpus 4 # --binsize $ref_binsize --refsize $ref_refsizess

# Upload output data
dx-upload-all-outputs
