import torch
import torch.nn as nn

class TemporalLSTM(nn.Module):
    """
    PyTorch LSTM for predicting 'Time to Completion' based on historical sequences.
    """
    def __init__(self, input_size=5, hidden_size=64, num_layers=2):
        super(TemporalLSTM, self).__init__()
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True)
        self.fc = nn.Linear(hidden_size, 1)

    def forward(self, x):
        h0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size)
        c0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size)
        out, _ = self.lstm(x, (h0, c0))
        out = self.fc(out[:, -1, :])
        return out

def estimate_time(sequence_data: list) -> float:
    # Simulation: Convert historical task times to tensor and predict
    model = TemporalLSTM()
    model.eval()
    
    # Mock input: 1 batch, 10 time steps, 5 features
    mock_input = torch.randn(1, 10, 5)
    with torch.no_grad():
        prediction = model(mock_input)
    
    # Return estimated minutes (scaled)
    return float(prediction.item() * 60 + 30)
