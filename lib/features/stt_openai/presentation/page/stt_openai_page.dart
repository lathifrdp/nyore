import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyore/features/stt_openai/bloc/speech_to_text_bloc.dart';

class SttOpenAiPage extends StatefulWidget {
  const SttOpenAiPage({super.key});

  @override
  State<SttOpenAiPage> createState() => _SttOpenAiPageState();
}

class _SttOpenAiPageState extends State<SttOpenAiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speech AI')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<SpeechToTextBloc, SpeechToTextState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is SpeechToTextInitial) {
              return _buildInitial(context);
            } else if (state is ChatListening) {
              return const Center(child: Text('Listening...'));
            } else if (state is ChatLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChatSuccess) {
              return Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('You: ${state.userMessage}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 20),
                        Text('AI: ${state.aiResponse}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => context
                            .read<SpeechToTextBloc>()
                            .add(StartListening()),
                        child: const Text('Talk Again'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => context
                            .read<SpeechToTextBloc>()
                            .add(StopSpeaking()),
                        child: const Text('Stop Speaking'),
                      ),
                    ],
                  )
                ],
              );
            } else if (state is ChatError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<SpeechToTextBloc>().add(StopListening()),
        child: const Icon(Icons.stop),
      ),
    );
  }

  Widget _buildInitial(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.mic),
        label: const Text('Start Talking'),
        onPressed: () => context.read<SpeechToTextBloc>().add(StartListening()),
      ),
    );
  }
}
