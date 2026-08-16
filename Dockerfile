FROM ubuntu:22.04 AS cpp-build

RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    libboost-all-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY cpp/ ./cpp/

WORKDIR /build/cpp
RUN cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --target run_planner

FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
COPY --from=cpp-build /build/cpp/build/bin/run_planner ./run_planner

RUN chmod +x ./run_planner

CMD ["python", "simulator.py"]