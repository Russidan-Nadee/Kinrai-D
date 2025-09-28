import { Test, TestingModule } from '@nestjs/testing';
import { ProteinPreferencesService } from './protein-preferences.service';

describe('ProteinPreferencesService', () => {
  let service: ProteinPreferencesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ProteinPreferencesService],
    }).compile();

    service = module.get<ProteinPreferencesService>(ProteinPreferencesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
