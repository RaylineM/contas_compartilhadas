import 'package:contas_compartilhadas/core/common/cubit/user/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contas_compartilhadas/features/group/presentation/bloc/grupo_bloc.dart';

class TelaCriarGrupo extends StatefulWidget {
  @override
  _TelaCriarGrupoState createState() => _TelaCriarGrupoState();
}

class _TelaCriarGrupoState extends State<TelaCriarGrupo> {
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Grupo'),
        backgroundColor:  Color(0xFF455A64),
        elevation: 4,
      ),
      body: BlocConsumer<GrupoBloc, GrupoState>(
        listener: (context, state) {
          if (state is GrupoEstadoErro) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensagem),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else if (state is GrupoEstadoCriadoComSucesso) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Grupo criado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildGroupCard(),
                  const SizedBox(height: 24.0),
                  _buildCreateButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupCard() {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Informações do Grupo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _nomeController,
              label: 'Nome do Grupo',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'O nome do grupo é obrigatório.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _descricaoController,
              label: 'Descrição',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'A descrição é obrigatória.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      validator: validator,
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          final nome = _nomeController.text;
          final descricao = _descricaoController.text;

          final user = context.read<UsuarioCubit>().state;
          final administradorId = user.id;
          BlocProvider.of<GrupoBloc>(context).add(
            EventoCriarGrupo(
              nome: nome,
              descricao: descricao,
              administradorId: administradorId,
              membrosId: [],
              transacoesId: [],
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:  Color(0xFF607D8B),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: const Text('Criar Grupo'),
    );
  }
}
