import { IsInt } from 'class-validator';

export class RemoveFavoriteDto {
  @IsInt()
  menu_id: number;
}