# FROM mambaorg/micromamba:latest

# COPY --chown=$MAMBA_USER:$MAMBA_USER entrypoint.sh /entrypoint.sh
# COPY --chown=$MAMBA_USER:$MAMBA_USER get_yml.py /tmp/get_yml.py

# USER root

# RUN chmod +x /entrypoint.sh

# ENTRYPOINT ["/entrypoint.sh"]

FROM mambaorg/micromamba:latest

COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes

ARG MAMBA_DOCKERFILE_ACTIVATE=1

RUN python -c 'import geopandas; print(geopandas.show_versions())'