
<h1 align="center">blastdbbuilder Container: Reproducible Runtime for Building Customised BLASTn Databases</h1>

<h3 align="center">M. Asaduzzaman Prodhan<sup>*</sup> </h3>

<div align="center"><b> DPIRD Diagnostics and Laboratory Services </b></div>
<div align="center"><b> Department of Primary Industries and Regional Development </b></div>
<div align="center"><b> 31 Cedric St, Stirling WA 6021, Australia </b></div>
<div align="center"><b> *Correspondence: asad.prodhan@dpird.wa.gov.au; prodhan82@gmail.com </b></div>

<br />

<p align="center">
  <a href="https://github.com/asadprodhan/blastdbbuilder/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-GPL%203.0-yellow.svg" alt="License GPL 3.0"></a>
  <a href="https://orcid.org/0000-0002-1320-3486"><img src="https://img.shields.io/badge/ORCID-green?style=flat-square&logo=ORCID&logoColor=white" alt="ORCID"></a>
  <a href="https://doi.org/10.5281/zenodo.18933806"><img src="https://zenodo.org/badge/1177535848.svg" alt="DOI"></a>
</p>


## **Content**

<img src="https://raw.githubusercontent.com/asadprodhan/blastdbbuilder/main/blastdbbuilder_logo.png"
     width="190"
     align="right">

