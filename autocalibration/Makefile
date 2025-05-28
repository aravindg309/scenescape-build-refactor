IMAGE_NAME=scenescape-camcalibration

build:
	docker build --progress=plain -t $(IMAGE_NAME):latest .

run:
	docker run --rm $(IMAGE_NAME):latest

clean:
	docker rmi -f $(IMAGE_NAME):latest || true
