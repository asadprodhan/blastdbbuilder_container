FROM mambaorg/micromamba:1.5.10

RUN micromamba install -y -n base -c conda-forge -c bioconda \
      python=3.11 \
      pip \
      blast=2.16.0 \
      seqkit=2.10.1 \
      ncbi-datasets-cli \
      git \
      unzip \
      wget \
 && micromamba clean -a -y

RUN micromamba run -n base pip install --no-cache-dir blastdbbuilder==1.1.0

USER root

RUN bash -lc 'for x in blastdbbuilder makeblastdb blastn blastdb_aliastool seqkit datasets dataformat wget unzip; do \
  ln -sf "$(micromamba run -n base which "$x")" "/usr/local/bin/$x"; \
done'

RUN printf '%s\n' \
'#!/usr/bin/env bash' \
'set -euo pipefail' \
'' \
'cmd="$1"' \
'shift' \
'' \
'case "$cmd" in' \
'pull)' \
'    sif="$1"' \
'    image="$2"' \
'    echo "[blastdbbuilder shim] pull $image -> $sif"' \
'    mkdir -p "$(dirname "$sif")"' \
'    touch "$sif"' \
'    ;;' \
'' \
'exec)' \
'    sif="$1"' \
'    shift' \
'    tool="$1"' \
'    shift' \
'' \
'    case "$tool" in' \
'        datasets)' \
'            exec datasets "$@"' \
'            ;;' \
'        dataformat)' \
'            exec dataformat "$@"' \
'            ;;' \
'        makeblastdb)' \
'            exec makeblastdb "$@"' \
'            ;;' \
'        blastn)' \
'            exec blastn "$@"' \
'            ;;' \
'        seqkit)' \
'            exec seqkit "$@"' \
'            ;;' \
'        unzip)' \
'            exec unzip "$@"' \
'            ;;' \
'        wget)' \
'            exec wget "$@"' \
'            ;;' \
'        *)' \
'            exec "$tool" "$@"' \
'            ;;' \
'    esac' \
'    ;;' \
'' \
'*)' \
'    echo "Unsupported singularity command: $cmd"' \
'    exit 1' \
'    ;;' \
'esac' \
> /usr/local/bin/singularity \
&& chmod +x /usr/local/bin/singularity \
&& ln -s /usr/local/bin/singularity /usr/local/bin/apptainer

WORKDIR /work

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER mambauser

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
