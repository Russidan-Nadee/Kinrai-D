import { IsInt } from 'class-validator';

export class RemoveProteinPreferenceDto {
  @IsInt()
  protein_type_id: number;
}