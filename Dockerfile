FROM alpine
RUN apk add --no-cache --upgrade bash
RUN apk add jq
RUN apk add docker-cli
COPY build.sh . 
RUN chmod +x build.sh
COPY BP-BASE-SHELL-STEPS/functions.sh . 
ENV MAX_IMAGES 2 
ENV SLEEP_DURATION 5s
ENV ACTIVITY_SUB_TASK_CODE IMAGE_CLEANUP
ENTRYPOINT [ "./build.sh" ]