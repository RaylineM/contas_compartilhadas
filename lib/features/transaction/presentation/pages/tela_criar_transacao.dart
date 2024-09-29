import 'package:contas_compartilhadas/core/common/cubit/user/user_cubit.dart';
import 'package:contas_compartilhadas/features/group/data/models/grupo_modelo.dart';
import 'package:contas_compartilhadas/features/group/presentation/bloc/grupo_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contas_compartilhadas/features/transaction/presentation/bloc/transacao_bloc.dart';
import 'package:contas_compartilhadas/core/enums/categoria_transacao.dart';
import 'package:contas_compartilhadas/core/enums/tipo_transacao.dart';
import 'package:intl/intl.dart';

class TelaCriarTransacao extends StatefulWidget {
  const TelaCriarTransacao({super.key});

  @override
  State<TelaCriarTransacao> createState() => _TelaCriarTransacaoState();
}

class _TelaCriarTransacaoState extends State<TelaCriarTransacao> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  TipoTransacao? _tipoSelecionado;
  CategoriaTransacao? _categoriaSelecionada;
  String? _grupoSelecionado;

  @override
  void initState() {
    super.initState();
    _tipoSelecionado = TipoTransacao.variavel;
    _categoriaSelecionada = CategoriaTransacao.outros;
    carregarGrupos();
  }

  void selecionarData() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (dataSelecionada != null) {
      _dataController.text = DateFormat('yyyy-MM-dd').format(dataSelecionada);
    }
  }

  void carregarGrupos() {
    BlocProvider.of<GrupoBloc>(context).add(EventoCarregarGrupos(
      usuarioId: context.read<UsuarioCubit>().state.id,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Transação'),
        backgroundColor: Colors.blueGrey[800],
        elevation: 4,
      ),
      body: BlocConsumer<TransacaoBloc, TransacaoState>(
        listener: (context, state) {
          if (state is TransacaoEstadoErro) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensagem),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else if (state is TransacaoEstadoCriadaComSucesso) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transação criada com sucesso.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is TransacaoEstadoCarregando) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _tituloController,
                      labelText: 'Título',
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      controller: _valorController,
                      labelText: 'Valor',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: selecionarData,
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: _dataController,
                          labelText: 'Data',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    BlocBuilder<GrupoBloc, GrupoState>(
                      builder: (context, state) {
                        if (state is GrupoEstadoCarregando) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is GrupoEstadoSucesso) {
                          final grupos = state.grupos;
                          final gruposFiltrados = grupos
                              .where((grupo) => grupo.grupoId != 0)
                              .toList();

                          gruposFiltrados.insert(
                            0,
                            GrupoModelo(
                              grupoId: '0',
                              nome: 'Selecione um grupo',
                              descricao: '',
                              membrosId: [],
                              administradorId: '',
                              transacoesId: [],
                            ),
                          );

                          return _buildDropdown<String>(
                            value: _grupoSelecionado,
                            items: gruposFiltrados.map((opcao) {
                              return DropdownMenuItem<String>(
                                value: opcao.grupoId,
                                child: Text(opcao.nome),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _grupoSelecionado = newValue;
                              });
                            },
                          );
                        } else {
                          return const Text('Erro ao carregar grupos');
                        }
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildDropdown<TipoTransacao>(
                      value: _tipoSelecionado,
                      items: TipoTransacao.values.map((TipoTransacao tipo) {
                        return DropdownMenuItem<TipoTransacao>(
                          value: tipo,
                          child: Text(tipo.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (TipoTransacao? newValue) {
                        setState(() {
                          _tipoSelecionado = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildDropdown<CategoriaTransacao>(
                      value: _categoriaSelecionada,
                      items: CategoriaTransacao.values.map((CategoriaTransacao categoria) {
                        return DropdownMenuItem<CategoriaTransacao>(
                          value: categoria,
                          child: Text(categoria.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (CategoriaTransacao? newValue) {
                        setState(() {
                          _categoriaSelecionada = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 24.0),
                    Center(
                      child: SizedBox(
                        width: double.infinity, 
                        child: ElevatedButton(
                          onPressed: () {
                            final titulo = _tituloController.text;
                            final valor = double.tryParse(_valorController.text) ?? 0.0;

                            if (titulo.isEmpty ||
                                valor == 0.0 ||
                                _tipoSelecionado == null ||
                                _categoriaSelecionada == null ||
                                _grupoSelecionado == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Todos os campos devem ser preenchidos.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            final user = context.read<UsuarioCubit>().state;
                            final usuarioId = user.id;

                            BlocProvider.of<TransacaoBloc>(context).add(
                              EventoCriarTransacao(
                                titulo: titulo,
                                valor: valor,
                                usuarioId: usuarioId,
                                data: DateTime.parse(_dataController.text),
                                tipo: _tipoSelecionado!,
                                categoria: _categoriaSelecionada!,
                                grupoId: _grupoSelecionado!,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF607D8B),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 5,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: const Text(
                            'Criar Transação',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 27, 9, 31), 
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      items: items,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
    );
  }
}
