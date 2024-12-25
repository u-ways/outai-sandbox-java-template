# OutAI Sandbox Java Project

[![Java Version](https://img.shields.io/badge/Java-21-blue)](https://openjdk.org/projects/jdk/21/)
[![Gradle Version](https://img.shields.io/badge/Gradle-8.11-blue)](https://gradle.org/)
[![License](https://img.shields.io/badge/License-MIT-blue)](https://opensource.org/licenses/MIT)

## Quick Usage:

If you're a reviewer in the Sphere IDE, you can quickly evaluate the project tests by running: 

```bash
make test-app
```

If you encounter any issues, please download the ZIP attached in the workplace, and run the following commands:

```bash 
make check-test-docker
```

Which will run the tests in an isolated environment using Docker.

## Table of Contents

- [Introduction](#introduction)
    - [Problem Statement](#problem-statement)
    - [Solution](#solution)
- [Features](#features)
    - [Instantly bundle (ZIP) your source code](#a-instantly-bundle-zip-your-source-code)
    - [Ensure Your Code is Well-Formatted](#b-ensure-your-code-is-well-formatted)
    - [Want to be strict? Configure and run the Sonarlint!](#c-want-to-be-strict-configure-and-run-the-sonarlint)
    - [Isolated Development/Testing Environment](#d-isolated-developmenttesting-environment)
- [Contributing](#contributing)

## Introduction

The OutAI Sandbox Java Project is a template designed to help developers quickly evaluate and contribute to Java
projects. This template provides a standardised environment with essential tools and configurations, allowing
contributors to focus on development rather than setup.

### Problem Statement

Certain tasks require high attention to detail and precision, such as QA testing, code reviews, debugging, and rewrites.

On top of that, you need to allocate time to produce a creative prompt based on the task at hand. This entire process
can be quite time-consuming and error-prone, especially when you're working in a non-standardised environment.

This not only impact the tasker, the reviewer is also highly affected by the quality of the source code shared.
In the event of a bad environment setup, the reviewer might spend more time bootstrapping the project rather 
than focusing on the actual review at hand.

For me, the aim is to produce a high-quality task output to train the next generation of GPT models to help me and my
team in our actual jobs. Therefore, I want to focus on the task at hand, not the setup.

### Solution

This project aims to provide a reusable template for Java projects, allowing developers to quickly evaluate and rewrite
model responses for the task at hand. On top of that, it comes with a set of useful tools and configurations to help
you deliver high-quality work.

## Features

#### A. Instantly bundle (ZIP) your source code

Whenever you do code changes or need to rewrite the model responses, you usually need to bundle your source code to
share it with the reviewer. The following command will bundle your source code without the cache or build artifacts:

```shell
make bundle
```

#### B. Ensure Your Code is Well-Formatted

Your code should be well-formatted to ensure readability. We rely on a modern Java formatter called "Planter" via
the [Spotless](https://github.com/diffplug/spotless/tree/main/plugin-gradle#-spotless-plugin-for-gradle) Gradle plugin.
The following command will format your code:

```shell
make format-code
```

This allows you to produce easy to read code submissions. Be sure to check out the
[palantir-java-format](https://plugins.jetbrains.com/plugin/13180-palantir-java-format) IntelliJ plugin if you're
a JetBrains user.

#### C. Want to be strict? Sonarlint is set up for you!

The project is pre-configured with the [Sonarlint](https://www.sonarsource.com/products/sonarlint/) plugin.

```shell
make check-lint
```

The rules you can enable are described here:

- https://rules.sonarsource.com/java/

You can easily configure them to your liking via `build.gradle.kts`.

#### D. Isolated Development/Testing Environment

We rely on containerisation (Docker) to provide an isolated environment for running the project. This ensures that
the project runs consistently across different machines. Here are the available commands:

- `make check-test-docker`: Run the test suite in a Docker container.
- `make check-format-docker`: Run the code formatter in a Docker container.
- `make check-lint-docker`: Run the linter in a Docker container.
- `make check-code-quality-docker`: Run all of the above in a Docker container.

Which means you don't need to install Java, Gradle, or any other dependencies on your machine to verify the output of
this project other than [Docker](https://docs.docker.com/engine/install/)!

### Contributing

If you have any suggestions or improvements, feel free to open a PR or an issue.

I am always open to feedback and suggestions to improve this template.

___