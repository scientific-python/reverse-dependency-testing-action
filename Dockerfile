FROM mambaorg/micromamba:latest

COPY --chown=$MAMBA_USER:$MAMBA_USER entrypoint.sh /entrypoint.sh
COPY --chown=$MAMBA_USER:$MAMBA_USER get_yml.py /get_yml.py

USER root

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
