FROM ubuntu:20.04

# Install necessary dependencies
ENV TZ=Asia/Colombo
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y golang-go curl jq texlive-latex-base git tzdata mailutils ssmtp

COPY ssmtp.conf /etc/ssmtp/ssmtp.conf
# Install grafana-reporter
ENV PATH="/usr/local/git/bin:${PATH}"
RUN go get github.com/IzakMarais/reporter/...
RUN go install /root/go/src/github.com/IzakMarais/reporter/cmd/grafana-reporter

ENV PATH="/root/go/bin:${PATH}"



# Copy the script to the container
COPY script.sh /app/script.sh

# Set the working directory
WORKDIR /app

# Make the script executable
RUN chmod +x script.sh

# Set the entry point
ENTRYPOINT ["./script.sh"]

CMD sleep 3600