# WisecondorX newref v1.0
[CenterForMedicalGeneticsGhent/WisecondorX v0.2.0](https://github.com/CenterForMedicalGeneticsGhent/WisecondorX/releases/tag/v0.2.0)

## What does this app do?
Create male and female reference files for WisecondorX.

## What are typical use cases for this app?
WisecondorX predicts CNVs from NGS samples. For this prediction, a specific reference file made from sequences of healthy individuals is required for comparison. This app takes WGS alignments from both male and female healthy sequences and generates a WiscondorX reference for each gender. 

## What inputs are required for this app to run?
The app takes the **name of a DNAnexus project** as input. The project should contain the alignment output files (`.bam` and `.bai`) for each input sample to WisecondorX newref. All inputs should be placed in the top-level project directory 'wisecondorx_reference/'.  A minimum of 10 male and 10 female input samples are required.

## What does this app output?
* reference_male.npz - WisecondorX reference for male samples
* reference_female.npz - WisecondorX reference for female samples

## How does this app work?
This app separates all input files into directories based on gender, detected using `WisecondorX gender`. Following this, `WisecondorX newref` is called on the male and female sample sets and the reference files created are returned by the app.

*Developed by Viapath Genome Informatics*
