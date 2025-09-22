## Commands
```bash
docker build -f Dockerfile.fat -t ml_infer:fat .
docker build -f Dockerfile.slim -t ml_infer:slim .

# Launch
# (if sample.jpg is in the current directory)
docker run --rm -v $(pwd):/app ml_infer:fat --img /app/sample.jpg
docker run --rm -v $(pwd):/app ml_infer:slim --img /app/sample.jpg

# Size
docker images --format "{{.Repository}}:{{.Tag}} {{.Size}}"

# Layers
docker history ml_infer:fat | wc -l
docker history ml_infer:slim | wc -l
```
