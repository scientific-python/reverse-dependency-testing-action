FROM mambaorg/micromamba:latest

COPY --chown=$MAMBA_USER:$MAMBA_USER entrypoint.sh /entrypoint.sh
COPY --chown=$MAMBA_USER:$MAMBA_USER get_yml.py /tmp/get_yml.py

RUN micromamba install --yes python
ARG MAMBA_DOCKERFILE_ACTIVATE=1

RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]