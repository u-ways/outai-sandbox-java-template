# Gradle's official Ubuntu JDK21 image.
#   See:
#     https://github.com/keeganwitt/docker-gradle/blob/42b5732bf31f09416c727cd6d3899be90003b85a/jdk21/Dockerfile
#   NOTE:
#     We use a Ubuntu image instead of the slim Alpine image as official Alpine OS uses musl libc
#     instead of the more common glibc used by most other Linux distributions. Many pre-built
#     binaries, including many JDK distributions, expect glibc, so running Alpine risks us
#     encounting unexpected errors and wasting time debugging them for no functional benefit.
FROM gradle:8.11-jdk21

# We (temporarily) switch to root to modify user and group IDs
USER root
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupmod -g ${USER_GID} gradle && \
    usermod -u ${USER_UID} -g ${USER_GID} gradle && \
    chown -R gradle:gradle /home/gradle
USER gradle

# Define $HOME directory to the gradle user's home directory so
# our subsequent definitions have the correct $HOME as we will
# run commands in the contianer using the gradle user.
ARG HOME=/home/gradle
# Ensure appropriate environment variables set.
ENV GRADLE_USER_HOME=$HOME/.gradle \
    MAVEN_HOME=$HOME/.m2 \
    GPG_HOME=$HOME/.gnupg \
    WORKING_DIR=$HOME/app
# Create necessary directories (if they don't exist)
RUN mkdir -p \
      $GRADLE_USER_HOME \
      $MAVEN_HOME \
      $GPG_HOME \
      $WORKING_DIR
WORKDIR $WORKING_DIR

# Default command to run when the container starts.
CMD ["./gradlew", "tasks"]
