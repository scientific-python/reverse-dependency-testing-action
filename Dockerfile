FROM mambaorg/micromamba:latest

COPY --chown=$MAMBA_USER:$MAMBA_USER entrypoint.sh /entrypoint.sh
COPY --chown=$MAMBA_USER:$MAMBA_USER get_yml.py /tmp/get_yml.py

USER root
RUN chown $MAMBA_USER /tmp
USER $MAMBA_USER
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