- [Introduction](#introduction)
- [blastdbbuilder Container](#blastdbbuilder-container)
- [Features](#features)
- [Container Contents](#container-contents)
- [Container Image](#container-image)
- [How to Pull the Container](#how-to-pull-the-container)
- [Running blastdbbuilder in the Container](#running-blastdbbuilder-in-the-container)
- [How to use `blastdbbuilder` on HPC](#how-to-use-blastdbbuilder-on-hpc)
- [Step 1 — Download genomes](#step-1--download-genomes)
- [Step 2 — Concatenate genomes](#step-2--concatenate-genomes)
- [Step 3 — Build BLAST database](#step-3--build-blast-database)
- [Final output files](#final-output-files)
- [Citation](#citation)
- [Support](#support)
  

## **Introduction**

A **BLASTn database** provides the essential reference framework for comparing query sequences and forms the backbone of sequence-based analysis.

Accurate results in areas such as:

- molecular diagnostics
- biosecurity surveillance
- microbial genomics
- environmental sequencing
- evolutionary studies
- functional genomics

depend on **high-quality, well-curated reference databases**.

Public databases are comprehensive but rapidly expanding. As a result, they often contain:

- redundant sequences
- incomplete genomes
- low-quality assemblies
- entries irrelevant to specific analyses

This can lead to **slower searches and reduced analytical precision**.

A **custom database**, in contrast, is like a carefully organised library — smaller, faster to search, and focused on the relevant biological scope.

To simplify database construction, **blastdbbuilder** provides an automated command-line workflow that:

1. downloads genomes from NCBI RefSeq  
2. concatenates FASTA sequences  
3. builds a BLAST nucleotide database  

To ensure reproducibility across computing environments, the **blastdbbuilder container** packages all required dependencies into a portable runtime environment.


## **blastdbbuilder Container**

The container provides a **fully self-contained runtime environment** for running `blastdbbuilder`.

All required dependencies are bundled inside the container, allowing the workflow to run without installing external software.

This guarantees **consistent execution across different systems**, including:

- laptops
- servers
- high-performance computing (HPC) clusters


## **Features**

- Fully reproducible containerised runtime
- Compatible with **Docker**, **Singularity**, and **Apptainer**
- No manual dependency installation required
- Portable across Linux systems and HPC environments
- Automated download of RefSeq genomes from NCBI
- FASTA concatenation into a unified reference dataset
- Automated BLAST nucleotide database construction
- HPC-ready workflows compatible with **SLURM**
  

## **Container Contents**

| Tool | Purpose |
|:-----|:-------|
| blastdbbuilder | Database construction workflow |
| NCBI datasets CLI | Genome downloads |
| dataformat | Metadata processing |
| BLAST+ | BLAST database creation |
| seqkit | FASTA manipulation |
| unzip | Archive extraction |


## **Container Image**

```
quay.io/asadprodhan/blastdbbuilder:v1.0.3
```


## **How to Pull the Container**

Docker

```
docker pull quay.io/asadprodhan/blastdbbuilder:v1.0.3
```

Singularity

```
singularity pull docker://quay.io/asadprodhan/blastdbbuilder:v1.0.3
```


## **Running blastdbbuilder in the Container**

```
singularity exec blastdbbuilder_v1.0.3.sif blastdbbuilder --help
```

Example workflow

```
blastdbbuilder --download --archaea
blastdbbuilder --concat
blastdbbuilder --build
```


## **How to use `blastdbbuilder` on HPC**


On HPC systems, the workflow is typically executed in **three independent stages**:

1. Download genomes  
2. Concatenate FASTA files  
3. Build the BLAST database  

Each stage can be submitted as a **separate SLURM job**, which improves resource management and fault tolerance.

---

## **Step 1 — Download genomes**

Example SLURM script:

```
#!/bin/bash --login
#SBATCH --job-name=blastdbbuilder-archaea-download
#SBATCH --account=xxx
#SBATCH --partition=xxx
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --output=blastdbbuilder_archaea_download_%j.out
#SBATCH --error=blastdbbuilder_archaea_download_%j.err
#SBATCH --export=NONE

set -euo pipefail
unset SLURM_EXPORT_ENV

module load singularity/4.1.0-slurm

BASE="$MYSCRATCH"

WORKDIR="${BASE}/blastdbbuilder_archaea_test"
CONTAINER_DIR="${BASE}/containers"
CONTAINER="${CONTAINER_DIR}/blastdbbuilder_v1.0.3.sif"

IMAGE_URI="docker://quay.io/asadprodhan/blastdbbuilder:v1.0.3"

export SINGULARITY_CACHEDIR="${BASE}/.singularity/cache"
export SINGULARITY_TMPDIR="${BASE}/.singularity/tmp/${SLURM_JOB_ID}"

mkdir -p "$WORKDIR" "$CONTAINER_DIR" "$SINGULARITY_CACHEDIR" "$SINGULARITY_TMPDIR"

cd "$WORKDIR"

if [ ! -f "$CONTAINER" ]; then
    singularity pull "$CONTAINER" "$IMAGE_URI"
fi

singularity exec \
  --bind "$WORKDIR":"$WORKDIR" \
  --pwd "$WORKDIR" \
  "$CONTAINER" \
  blastdbbuilder --download --archaea
```

**Submit job:**

```
sbatch blastdbbuilder_container_archaea_download_slurm.sh
```

---

## **Step 2 — Concatenate genomes**

```
#!/bin/bash --login
#SBATCH --job-name=blastdbbuilder-archaea-download
#SBATCH --account=xxx
#SBATCH --partition=xxx
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --output=blastdbbuilder_archaea_concat_%j.out
#SBATCH --error=blastdbbuilder_archaea_concat_%j.err
#SBATCH --export=NONE

set -euo pipefail
unset SLURM_EXPORT_ENV

module load singularity/4.1.0-slurm

BASE="$MYSCRATCH"

WORKDIR="${BASE}/blastdbbuilder_archaea_test"
CONTAINER_DIR="${BASE}/containers"
CONTAINER="${CONTAINER_DIR}/blastdbbuilder_v1.0.3.sif"

IMAGE_URI="docker://quay.io/asadprodhan/blastdbbuilder:v1.0.3"

export SINGULARITY_CACHEDIR="${BASE}/.singularity/cache"
export SINGULARITY_TMPDIR="${BASE}/.singularity/tmp/${SLURM_JOB_ID}"

mkdir -p "$WORKDIR" "$CONTAINER_DIR" "$SINGULARITY_CACHEDIR" "$SINGULARITY_TMPDIR"

cd "$WORKDIR"

if [ ! -f "$CONTAINER" ]; then
    singularity pull "$CONTAINER" "$IMAGE_URI"
fi

singularity exec \
  --bind "$WORKDIR":"$WORKDIR" \
  --pwd "$WORKDIR" \
  "$CONTAINER" \
  blastdbbuilder --concat
```

**Submit job:**

```
sbatch blastdbbuilder_container_concat_slurm.sh
```

---

# **Step 3 — Build BLAST database**

```
#!/bin/bash --login
#SBATCH --job-name=blastdbbuilder-archaea-download
#SBATCH --account=xxx
#SBATCH --partition=xxx
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --output=blastdbbuilder_archaea_build_%j.out
#SBATCH --error=blastdbbuilder_archaea_build_%j.err
#SBATCH --export=NONE

set -euo pipefail
unset SLURM_EXPORT_ENV

module load singularity/4.1.0-slurm

BASE="$MYSCRATCH"

WORKDIR="${BASE}/blastdbbuilder_archaea_test"
CONTAINER_DIR="${BASE}/containers"
CONTAINER="${CONTAINER_DIR}/blastdbbuilder_v1.0.3.sif"

IMAGE_URI="docker://quay.io/asadprodhan/blastdbbuilder:v1.0.3"

export SINGULARITY_CACHEDIR="${BASE}/.singularity/cache"
export SINGULARITY_TMPDIR="${BASE}/.singularity/tmp/${SLURM_JOB_ID}"

mkdir -p "$WORKDIR" "$CONTAINER_DIR" "$SINGULARITY_CACHEDIR" "$SINGULARITY_TMPDIR"

cd "$WORKDIR"

if [ ! -f "$CONTAINER" ]; then
    singularity pull "$CONTAINER" "$IMAGE_URI"
fi

singularity exec \
  --bind "$WORKDIR":"$WORKDIR" \
  --pwd "$WORKDIR" \
  "$CONTAINER" \
  blastdbbuilder --build
```

**Submit job:**

```
sbatch blastdbbuilder_container_build_slurm.sh
```

---

## **Final output files**

After completion you will obtain:

```
blastnDB/
├── nt.nhr
├── nt.nin
├── nt.nsq
├── nt.ndb
├── nt.njs
├── nt.not
├── nt.ntf
└── nt.nto
```

This is the **final BLAST nucleotide database**.

**Example usage:**

```
blastn -query query.fasta -db blastnDB/nt
```

## **Citation**

Cite this repository

If you use this container in your work, please cite it as follows:

**Prodhan, M. A.** (2026). blastdbbuilder Container: Reproducible Runtime for Building Customised BLASTn Databases. https://doi.org/10.5281/zenodo.18933806

---

## **Support**

For issues, bug reports, or feature requests, please contact: 
**Asad Prodhan. E-mail: asad.prodhan@dpird.wa.gov.au, prodhan82@gmail.com**
