import { Test, TestingModule } from '@nestjs/testing';
import { ProteinPreferencesController } from './protein-preferences.controller';

describe('ProteinPreferencesController', () => {
  let controller: ProteinPreferencesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ProteinPreferencesController],
    }).compile();

    controller = module.get<ProteinPreferencesController>(ProteinPreferencesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
