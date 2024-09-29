import 'package:contas_compartilhadas/core/common/cubit/user/user_cubit.dart';
import 'package:contas_compartilhadas/features/group/domain/entities/grupo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contas_compartilhadas/features/group/presentation/bloc/grupo_bloc.dart';
import 'package:contas_compartilhadas/core/rotas.dart' as rotas;

class TelaListarGrupos extends StatefulWidget {
  const TelaListarGrupos({super.key});

  @override
  State<TelaListarGrupos> createState() => _TelaListarGruposState();
}

class _TelaListarGruposState extends State<TelaListarGrupos> {
  List<Grupo> grupos = [];
  bool carregouGrupos = false;

  @override
  void initState() {
    super.initState();
    carregarGrupos();
  }

  void carregarGrupos() {
    final usuarioId = context.read<UsuarioCubit>().state.id;
    context.read<GrupoBloc>().add(EventoCarregarGrupos(usuarioId: usuarioId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        backgroundColor:  Color(0xFF455A64),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              Navigator.of(context).pushNamed(rotas.leitorDeQrCode);
            },
          ),
        ],
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
          } else if (state is GrupoEstadoSucesso) {
            setState(() {
              grupos = state.grupos;
              carregouGrupos = true;
            });
          }
        },
        builder: (context, state) {
          if (!carregouGrupos) {
            if (state is GrupoEstadoCarregando) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GrupoEstadoErro) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.mensagem,
                    style: TextStyle(color: Colors.redAccent, fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          }

          if (grupos.isNotEmpty) {
            return ListView.separated(
              itemCount: grupos.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: Colors.grey,
              ),
              itemBuilder: (context, index) {
                final grupo = grupos[index];
                return Card(
                  elevation: 8.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: Icon(
                      Icons.group,
                      color: Colors.blueGrey[700],
                      size: 36.0,
                    ),
                    title: Text(
                      grupo.nome,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    subtitle: Text(
                      grupo.descricao,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        rotas.telaDetalhesGrupo,
                        arguments: grupo,
                      );
                    },
                  ),
                );
              },
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Nenhum grupo encontrado',
                style: TextStyle(fontSize: 16.0, color: Colors.blueGrey[600]),
              ),
            ),
          );
        },
      ),
    );
  }
}
