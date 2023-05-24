FROM mambaorg/micromamba:latest

COPY --chown=$MAMBA_USER:$MAMBA_USER entrypoint.sh /entrypoint.sh
COPY --chown=$MAMBA_USER:$MAMBA_USER get_yml.py /tmp/get_yml.py

USER root

RUN micromamba install -y -n base python git -c conda-forge
ARG MAMBA_DOCKERFILE_ACTIVATE=1

RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]