import { IsInt, IsBoolean, IsOptional } from 'class-validator';

export class SetProteinPreferenceDto {
  @IsInt()
  protein_type_id: number;

  @IsBoolean()
  @IsOptional()
  exclude?: boolean = true; // true = user doesn't want this protein
}
