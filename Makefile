CXX ?= g++
CXXFLAGS ?= -std=c++17 -O2 -Wall -Wextra
TARGET = madagascar-widescreen-fix

all: $(TARGET)

$(TARGET): src/main.cpp
	$(CXX) $(CXXFLAGS) -o $(TARGET) src/main.cpp

clean:
	rm -f $(TARGET)
