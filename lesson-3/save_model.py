import torch
import torchvision.models as models
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--out", type=str, default="model.pt", help="Path to the model")
args = parser.parse_args()

print("Downloading model mobi;enet_v2...")
model = models.mobilenet_v2(pretrained=True)
model.eval()

example_input = torch.randn(1, 3, 224, 224)
traced = torch.jit.trace(model, example_input)

traced.save(args.out)
print(f"Model saved in {args.out}")
