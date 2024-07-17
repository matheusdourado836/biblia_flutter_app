import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/enums.dart';

final GlobalKey _textFieldKey = GlobalKey();

int _selectedReason = 0;
GlobalKey<FormState> _formKey = GlobalKey<FormState>();
TextEditingController _textEditingController = TextEditingController();

class ReportDialog extends StatelessWidget {
  final String devocionalId;
  final Comentario comentario;
  const ReportDialog({super.key, required this.devocionalId, required this.comentario});

  @override
  Widget build(BuildContext context) {
    final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    return AlertDialog(
      title: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Denunciar comentário'),
          SizedBox(height: 5),
          Text(
            'Selecione o motivo pelo qual você quer denunciar este comentário',
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12,)
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: ReportReasonsList()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final report = Report(
                  autor: comentario.name,
                  comment: comentario.comment,
                  commentId: comentario.id,
                  devocionalId: devocionalId,
                  reportReason: ReportReason.fromInt(_selectedReason).description,
                  text: _textEditingController.text,
                  createdAt: DateTime.now().toIso8601String()
              );
              devocionalProvider.reportComment(report: report);
              Navigator.pop(context, 1);
            }
          },
          child: const Text('Denunciar')
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      ],
    );
  }
}

class ReportReasonsList extends StatefulWidget {
  const ReportReasonsList({super.key});

  @override
  State<ReportReasonsList> createState() => _ReportReasonsListState();
}

class _ReportReasonsListState extends State<ReportReasonsList> {
  Color containerBorderColor = const Color.fromRGBO(215, 215, 215, 1);
  final List<ReportReason> reasons = ReportReason.values;

  void scrollToTextField() async => await Scrollable.ensureVisible(_textFieldKey.currentContext!, duration: const Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reasons.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, index) {
        if (index == reasons.length - 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: (_selectedReason == index)
                    ? Theme.of(context).colorScheme.primary.withOpacity(.6)
                    : Colors.transparent,
                child: RadioListTile<int>(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text(reasons[index].description, style: const TextStyle(fontSize: 12)),
                  value: index,
                  groupValue: _selectedReason,
                  onChanged: (value) =>
                      setState(() => _selectedReason = value!),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, bottom: 6),
                child: Text(
                  'Descreva o motivo da denúncia',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ),
              Container(
                key: _textFieldKey,
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: containerBorderColor),
                ),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _textEditingController,
                    onTap: (() => scrollToTextField()),
                    style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                    validator: (value) {
                      if (value != null) {
                        if (value.isEmpty || value.length < 4) {
                          setState(() => containerBorderColor = Colors.red);
                          scrollToTextField();
                          return 'digite pelo menos 4 caracteres';
                        }
                      }

                      return null;
                    },
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      errorStyle: TextStyle(color: Colors.red)),
                    keyboardType: TextInputType.multiline,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Container(
            color: (_selectedReason == index)
                ? Theme.of(context).colorScheme.primary.withOpacity(.6)
                : Colors.transparent,
            child: RadioListTile<int>(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 1.5),
              activeColor: Theme.of(context).colorScheme.primary,
              title: Text(reasons[index].description, style: const TextStyle(fontSize: 12)),
              value: index,
              groupValue: _selectedReason,
              onChanged: (value) => setState(() => _selectedReason = value!),
            ),
          );
        }
      },
    );
  }
}